import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
    @Published var restaurants: [Vendor]
    @Published var markets: [Vendor]
    @Published var activeOrder: Order?
    @Published var pastOrders: [Order]
    @Published var cartItems: [CartItem]
    @Published var userProfile: UserProfile

    let shortcuts: [CategoryShortcut]
    let campaigns: [Campaign]
    let homeSearchSuggestions: [String]
    let homePrimaryServices: [HomePrimaryService]
    let homeMiniServices: [HomeMiniService]
    let homeCuisines: [HomeCuisine]
    let homeQuickFilters: [HomeQuickFilter]
    let homeHeroBanners: [HomeHeroBanner]
    let homeRewardsOverview: HomeRewardsOverview
    let homePersonalRestaurants: [HomeRestaurantSpotlight]
    let homeCampaignRestaurants: [HomeRestaurantSpotlight]
    let homeMarkets: [HomeMarketSpotlight]
    let homeOpportunities: [HomeOpportunitySpotlight]

    var onTabChange: ((AppTab) -> Void)?
    private let repository: AppRepository
    private var usesRemoteUserProfile = false

    @Published var isInFoodService: Bool = false {
        didSet {
            if isInFoodService {
                onTabChange?(.home)
            }
        }
    }

    var allVendors: [Vendor] {
        restaurants + markets
    }

    @Published var selectedAddress: Address

    init(repository: AppRepository) {
        self.repository = repository
        restaurants = repository.restaurants
        markets = repository.markets
        activeOrder = repository.activeOrder
        pastOrders = repository.pastOrders
        cartItems = repository.cartItems
        selectedAddress = repository.selectedAddress

        shortcuts = repository.shortcuts
        campaigns = repository.campaigns
        userProfile = repository.userProfile
        homeSearchSuggestions = repository.homeSearchSuggestions
        homePrimaryServices = repository.homePrimaryServices
        homeMiniServices = repository.homeMiniServices
        homeCuisines = repository.homeCuisines
        homeQuickFilters = repository.homeQuickFilters
        homeHeroBanners = repository.homeHeroBanners
        homeRewardsOverview = repository.homeRewardsOverview
        homePersonalRestaurants = repository.homePersonalRestaurants
        homeCampaignRestaurants = repository.homeCampaignRestaurants
        homeMarkets = repository.homeMarkets
        homeOpportunities = repository.homeOpportunities
    }

    var featuredRestaurants: [Vendor] {
        restaurants.sorted { $0.rating > $1.rating }
    }

    var fastDeliveryVendors: [Vendor] {
        allVendors.filter { $0.tags.contains("30 dk") || $0.tags.contains("15 dk") || $0.tags.contains("Hızlı") }
    }

    var favoriteVendors: [Vendor] {
        allVendors.filter(\.isFavorite)
    }

    var suggestedProducts: [Product] {
        Array(allVendors.flatMap(\.menuSections).flatMap(\.products).prefix(6))
    }

    var cartItemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    var cartVendorName: String? {
        cartItems.first?.vendorName
    }

    var cartVendor: Vendor? {
        guard let vendorID = cartItems.first?.vendorID else { return nil }
        return allVendors.first(where: { $0.id == vendorID })
    }

    var cartSubtotal: Double {
        cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }

    var cartDeliveryFee: Double {
        cartVendor?.deliveryFee ?? 0
    }

    var cartServiceFee: Double {
        cartItems.isEmpty ? 0 : 8.99
    }

    var cartDiscount: Double {
        cartSubtotal >= 300 ? 40 : 0
    }

    var cartTotal: Double {
        max(0, cartSubtotal + cartDeliveryFee + cartServiceFee - cartDiscount)
    }

    func selectAddress(_ address: Address) {
        if usesRemoteUserProfile {
            selectedAddress = address
            onTabChange?(.home)
            return
        }

        repository.selectAddress(address)
        refreshState()
        onTabChange?(.home)
    }

    func applyRemoteUserProfile(_ profile: UserProfile) {
        usesRemoteUserProfile = true
        userProfile = profile

        if let matchingAddress = profile.addresses.first(where: { $0.id == selectedAddress.id }) {
            selectedAddress = matchingAddress
        } else if let firstAddress = profile.addresses.first {
            selectedAddress = firstAddress
        }
    }

    func resetUserProfileToRepository() {
        usesRemoteUserProfile = false
        userProfile = repository.userProfile
        selectedAddress = repository.selectedAddress
    }

    func addToCart(product: Product, from vendor: Vendor, selectedOptions: [String] = [], note: String = "", quantity: Int = 1) {
        repository.addToCart(
            product: product,
            from: vendor,
            selectedOptions: selectedOptions,
            note: note,
            quantity: quantity
        )
        refreshState()
    }

    func incrementQuantity(for item: CartItem) {
        repository.incrementQuantity(for: item)
        refreshState()
    }

    func decrementQuantity(for item: CartItem) {
        repository.decrementQuantity(for: item)
        refreshState()
    }

    func toggleFavorite(for vendor: Vendor) {
        repository.toggleFavorite(for: vendor)
        refreshState()
    }

    func reorder(_ order: Order) {
        repository.reorder(order)
        refreshState()
        onTabChange?(.home)
    }

    func placeOrder() {
        guard !cartItems.isEmpty else { return }
        repository.placeOrder(
            total: cartTotal,
            campaignNote: cartDiscount > 0 ? "40 TL sepet indirimi uygulandı" : "Standart teslimat",
            addressLine: "\(selectedAddress.line1), \(selectedAddress.detail)",
            vendorName: cartVendorName ?? "Sipariş"
        )
        refreshState()
        onTabChange?(.orders)
    }

    private func refreshState() {
        restaurants = repository.restaurants
        markets = repository.markets
        activeOrder = repository.activeOrder
        pastOrders = repository.pastOrders
        cartItems = repository.cartItems
        if !usesRemoteUserProfile {
            selectedAddress = repository.selectedAddress
            userProfile = repository.userProfile
        }
    }
}

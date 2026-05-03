import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
    @Published var restaurants: [Vendor]
    @Published var markets: [Vendor]
    @Published var activeOrder: Order?
    @Published var pastOrders: [Order]
    @Published var cartItems: [CartItem]
    @Published var userProfile: UserProfile
    @Published var homeSearchSuggestions: [String]
    @Published var homePrimaryServices: [HomePrimaryService]
    @Published var homeMiniServices: [HomeMiniService]
    @Published var homeHeroBanners: [HomeHeroBanner]
    @Published private(set) var isLoadingRemoteRestaurants = false
    @Published private(set) var homeErrorMessage: String?
    @Published private(set) var favoritesErrorMessage: String?
    @Published private(set) var ordersErrorMessage: String?

    let shortcuts: [CategoryShortcut]
    let campaigns: [Campaign]
    let homeCuisines: [HomeCuisine]
    let homeQuickFilters: [HomeQuickFilter]
    let homeRewardsOverview: HomeRewardsOverview
    let homePersonalRestaurants: [HomeRestaurantSpotlight]
    let homeCampaignRestaurants: [HomeRestaurantSpotlight]
    let homeMarkets: [HomeMarketSpotlight]
    let homeOpportunities: [HomeOpportunitySpotlight]

    var onTabChange: ((AppTab) -> Void)?
    private let repository: AppRepository
    private let vendorsClient = VendorsAPIClient()
    private let authClient = AuthAPIClient()
    private var usesRemoteUserProfile = false
    private var usesRemoteRestaurants = false
    private var usesRemoteHomeDiscover = false
    private var usesRemoteOrders = false

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

    func loadRemoteRestaurants() async {
        isLoadingRemoteRestaurants = true
        defer { isLoadingRemoteRestaurants = false }

        do {
            let remoteRestaurants = try await vendorsClient.fetchVendors(page: 1, limit: 20)
            if !remoteRestaurants.isEmpty {
                usesRemoteRestaurants = true
                restaurants = remoteRestaurants
            }
        } catch {
            // Keep mock restaurant data if the live endpoint fails.
        }
    }

    func loadHomeDiscover(accessToken: String) async {
        homeErrorMessage = nil

        do {
            let response = try await authClient.fetchHomeDiscover(accessToken: accessToken)
            usesRemoteHomeDiscover = true
            if !response.hero_banners.isEmpty {
                homeHeroBanners = response.hero_banners.enumerated().map { index, banner in
                    banner.appBanner(index: index)
                }
            }
            if !response.primary_categories.isEmpty {
                homePrimaryServices = response.primary_categories.map { $0.appPrimaryService() }
            }
            if !response.mini_services.isEmpty {
                homeMiniServices = response.mini_services.map { $0.appMiniService() }
            }
            mergeRemoteVendors(response.featured_vendors.map(\.appVendor))
        } catch {
            homeErrorMessage = error.localizedDescription
        }
    }

    func loadFavorites(accessToken: String) async {
        favoritesErrorMessage = nil

        do {
            let response = try await authClient.fetchFavorites(accessToken: accessToken)
            let favoriteVendors = response.data.map(\.appVendor)
            mergeRemoteVendors(favoriteVendors)
            applyFavoriteVendorIDs(Set(response.data.map(\.vendor_id)))
        } catch {
            favoritesErrorMessage = error.localizedDescription
        }
    }

    func loadOrders(accessToken: String) async {
        ordersErrorMessage = nil

        do {
            let response = try await authClient.fetchOrders(accessToken: accessToken)
            usesRemoteOrders = true
            let mappedOrders = response.data.map(\.appOrder)
            activeOrder = mappedOrders.first(where: \.isActive)
            pastOrders = mappedOrders.filter { !$0.isActive }
        } catch {
            ordersErrorMessage = error.localizedDescription
        }
    }

    func refreshVendorDetailIfNeeded(for vendor: Vendor) async -> Vendor {
        guard vendor.menuSections.isEmpty, let backendID = vendor.backendID else {
            return vendor
        }

        do {
            let detailedVendor = try await vendorsClient.fetchVendorDetail(vendorID: backendID)
            if let index = restaurants.firstIndex(where: { $0.id == vendor.id }) {
                restaurants[index] = detailedVendor
            }
            return detailedVendor
        } catch {
            return vendor
        }
    }

    func refreshOrderDetailIfNeeded(for order: Order, accessToken: String?) async -> Order {
        guard let accessToken, let backendID = order.backendID else {
            return order
        }

        do {
            let detail = try await authClient.fetchOrderDetail(accessToken: accessToken, id: backendID)
            let detailedOrder = detail.merged(into: order)
            if let index = pastOrders.firstIndex(where: { $0.id == order.id }) {
                pastOrders[index] = detailedOrder
            } else if activeOrder?.id == order.id {
                activeOrder = detailedOrder
            }
            return detailedOrder
        } catch {
            return order
        }
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

    func toggleFavorite(for vendor: Vendor, accessToken: String?) async {
        guard let backendID = vendor.backendID, let accessToken else {
            repository.toggleFavorite(for: vendor)
            refreshState()
            return
        }

        let currentIsFavorite = allVendors.first(where: { $0.id == vendor.id })?.isFavorite ?? vendor.isFavorite
        setFavoriteState(forBackendID: backendID, isFavorite: !currentIsFavorite)
        favoritesErrorMessage = nil

        do {
            if currentIsFavorite {
                try await authClient.removeFavorite(accessToken: accessToken, vendorID: backendID)
            } else {
                try await authClient.addFavorite(accessToken: accessToken, vendorID: backendID)
            }
            await loadFavorites(accessToken: accessToken)
        } catch {
            setFavoriteState(forBackendID: backendID, isFavorite: currentIsFavorite)
            favoritesErrorMessage = error.localizedDescription
        }
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
        if !usesRemoteRestaurants {
            restaurants = repository.restaurants
        }
        markets = repository.markets
        if !usesRemoteHomeDiscover {
            activeOrder = repository.activeOrder
        }
        if !usesRemoteOrders {
            pastOrders = repository.pastOrders
        }
        cartItems = repository.cartItems
        if !usesRemoteUserProfile {
            selectedAddress = repository.selectedAddress
            userProfile = repository.userProfile
        }
    }

    private func mergeRemoteVendors(_ incoming: [Vendor]) {
        guard !incoming.isEmpty else { return }

        var updatedRestaurants = restaurants

        for vendor in incoming {
            if let backendID = vendor.backendID,
               let index = updatedRestaurants.firstIndex(where: { $0.backendID == backendID }) {
                let existing = updatedRestaurants[index]
                updatedRestaurants[index] = Vendor(
                    backendID: existing.backendID ?? vendor.backendID,
                    name: vendor.name,
                    summary: vendor.summary,
                    kind: vendor.kind,
                    eta: vendor.eta,
                    rating: vendor.rating == 0 ? existing.rating : vendor.rating,
                    reviewCount: vendor.reviewCount == 0 ? existing.reviewCount : vendor.reviewCount,
                    minimumBasket: existing.minimumBasket,
                    deliveryFee: vendor.deliveryFee == 0 ? existing.deliveryFee : vendor.deliveryFee,
                    coverNote: vendor.coverNote,
                    promoText: vendor.promoText,
                    tags: vendor.tags.isEmpty ? existing.tags : vendor.tags,
                    theme: existing.theme,
                    isFavorite: existing.isFavorite,
                    menuSections: existing.menuSections.isEmpty ? vendor.menuSections : existing.menuSections
                )
            } else {
                updatedRestaurants.append(vendor)
            }
        }

        restaurants = updatedRestaurants
    }

    private func applyFavoriteVendorIDs(_ ids: Set<String>) {
        restaurants = restaurants.map { vendor in
            guard let backendID = vendor.backendID else { return vendor }
            return Vendor(
                backendID: vendor.backendID,
                name: vendor.name,
                summary: vendor.summary,
                kind: vendor.kind,
                eta: vendor.eta,
                rating: vendor.rating,
                reviewCount: vendor.reviewCount,
                minimumBasket: vendor.minimumBasket,
                deliveryFee: vendor.deliveryFee,
                coverNote: vendor.coverNote,
                promoText: vendor.promoText,
                tags: vendor.tags,
                theme: vendor.theme,
                isFavorite: ids.contains(backendID),
                menuSections: vendor.menuSections
            )
        }
    }

    private func setFavoriteState(forBackendID backendID: String, isFavorite: Bool) {
        restaurants = restaurants.map { vendor in
            guard vendor.backendID == backendID else { return vendor }
            return Vendor(
                backendID: vendor.backendID,
                name: vendor.name,
                summary: vendor.summary,
                kind: vendor.kind,
                eta: vendor.eta,
                rating: vendor.rating,
                reviewCount: vendor.reviewCount,
                minimumBasket: vendor.minimumBasket,
                deliveryFee: vendor.deliveryFee,
                coverNote: vendor.coverNote,
                promoText: vendor.promoText,
                tags: vendor.tags,
                theme: vendor.theme,
                isFavorite: isFavorite,
                menuSections: vendor.menuSections
            )
        }
    }
}

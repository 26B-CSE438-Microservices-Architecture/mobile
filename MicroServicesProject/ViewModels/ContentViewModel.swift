import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var searchText: String = ""
    @Published var restaurants: [Vendor] = MockData.restaurants
    @Published var markets: [Vendor] = MockData.markets
    @Published var activeOrder: Order? = MockData.activeOrder
    @Published var pastOrders: [Order] = MockData.pastOrders
    @Published var cartItems: [CartItem] = MockData.activeOrder.items

    let shortcuts = MockData.shortcuts
    let campaigns = MockData.campaigns
    let userProfile = MockData.userProfile
    let homeSearchSuggestions = MockData.homeSearchSuggestions
    let homePrimaryServices = MockData.homePrimaryServices
    let homeMiniServices = MockData.homeMiniServices
    let homeCuisines = MockData.homeCuisines
    let homeQuickFilters = MockData.homeQuickFilters
    let homeHeroBanners = MockData.homeHeroBanners
    let homeRewardsOverview = MockData.homeRewardsOverview
    let homePersonalRestaurants = MockData.homePersonalRestaurants
    let homeCampaignRestaurants = MockData.homeCampaignRestaurants
    let homeMarkets = MockData.homeMarkets
    let homeOpportunities = MockData.homeOpportunities

    var allVendors: [Vendor] {
        restaurants + markets
    }

    @Published var selectedAddress: Address = MockData.userProfile.addresses.first(where: { $0.isCurrent }) ?? MockData.userProfile.addresses[0]

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

    var searchResults: [Vendor] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        return allVendors.filter { vendor in
            vendor.name.localizedCaseInsensitiveContains(query) ||
            vendor.summary.localizedCaseInsensitiveContains(query) ||
            vendor.tags.contains(where: { $0.localizedCaseInsensitiveContains(query) }) ||
            vendor.menuSections.contains { section in
                section.products.contains { product in
                    product.name.localizedCaseInsensitiveContains(query) ||
                    product.description.localizedCaseInsensitiveContains(query)
                }
            }
        }
    }

    func selectAddress(_ address: Address) {
        selectedAddress = address
        selectedTab = .home
    }

    func addToCart(product: Product, from vendor: Vendor, selectedOptions: [String] = [], note: String = "", quantity: Int = 1) {
        guard quantity > 0 else { return }

        if let currentVendorID = cartItems.first?.vendorID, currentVendorID != vendor.id {
            cartItems.removeAll()
        }

        if let index = cartItems.firstIndex(where: {
            $0.product.id == product.id &&
            $0.vendorID == vendor.id &&
            $0.selectedOptions == selectedOptions &&
            $0.note == note
        }) {
            cartItems[index].quantity += quantity
            return
        }

        let item = CartItem(
            product: product,
            vendorID: vendor.id,
            vendorName: vendor.name,
            selectedOptions: selectedOptions,
            note: note,
            quantity: quantity
        )
        cartItems.append(item)
    }

    func incrementQuantity(for item: CartItem) {
        guard let index = cartItems.firstIndex(where: { $0.id == item.id }) else { return }
        cartItems[index].quantity += 1
    }

    func decrementQuantity(for item: CartItem) {
        guard let index = cartItems.firstIndex(where: { $0.id == item.id }) else { return }

        if cartItems[index].quantity == 1 {
            cartItems.remove(at: index)
        } else {
            cartItems[index].quantity -= 1
        }
    }

    func toggleFavorite(for vendor: Vendor) {
        if let index = restaurants.firstIndex(where: { $0.id == vendor.id }) {
            restaurants[index].isFavorite.toggle()
            return
        }

        if let index = markets.firstIndex(where: { $0.id == vendor.id }) {
            markets[index].isFavorite.toggle()
        }
    }

    func reorder(_ order: Order) {
        cartItems = order.items
        selectedTab = .home
    }

    func placeOrder() {
        guard !cartItems.isEmpty else { return }

        if let currentActive = activeOrder {
            let archivedActive = Order(
                vendorName: currentActive.vendorName,
                items: currentActive.items,
                total: currentActive.total,
                dateLabel: currentActive.dateLabel,
                statusLabel: "Teslim edildi",
                addressLine: currentActive.addressLine,
                etaRange: currentActive.etaRange,
                campaignNote: currentActive.campaignNote,
                courier: nil,
                steps: currentActive.steps,
                activeStep: currentActive.steps.count - 1,
                isActive: false
            )
            pastOrders.insert(archivedActive, at: 0)
        }

        let createdOrder = Order(
            vendorName: cartVendorName ?? "Sipariş",
            items: cartItems,
            total: cartTotal,
            dateLabel: "Bugün, 13:24",
            statusLabel: "Sipariş alındı",
            addressLine: "\(selectedAddress.line1), \(selectedAddress.detail)",
            etaRange: "20-30 dk",
            campaignNote: cartDiscount > 0 ? "40 TL sepet indirimi uygulandı" : "Standart teslimat",
            courier: Courier(
                name: "Kurye Atanıyor",
                vehicle: "Motosiklet",
                plate: "--",
                phone: "+90 555 000 00 00",
                etaNote: "Hazırlık tamamlandığında kurye bilgisi güncellenecek"
            ),
            steps: [
                OrderStep(title: "Sipariş alındı", detail: "Restorana iletildi", symbol: "checkmark.circle.fill"),
                OrderStep(title: "Hazırlanıyor", detail: "Ürünler hazırlanıyor", symbol: "bag.fill"),
                OrderStep(title: "Kurye yolda", detail: "Kurye teslim alacak", symbol: "bicycle.circle.fill"),
                OrderStep(title: "Teslim edildi", detail: "Teslim sonrası burada göreceksin", symbol: "house.fill")
            ],
            activeStep: 0,
            isActive: true
        )

        activeOrder = createdOrder
        cartItems.removeAll()
        selectedTab = .orders
    }
}

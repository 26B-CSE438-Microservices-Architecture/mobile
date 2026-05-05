import Foundation

protocol AppRepository {
    var restaurants: [Vendor] { get }
    var markets: [Vendor] { get }
    var activeOrder: Order? { get }
    var pastOrders: [Order] { get }
    var cartItems: [CartItem] { get }
    var selectedAddress: Address { get }

    var shortcuts: [CategoryShortcut] { get }
    var campaigns: [Campaign] { get }
    var userProfile: UserProfile { get }
    var homeSearchSuggestions: [String] { get }
    var homePrimaryServices: [HomePrimaryService] { get }
    var homeMiniServices: [HomeMiniService] { get }
    var homeCuisines: [HomeCuisine] { get }
    var homeQuickFilters: [HomeQuickFilter] { get }
    var homeHeroBanners: [HomeHeroBanner] { get }
    var homeRewardsOverview: HomeRewardsOverview { get }
    var homePersonalRestaurants: [HomeRestaurantSpotlight] { get }
    var homeCampaignRestaurants: [HomeRestaurantSpotlight] { get }
    var homeMarkets: [HomeMarketSpotlight] { get }
    var homeOpportunities: [HomeOpportunitySpotlight] { get }

    func selectAddress(_ address: Address)
    func addToCart(product: Product, from vendor: Vendor, selectedOptions: [String], note: String, quantity: Int)
    func incrementQuantity(for item: CartItem)
    func decrementQuantity(for item: CartItem)
    func toggleFavorite(for vendor: Vendor)
    func reorder(_ order: Order)
    func placeOrder(total: Double, campaignNote: String, addressLine: String, vendorName: String)
}

final class MockAppRepository: AppRepository {
    private var storedRestaurants: [Vendor] = MockData.restaurants
    private var storedMarkets: [Vendor] = MockData.markets
    private var storedActiveOrder: Order? = MockData.activeOrder
    private var storedPastOrders: [Order] = MockData.pastOrders
    private var storedCartItems: [CartItem] = []
    private var storedSelectedAddress: Address = MockData.userProfile.addresses.first(where: { $0.isCurrent }) ?? MockData.userProfile.addresses[0]

    var restaurants: [Vendor] { storedRestaurants }
    var markets: [Vendor] { storedMarkets }
    var activeOrder: Order? { storedActiveOrder }
    var pastOrders: [Order] { storedPastOrders }
    var cartItems: [CartItem] { storedCartItems }
    var selectedAddress: Address { storedSelectedAddress }

    let shortcuts: [CategoryShortcut] = MockData.shortcuts
    let campaigns: [Campaign] = MockData.campaigns
    let userProfile: UserProfile = MockData.userProfile
    let homeSearchSuggestions: [String] = MockData.homeSearchSuggestions
    let homePrimaryServices: [HomePrimaryService] = MockData.homePrimaryServices
    let homeMiniServices: [HomeMiniService] = MockData.homeMiniServices
    let homeCuisines: [HomeCuisine] = MockData.homeCuisines
    let homeQuickFilters: [HomeQuickFilter] = MockData.homeQuickFilters
    let homeHeroBanners: [HomeHeroBanner] = MockData.homeHeroBanners
    let homeRewardsOverview: HomeRewardsOverview = MockData.homeRewardsOverview
    let homePersonalRestaurants: [HomeRestaurantSpotlight] = MockData.homePersonalRestaurants
    let homeCampaignRestaurants: [HomeRestaurantSpotlight] = MockData.homeCampaignRestaurants
    let homeMarkets: [HomeMarketSpotlight] = MockData.homeMarkets
    let homeOpportunities: [HomeOpportunitySpotlight] = MockData.homeOpportunities

    func selectAddress(_ address: Address) {
        storedSelectedAddress = address
    }

    func addToCart(product: Product, from vendor: Vendor, selectedOptions: [String], note: String, quantity: Int) {
        guard quantity > 0 else { return }

        if let currentVendorID = storedCartItems.first?.vendorID, currentVendorID != vendor.id {
            storedCartItems.removeAll()
        }

        if let index = storedCartItems.firstIndex(where: {
            $0.product.id == product.id &&
            $0.vendorID == vendor.id &&
            $0.selectedOptions == selectedOptions &&
            $0.note == note
        }) {
            storedCartItems[index].quantity += quantity
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
        storedCartItems.append(item)
    }

    func incrementQuantity(for item: CartItem) {
        guard let index = storedCartItems.firstIndex(where: { $0.id == item.id }) else { return }
        storedCartItems[index].quantity += 1
    }

    func decrementQuantity(for item: CartItem) {
        guard let index = storedCartItems.firstIndex(where: { $0.id == item.id }) else { return }
        if storedCartItems[index].quantity == 1 {
            storedCartItems.remove(at: index)
        } else {
            storedCartItems[index].quantity -= 1
        }
    }

    func toggleFavorite(for vendor: Vendor) {
        if let index = storedRestaurants.firstIndex(where: { $0.id == vendor.id }) {
            storedRestaurants[index].isFavorite.toggle()
            return
        }

        if let index = storedMarkets.firstIndex(where: { $0.id == vendor.id }) {
            storedMarkets[index].isFavorite.toggle()
        }
    }

    func reorder(_ order: Order) {
        storedCartItems = order.items
    }

    func placeOrder(total: Double, campaignNote: String, addressLine: String, vendorName: String) {
        guard !storedCartItems.isEmpty else { return }

        if let currentActive = storedActiveOrder {
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
            storedPastOrders.insert(archivedActive, at: 0)
        }

        let createdOrder = Order(
            vendorName: vendorName,
            items: storedCartItems,
            total: total,
            dateLabel: "Bugün, 13:24",
            statusLabel: "Sipariş alındı",
            addressLine: addressLine,
            etaRange: "20-30 dk",
            campaignNote: campaignNote,
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

        storedActiveOrder = createdOrder
        storedCartItems.removeAll()
    }
}

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
    @Published private(set) var nearbyVendors: [Vendor] = []
    @Published private(set) var liveCampaigns: [Campaign] = []
    @Published private(set) var gatewayHealthStatus: String?
    @Published private(set) var gatewayInfoVersion: String?
    @Published private(set) var isLoadingRemoteRestaurants = false
    @Published private(set) var homeErrorMessage: String?
    @Published private(set) var favoritesErrorMessage: String?
    @Published private(set) var ordersErrorMessage: String?
    @Published private(set) var cartErrorMessage: String?

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
    private var usesRemoteCart = false
    private(set) var remoteAccessToken: String?
    private let strictProdMode = true

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

    func loadNearbyVendors() async {
        do {
            let lat = selectedAddress.latitude ?? 36.8969
            let lng = selectedAddress.longitude ?? 30.7133
            let response = try await authClient.fetchNearbyVendors(lat: lat, lng: lng)
            nearbyVendors = (response.data ?? []).map(\.appVendor)
        } catch {
            nearbyVendors = []
        }
    }

    func loadCampaigns() async {
        do {
            let response = try await authClient.fetchCampaigns(page: 1, limit: 20)
            liveCampaigns = (response.data ?? []).map(\.appCampaign)
        } catch {
            liveCampaigns = []
        }
    }

    func loadGatewayMeta() async {
        do {
            let health = try await authClient.fetchGatewayHealth()
            gatewayHealthStatus = health.status ?? "unknown"
        } catch {
            gatewayHealthStatus = "unavailable"
        }

        do {
            let info = try await authClient.fetchGatewayInfo()
            gatewayInfoVersion = info.version
        } catch {
            gatewayInfoVersion = nil
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
        remoteAccessToken = accessToken
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
        if strictProdMode, let token = remoteAccessToken, let backendID = product.backendID {
            print("[CartFlow] addToCart remote mode vendor=\(vendor.name) product=\(product.name) backendID=\(backendID) quantity=\(quantity)")
            Task {
                do {
                    try await authClient.addCartItem(accessToken: token, productID: backendID, restaurantID: vendor.backendID, quantity: quantity)
                    await loadCart(accessToken: token)
                } catch {
                    await MainActor.run {
                        print("[CartFlow] addToCart failed: \(error.localizedDescription)")
                        cartErrorMessage = error.localizedDescription
                    }
                }
            }
            return
        }

        repository.addToCart(
            product: product,
            from: vendor,
            selectedOptions: selectedOptions,
            note: note,
            quantity: quantity
        )
        refreshState()

        if let token = remoteAccessToken, let backendID = product.backendID {
            Task {
                do {
                    try await authClient.addCartItem(accessToken: token, productID: backendID, restaurantID: vendor.backendID, quantity: quantity)
                    await loadCart(accessToken: token)
                } catch {
                    await MainActor.run {
                        cartErrorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func incrementQuantity(for item: CartItem) {
        if strictProdMode, remoteAccessToken != nil {
            let currentQuantity = cartItems.first(where: { $0.id == item.id })?.quantity ?? item.quantity
            let target = currentQuantity + 1
            updateRemoteCartItem(item, quantity: target)
            return
        }
        repository.incrementQuantity(for: item)
        refreshState()
        syncCartItemQuantityToRemote(item)
    }

    func decrementQuantity(for item: CartItem) {
        if strictProdMode, remoteAccessToken != nil {
            let currentQuantity = cartItems.first(where: { $0.id == item.id })?.quantity ?? item.quantity
            let target = max(0, currentQuantity - 1)
            updateRemoteCartItem(item, quantity: target)
            return
        }
        repository.decrementQuantity(for: item)
        refreshState()
        syncCartItemQuantityToRemote(item)
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
        if let token = remoteAccessToken, let backendID = order.backendID {
            Task {
                do {
                    _ = try await authClient.reorderOrder(accessToken: token, id: backendID)
                    await loadCart(accessToken: token)
                    await MainActor.run { onTabChange?(.home) }
                } catch {
                    await MainActor.run {
                        ordersErrorMessage = error.localizedDescription
                        if !strictProdMode {
                            repository.reorder(order)
                            refreshState()
                            onTabChange?(.home)
                        }
                    }
                }
            }
            return
        }

        repository.reorder(order)
        refreshState()
        onTabChange?(.home)
    }

    func placeOrder() {
        guard !cartItems.isEmpty else { return }

        if let token = remoteAccessToken {
            Task {
                do {
                    _ = try await authClient.checkoutCart(accessToken: token)
                    try? await authClient.clearCart(accessToken: token)
                    await loadCart(accessToken: token)
                    await loadOrders(accessToken: token)
                    await MainActor.run { onTabChange?(.orders) }
                } catch {
                    await MainActor.run {
                        cartErrorMessage = error.localizedDescription
                    }
                }
            }
            return
        }

        repository.placeOrder(
            total: cartTotal,
            campaignNote: cartDiscount > 0 ? "40 TL sepet indirimi uygulandı" : "Standart teslimat",
            addressLine: "\(selectedAddress.line1), \(selectedAddress.detail)",
            vendorName: cartVendorName ?? "Sipariş"
        )
        refreshState()
        onTabChange?(.orders)
    }

    func loadCart(accessToken: String) async {
        remoteAccessToken = accessToken
        cartErrorMessage = nil
        print("[CartFlow] loadCart started")

        do {
            let response = try await authClient.fetchCart(accessToken: accessToken)
            usesRemoteCart = true
            
            let enrichedItems = response.appCartItems.map { remoteItem -> CartItem in
                guard let productID = remoteItem.product.backendID else { return remoteItem }
                
                // 1. First try to find it in our current local cart (which was loaded from UserDefaults)
                if let existingItem = self.cartItems.first(where: { $0.product.backendID == productID }) {
                    return CartItem(
                        product: existingItem.product,
                        vendorID: existingItem.vendorID,
                        vendorName: existingItem.vendorName,
                        selectedOptions: remoteItem.selectedOptions,
                        note: remoteItem.note,
                        quantity: remoteItem.quantity
                    )
                }
                
                // 2. Then try to find it in the loaded menu catalog
                for vendor in allVendors {
                    for section in vendor.menuSections {
                        if let matchedProduct = section.products.first(where: { $0.backendID == productID }) {
                            return CartItem(
                                product: matchedProduct,
                                vendorID: vendor.id,
                                vendorName: vendor.name,
                                selectedOptions: remoteItem.selectedOptions,
                                note: remoteItem.note,
                                quantity: remoteItem.quantity
                            )
                        }
                    }
                }
                return remoteItem
            }
            
            cartItems = enrichedItems
            print("[CartFlow] loadCart success itemCount=\(enrichedItems.count)")
        } catch {
            usesRemoteCart = true
            cartItems = []
            cartErrorMessage = error.localizedDescription
            print("[CartFlow] loadCart failed: \(error.localizedDescription)")
        }
    }

    func cancelOrder(_ order: Order, accessToken: String) async {
        guard canCancel(order: order) else {
            ordersErrorMessage = "Bu sipariş mevcut durumunda iptal edilemez."
            return
        }
        guard let backendID = order.backendID else { return }

        do {
            _ = try await authClient.cancelOrder(accessToken: accessToken, id: backendID)
            await loadOrders(accessToken: accessToken)
        } catch {
            ordersErrorMessage = error.localizedDescription
        }
    }

    func requestRefund(_ order: Order, accessToken: String) async {
        guard canRequestRefund(order: order) else {
            ordersErrorMessage = "Bu sipariş için iade talebi açılamaz."
            return
        }
        guard let backendID = order.backendID else { return }

        do {
            _ = try await authClient.requestRefund(accessToken: accessToken, id: backendID)
            await loadOrders(accessToken: accessToken)
        } catch {
            ordersErrorMessage = error.localizedDescription
        }
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
        if !usesRemoteCart {
            cartItems = repository.cartItems
        }
        if !usesRemoteUserProfile {
            selectedAddress = repository.selectedAddress
            userProfile = repository.userProfile
        }
    }

    private func syncCartItemQuantityToRemote(_ item: CartItem) {
        guard let token = remoteAccessToken, let productID = item.product.backendID else {
            return
        }

        let updatedQuantity = cartItems.first(where: { $0.id == item.id })?.quantity ?? 0
        print("[CartFlow] syncCartItemQuantityToRemote productID=\(productID) quantity=\(updatedQuantity)")
        Task {
            do {
                if updatedQuantity <= 0 {
                    try await authClient.deleteCartItem(accessToken: token, productID: productID)
                } else {
                    try await authClient.updateCartItem(accessToken: token, productID: productID, quantity: updatedQuantity)
                }
                await loadCart(accessToken: token)
            } catch {
                await MainActor.run {
                    print("[CartFlow] syncCartItemQuantityToRemote failed: \(error.localizedDescription)")
                    cartErrorMessage = error.localizedDescription
                }
            }
        }
    }

    func canCancel(order: Order) -> Bool {
        let code = normalizedStatus(order.statusCode)
        if ["DELIVERED", "CANCELLED", "REJECTED", "REFUNDED", "REFUND_COMPLETED"].contains(code) {
            return false
        }
        if ["PENDING", "RECEIVED", "PENDING_PAYMENT", "HOLD_PENDING", "HOLD_CONFIRMED", "CONFIRMED", "PREPARING"].contains(code) {
            return true
        }

        let label = order.statusLabel.lowercased()
        if label.contains("teslim") || label.contains("iptal") || label.contains("redd") || label.contains("iade") {
            return false
        }
        if label.contains("alındı") || label.contains("hazırl") || label.contains("onay") {
            return true
        }
        return false
    }

    func canRequestRefund(order: Order) -> Bool {
        let code = normalizedStatus(order.statusCode)
        if ["DELIVERED", "PAID", "COMPLETED"].contains(code) {
            return true
        }
        if ["REFUNDED", "REFUND_COMPLETED", "CANCELLED", "REJECTED"].contains(code) {
            return false
        }

        let label = order.statusLabel.lowercased()
        if label.contains("teslim") {
            return true
        }
        if label.contains("iptal") || label.contains("iade") || label.contains("redd") {
            return false
        }
        return false
    }

    private func normalizedStatus(_ status: String?) -> String {
        (status ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .uppercased()
    }

    private func updateRemoteCartItem(_ item: CartItem, quantity: Int) {
        guard let token = remoteAccessToken, let productID = item.product.backendID else {
            return
        }
        Task {
            do {
                if quantity <= 0 {
                    try await authClient.deleteCartItem(accessToken: token, productID: productID)
                } else {
                    try await authClient.updateCartItem(accessToken: token, productID: productID, quantity: quantity)
                }
                await loadCart(accessToken: token)
            } catch {
                await MainActor.run {
                    cartErrorMessage = error.localizedDescription
                }
            }
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

import Foundation

struct FavoritesListResponse: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let data: [FavoriteVendorResponse]
}

struct FavoriteVendorResponse: Decodable {
    let vendor_id: String
    let name: String
    let image_url: String?
}

struct HomeDiscoverResponse: Decodable {
    struct ActiveOrderResponse: Decodable {
        let id: String
        let vendor_name: String
        let status: String?
        let status_label: String?
    }

    struct BannerResponse: Decodable {
        let id: String
        let title: String
        let subtitle: String?
        let image_url: String?
    }

    struct CategoryResponse: Decodable {
        let id: String
        let name: String
        let icon_url: String?
    }

    struct FeaturedVendorResponse: Decodable {
        let id: String
        let name: String
        let rating: Double?
        let review_count: Int?
        let eta: String?
        let delivery_fee: Double?
        let image_url: String?
    }

    let active_order: ActiveOrderResponse?
    let hero_banners: [BannerResponse]
    let primary_categories: [CategoryResponse]
    let mini_services: [CategoryResponse]
    let featured_vendors: [FeaturedVendorResponse]
}

struct OrdersListResponse: Decodable {
    let page: Int
    let size: Int
    let total: Int
    let data: [OrderSummaryResponse]
}

struct OrderAddressSnapshotResponse: Decodable {
    let address_title: String?
    let city: String?
    let district: String?
    let neighborhood: String?
    let street: String?
    let building_no: String?
    let floor: String?
    let apartment_no: String?
    let address_description: String?
}

struct OrderSummaryResponse: Decodable {
    let id: String
    let vendor_name: String?
    let vendorName: String?
    let status: String?
    let status_label: String?
    let total_amount: Double?
    let total_price: Double?
    let date_label: String?
    let address_snapshot: OrderAddressSnapshotResponse?
    let item_summary: String?
    let delivered_item_count: Int?
}

struct OrderDetailResponse: Decodable {
    struct StepResponse: Decodable {
        let title: String?
        let is_completed: Bool?
    }

    struct ItemResponse: Decodable {
        let product_name: String?
        let name: String?
        let quantity: Int?
        let unit_price: Double?
        let price: Double?
    }

    let id: String
    let vendor_name: String?
    let status: String?
    let status_label: String?
    let eta_range: String?
    let active_step_index: Int?
    let address_snapshot: OrderAddressSnapshotResponse?
    let steps: [StepResponse]?
    let items: [ItemResponse]?
    let total_amount: Double?
    let total_price: Double?
}

extension FavoriteVendorResponse {
    var appVendor: Vendor {
        makeLightweightVendor(
            backendID: vendor_id,
            name: name,
            summary: "Favoriler canlı servisten geliyor",
            eta: "20-30 dk",
            rating: 0,
            reviewCount: 0,
            deliveryFee: 0,
            promoText: "Favori restoran"
        )
    }
}

extension HomeDiscoverResponse.BannerResponse {
    func appBanner(index: Int) -> HomeHeroBanner {
        HomeHeroBanner(
            style: index.isMultiple(of: 2) ? .flashDiscount : .uberOne,
            title: title,
            subtitle: subtitle ?? "Canlı kampanya",
            detail: image_url ?? "Gateway / Home Discover",
            ctaText: "İncele"
        )
    }
}

extension HomeDiscoverResponse.CategoryResponse {
    func appPrimaryService() -> HomePrimaryService {
        let lowercasedName = name.lowercased()
        let serviceStyle: HomePrimaryServiceStyle
        let artwork: HomeArtwork
        let subtitle: String

        if id == "food" || lowercasedName.contains("yemek") {
            serviceStyle = .food
            artwork = .burger
            subtitle = "Canlı restoranlar ve menüler"
        } else if id == "water" || lowercasedName.contains("su") {
            serviceStyle = .water
            artwork = .water
            subtitle = "Hızlı içecek teslimatı"
        } else {
            serviceStyle = .quickMarket
            artwork = .grocery
            subtitle = "Market ürünleri kapında"
        }

        return HomePrimaryService(
            title: name,
            subtitle: subtitle,
            style: serviceStyle,
            artwork: artwork,
            imageURL: icon_url ?? ""
        )
    }

    func appMiniService() -> HomeMiniService {
        let lowercasedName = name.lowercased()
        let artwork: HomeArtwork

        if lowercasedName.contains("pet") {
            artwork = .petShop
        } else if lowercasedName.contains("çiçek") || lowercasedName.contains("cicek") || lowercasedName.contains("flower") {
            artwork = .flowers
        } else {
            artwork = .produce
        }

        return HomeMiniService(
            title: name,
            badgeText: "canlı",
            artwork: artwork,
            imageURL: icon_url ?? ""
        )
    }
}

extension HomeDiscoverResponse.FeaturedVendorResponse {
    var appVendor: Vendor {
        makeLightweightVendor(
            backendID: id,
            name: name,
            summary: "Home discover canlı öneri",
            eta: eta ?? "20-30 dk",
            rating: rating ?? 0,
            reviewCount: review_count ?? 0,
            deliveryFee: delivery_fee ?? 0,
            promoText: "Öne çıkan restoran"
        )
    }
}

extension HomeDiscoverResponse.ActiveOrderResponse {
    var appOrder: Order {
        Order(
            backendID: id,
            vendorName: vendor_name,
            items: [],
            total: 0,
            dateLabel: "Aktif sipariş",
            statusLabel: status_label ?? status ?? "Sipariş hazırlanıyor",
            addressLine: "Teslimat adresi detay ekranında güncellenecek",
            etaRange: "Canlı takip",
            campaignNote: "Home discover aktif sipariş özeti",
            courier: nil,
            steps: defaultSteps(for: status),
            activeStep: defaultActiveStep(for: status),
            isActive: true,
            itemSummary: nil,
            deliveredItemCount: 0,
            showsRatingAction: false
        )
    }
}

extension OrderSummaryResponse {
    var appOrder: Order {
        Order(
            backendID: id,
            vendorName: vendor_name ?? vendorName ?? "Sipariş",
            items: [],
            total: total_amount ?? total_price ?? 0,
            dateLabel: date_label ?? "Geçmiş sipariş",
            statusLabel: status_label ?? prettifiedStatus(status) ?? "Sipariş",
            addressLine: address_snapshot?.addressLine ?? "Adres bilgisi yok",
            etaRange: date_label ?? "Detay ekranda",
            campaignNote: "Geçmiş sipariş",
            courier: nil,
            steps: defaultSteps(for: status),
            activeStep: defaultActiveStep(for: status),
            isActive: (status ?? "").uppercased() != "DELIVERED",
            itemSummary: item_summary,
            deliveredItemCount: delivered_item_count ?? 0,
            showsRatingAction: (status ?? "").uppercased() == "DELIVERED"
        )
    }
}

extension OrderDetailResponse {
    func merged(into baseOrder: Order) -> Order {
        Order(
            backendID: id,
            vendorName: vendor_name ?? baseOrder.vendorName,
            items: mappedItems ?? baseOrder.items,
            total: total_amount ?? total_price ?? baseOrder.total,
            dateLabel: baseOrder.dateLabel,
            statusLabel: status_label ?? prettifiedStatus(status) ?? baseOrder.statusLabel,
            addressLine: address_snapshot?.addressLine ?? baseOrder.addressLine,
            etaRange: eta_range ?? baseOrder.etaRange,
            campaignNote: baseOrder.campaignNote,
            courier: baseOrder.courier,
            steps: mappedSteps ?? baseOrder.steps,
            activeStep: active_step_index ?? baseOrder.activeStep,
            isActive: baseOrder.isActive,
            kind: baseOrder.kind,
            itemSummary: baseOrder.itemSummary,
            deliveredItemCount: baseOrder.deliveredItemCount,
            showsRatingAction: baseOrder.showsRatingAction,
            previewThumbnails: baseOrder.previewThumbnails
        )
    }

    private var mappedSteps: [OrderStep]? {
        guard let steps, !steps.isEmpty else { return nil }

        return steps.enumerated().map { index, step in
            let title = step.title ?? "Adım \(index + 1)"
            return OrderStep(
                title: title,
                detail: step.is_completed == true ? "Tamamlandı" : "Bekleniyor",
                symbol: symbol(for: title)
            )
        }
    }

    private var mappedItems: [CartItem]? {
        guard let items, !items.isEmpty else { return nil }

        return items.enumerated().map { index, item in
            let name = item.product_name ?? item.name ?? "Ürün \(index + 1)"
            let unitPrice = item.unit_price ?? item.price ?? 0
            let product = Product(
                name: name,
                description: "Canlı sipariş detayı",
                price: unitPrice,
                badge: nil,
                systemImage: "fork.knife",
                theme: .orange,
                optionGroups: []
            )

            return CartItem(
                product: product,
                vendorID: UUID(),
                vendorName: vendor_name ?? "Sipariş",
                selectedOptions: [],
                note: "",
                quantity: item.quantity ?? 1
            )
        }
    }
}

extension OrderAddressSnapshotResponse {
    var addressLine: String {
        [
            address_title,
            city,
            district,
            neighborhood,
            street,
            building_no.map { "No:\($0)" }
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }
}

private func makeLightweightVendor(
    backendID: String,
    name: String,
    summary: String,
    eta: String,
    rating: Double,
    reviewCount: Int,
    deliveryFee: Double,
    promoText: String
) -> Vendor {
    let theme: VendorTheme = name.lowercased().contains("pizza") ? .red : .orange

    return Vendor(
        backendID: backendID,
        name: name,
        summary: summary,
        kind: .restaurant,
        eta: eta,
        rating: rating,
        reviewCount: reviewCount,
        minimumBasket: 0,
        deliveryFee: deliveryFee,
        coverNote: "Canlı gateway verisi",
        promoText: promoText,
        tags: [eta],
        theme: theme,
        isFavorite: false,
        menuSections: []
    )
}

private func defaultSteps(for status: String?) -> [OrderStep] {
    let normalized = (status ?? "").uppercased()

    if normalized == "DELIVERING" {
        return [
            OrderStep(title: "Sipariş alındı", detail: "Siparişin sisteme düştü", symbol: "checkmark.circle.fill"),
            OrderStep(title: "Hazırlanıyor", detail: "Restoran siparişi hazırlıyor", symbol: "bag.fill"),
            OrderStep(title: "Kurye yolda", detail: "Kurye siparişi teslim ediyor", symbol: "bicycle.circle.fill"),
            OrderStep(title: "Teslim edildi", detail: "Sipariş teslim edildiğinde tamamlanır", symbol: "house.fill")
        ]
    }

    if normalized == "DELIVERED" {
        return [
            OrderStep(title: "Sipariş alındı", detail: "Sipariş sisteme düştü", symbol: "checkmark.circle.fill"),
            OrderStep(title: "Hazırlanıyor", detail: "Sipariş hazırlandı", symbol: "bag.fill"),
            OrderStep(title: "Kurye yolda", detail: "Sipariş yola çıktı", symbol: "bicycle.circle.fill"),
            OrderStep(title: "Teslim edildi", detail: "Sipariş teslim edildi", symbol: "house.fill")
        ]
    }

    return [
        OrderStep(title: "Sipariş alındı", detail: "Sipariş sisteme düştü", symbol: "checkmark.circle.fill"),
        OrderStep(title: "Hazırlanıyor", detail: "Sipariş hazırlanıyor", symbol: "bag.fill"),
        OrderStep(title: "Kurye yolda", detail: "Kurye bilgisi bekleniyor", symbol: "bicycle.circle.fill"),
        OrderStep(title: "Teslim edildi", detail: "Teslim edildiğinde burada görünecek", symbol: "house.fill")
    ]
}

private func defaultActiveStep(for status: String?) -> Int {
    switch (status ?? "").uppercased() {
    case "DELIVERED":
        return 3
    case "DELIVERING":
        return 2
    case "PREPARING":
        return 1
    default:
        return 0
    }
}

private func prettifiedStatus(_ status: String?) -> String? {
    switch (status ?? "").uppercased() {
    case "DELIVERED":
        return "Teslim edildi"
    case "DELIVERING":
        return "Kurye yolda"
    case "PREPARING":
        return "Hazırlanıyor"
    case "PENDING":
        return "Sipariş alındı"
    default:
        return nil
    }
}

private func symbol(for title: String) -> String {
    let lowercased = title.lowercased()
    if lowercased.contains("alındı") {
        return "checkmark.circle.fill"
    }
    if lowercased.contains("hazır") {
        return "bag.fill"
    }
    if lowercased.contains("kurye") || lowercased.contains("yolda") {
        return "bicycle.circle.fill"
    }
    if lowercased.contains("teslim") {
        return "house.fill"
    }
    return "circle.fill"
}

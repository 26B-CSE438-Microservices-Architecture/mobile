import Foundation

enum AppTab: Hashable {
    case home
    case favorites
    case cart
    case orders
    case profile
}

enum VendorKind: String, Hashable {
    case restaurant = "Restoran"
    case market = "Market"
    case water = "Su"
    case coffee = "Kahve"
}

enum VendorTheme: String, Hashable {
    case orange
    case amber
    case green
    case teal
    case blue
    case red
}

struct CategoryShortcut: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let theme: VendorTheme
}

struct Campaign: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let badge: String
    let detail: String
    let theme: VendorTheme
}

struct OptionGroup: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let required: Bool
    let options: [String]
}

struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let badge: String?
    let systemImage: String
    let theme: VendorTheme
    let optionGroups: [OptionGroup]
}

struct MenuSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let products: [Product]
}

struct Vendor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let summary: String
    let kind: VendorKind
    let eta: String
    let rating: Double
    let reviewCount: Int
    let minimumBasket: Double
    let deliveryFee: Double
    let coverNote: String
    let promoText: String
    let tags: [String]
    let theme: VendorTheme
    var isFavorite: Bool
    let menuSections: [MenuSection]
}

struct CartItem: Identifiable, Hashable {
    let id = UUID()
    let product: Product
    let vendorID: UUID
    let vendorName: String
    let selectedOptions: [String]
    let note: String
    var quantity: Int
}

struct Courier: Hashable {
    let name: String
    let vehicle: String
    let plate: String
    let phone: String
    let etaNote: String
}

struct OrderStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
}

enum OrderThumbnailKind: String, Hashable {
    case breakfastSauce
    case frozenSausage
    case labneh
    case falimRed
    case falimPurple
    case sodaBottle
    case bananas
    case persimmon
}

struct Order: Identifiable, Hashable {
    let id = UUID()
    let vendorName: String
    let items: [CartItem]
    let total: Double
    let dateLabel: String
    let statusLabel: String
    let addressLine: String
    let etaRange: String
    let campaignNote: String
    let courier: Courier?
    let steps: [OrderStep]
    let activeStep: Int
    let isActive: Bool
    let kind: VendorKind
    let itemSummary: String?
    let deliveredItemCount: Int
    let showsRatingAction: Bool
    let previewThumbnails: [OrderThumbnailKind]

    init(
        vendorName: String,
        items: [CartItem],
        total: Double,
        dateLabel: String,
        statusLabel: String,
        addressLine: String,
        etaRange: String,
        campaignNote: String,
        courier: Courier?,
        steps: [OrderStep],
        activeStep: Int,
        isActive: Bool,
        kind: VendorKind = .restaurant,
        itemSummary: String? = nil,
        deliveredItemCount: Int = 0,
        showsRatingAction: Bool = false,
        previewThumbnails: [OrderThumbnailKind] = []
    ) {
        self.vendorName = vendorName
        self.items = items
        self.total = total
        self.dateLabel = dateLabel
        self.statusLabel = statusLabel
        self.addressLine = addressLine
        self.etaRange = etaRange
        self.campaignNote = campaignNote
        self.courier = courier
        self.steps = steps
        self.activeStep = activeStep
        self.isActive = isActive
        self.kind = kind
        self.itemSummary = itemSummary
        self.deliveredItemCount = deliveredItemCount
        self.showsRatingAction = showsRatingAction
        self.previewThumbnails = previewThumbnails
    }
}

struct Address: Identifiable, Hashable {
    let id: String
    let title: String
    let line1: String
    let detail: String
    let regionLine: String
    let buildingLine: String
    let maskedPhone: String
    let showsMapPreview: Bool
    let isCurrent: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        line1: String,
        detail: String,
        regionLine: String,
        buildingLine: String,
        maskedPhone: String,
        showsMapPreview: Bool,
        isCurrent: Bool
    ) {
        self.id = id
        self.title = title
        self.line1 = line1
        self.detail = detail
        self.regionLine = regionLine
        self.buildingLine = buildingLine
        self.maskedPhone = maskedPhone
        self.showsMapPreview = showsMapPreview
        self.isCurrent = isCurrent
    }
}

struct PaymentMethod: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
    let isDefault: Bool
}

enum HomeBannerStyle: String, Hashable {
    case uberOne
    case flashDiscount
}

enum HomePrimaryServiceStyle: String, Hashable {
    case quickMarket
    case food
    case water
}

enum HomeArtwork: String, Hashable {
    case spaghetti
    case rigatoni
    case pizza
    case burger
    case cigkofte
    case friedChicken
    case grocery
    case petShop
    case goPlus
    case cleaning
    case water
    case doner
    case baklava
    case flowers
    case produce
    case nuts
}

struct HomeQuickFilter: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let systemImage: String
}

struct HomePrimaryService: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let style: HomePrimaryServiceStyle
    let artwork: HomeArtwork
    let imageURL: String
}

struct HomeMiniService: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let badgeText: String
    let artwork: HomeArtwork
    let imageURL: String
}

struct HomeCuisine: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageURL: String
    let artwork: HomeArtwork
}

struct HomeHeroBanner: Identifiable, Hashable {
    let id = UUID()
    let style: HomeBannerStyle
    let title: String
    let subtitle: String
    let detail: String
    let ctaText: String
}

struct HomeRewardMilestone: Identifiable, Hashable {
    let id = UUID()
    let points: Int
    let title: String
    let artwork: HomeArtwork
}

struct HomeRewardsOverview: Hashable {
    let currentPoints: Int
    let title: String
    let summary: String
    let detail: String
    let milestones: [HomeRewardMilestone]
}

enum HomeRestaurantDeliveryStyle: String, Hashable {
    case go
    case courier
}

struct HomeRestaurantSpotlight: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let promoBadges: [String]
    let imageURL: String
    let artwork: HomeArtwork
    let ratingText: String
    let reviewText: String
    let minimumText: String
    let distanceText: String
    let cuisineText: String
    let deliveryText: String
    let deliveryStyle: HomeRestaurantDeliveryStyle
    let sponsored: Bool
    let goPlus: Bool
}

struct HomeMarketSpotlight: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let featureBadge: String?
    let productTitle: String?
    let oldPriceText: String?
    let priceText: String?
    let ratingText: String
    let infoText: String
    let artwork: HomeArtwork
}

struct HomeOpportunitySpotlight: Identifiable, Hashable {
    let id = UUID()
    let badge: String
    let title: String
    let theme: VendorTheme
    let artwork: HomeArtwork
}

struct UserProfile: Hashable {
    let fullName: String
    let email: String
    let phone: String
    let walletBalance: Double
    let loyaltyPoints: Int
    let addresses: [Address]
    let paymentMethods: [PaymentMethod]
    let role: String
    let isActive: Bool

    init(
        fullName: String,
        email: String,
        phone: String,
        walletBalance: Double,
        loyaltyPoints: Int,
        addresses: [Address],
        paymentMethods: [PaymentMethod],
        role: String = "Customer",
        isActive: Bool = true
    ) {
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.walletBalance = walletBalance
        self.loyaltyPoints = loyaltyPoints
        self.addresses = addresses
        self.paymentMethods = paymentMethods
        self.role = role
        self.isActive = isActive
    }
}

enum MockData {
    static let shortcuts: [CategoryShortcut] = [
        CategoryShortcut(title: "Yemek", subtitle: "30 dk", systemImage: "fork.knife", theme: .orange),
        CategoryShortcut(title: "Market", subtitle: "15 dk", systemImage: "basket.fill", theme: .green),
        CategoryShortcut(title: "Su", subtitle: "Hızlı", systemImage: "drop.fill", theme: .blue),
        CategoryShortcut(title: "Kahve", subtitle: "Sıcak", systemImage: "cup.and.saucer.fill", theme: .amber),
        CategoryShortcut(title: "Tatlı", subtitle: "%20", systemImage: "birthday.cake.fill", theme: .red),
        CategoryShortcut(title: "İndirim", subtitle: "Kupon", systemImage: "ticket.fill", theme: .teal)
    ]

    static let campaigns: [Campaign] = [
        Campaign(
            title: "İlk Siparişe 80 TL İndirim",
            subtitle: "250 TL ve üzeri sepetlerde geçerli",
            badge: "Yeni kullanıcı",
            detail: "Sepette otomatik uygulanır. Yemek ve kahve kategorilerinde kullanılabilir.",
            theme: .orange
        ),
        Campaign(
            title: "Markette Gece Fırsatı",
            subtitle: "22.00 sonrası ücretsiz teslimat",
            badge: "Sınırlı süre",
            detail: "Seçili marketlerde teslimat ücreti düşer ve hızlı teslimat etiketi görünür.",
            theme: .green
        ),
        Campaign(
            title: "2 Al 1 Öde Kahve Menüsü",
            subtitle: "Öğle arası kahve siparişlerinde",
            badge: "Popüler",
            detail: "Seçili içeceklerde ikinci ürün ücretsiz eklenir. Mock data için kampanya etiketi kartlarda görünür.",
            theme: .amber
        )
    ]

    static let homeSearchSuggestions = ["Un ara", "Tantuni ara", "Döner ara"]

    static let homePrimaryServices: [HomePrimaryService] = [
        HomePrimaryService(
            title: "Hızlı Market",
            subtitle: "Binlerce ürün\nindirimlerle kapında",
            style: .quickMarket,
            artwork: .grocery,
            imageURL: "https://images.unsplash.com/photo-1628102491629-778571d893a3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
        ),
        HomePrimaryService(
            title: "Yemek",
            subtitle: "Sıcak ve indirimli\nlezzetler",
            style: .food,
            artwork: .burger,
            imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
        ),
        HomePrimaryService(
            title: "Su ve\nDamacana",
            subtitle: "",
            style: .water,
            artwork: .water,
            imageURL: "https://images.unsplash.com/photo-1602143407151-7111542de6e8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
        )
    ]

    static let homeMiniServices: [HomeMiniService] = [
        HomeMiniService(
            title: "Petshop",
            badgeText: "go-hızlıya",
            artwork: .petShop,
            imageURL: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
        ),
        HomeMiniService(
            title: "Gurme\nMarket",
            badgeText: "go-hızlıya",
            artwork: .grocery,
            imageURL: "https://images.unsplash.com/photo-1613454320437-0c228c8b1723?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
        ),
        HomeMiniService(
            title: "Manav",
            badgeText: "go-hızlıya",
            artwork: .produce,
            imageURL: "https://images.unsplash.com/photo-1590779033100-9f60a05a013d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
        ),
        HomeMiniService(
            title: "Kuruyemiş",
            badgeText: "go-hızlıya",
            artwork: .nuts,
            imageURL: "https://images.unsplash.com/photo-1600189020840-e9918c25269d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
        ),
        HomeMiniService(
            title: "Çiçek",
            badgeText: "go-hızlıya",
            artwork: .flowers,
            imageURL: "https://images.unsplash.com/photo-1582794543139-8ac9cb0f7b11?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
        )
    ]

    static let homeCuisines: [HomeCuisine] = [
        HomeCuisine(
            title: "Döner",
            imageURL: "https://images.unsplash.com/photo-1699728088614-7d1d4277414b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .doner
        ),
        HomeCuisine(
            title: "Çiğ Köfte",
            imageURL: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .cigkofte
        ),
        HomeCuisine(
            title: "Tatlı",
            imageURL: "https://images.unsplash.com/photo-1705663106388-6c1c51ff5a8d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .baklava
        ),
        HomeCuisine(
            title: "Hamburger",
            imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .burger
        ),
        HomeCuisine(
            title: "Pizza",
            imageURL: "https://images.unsplash.com/photo-1513104890138-7c749659a591?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .pizza
        )
    ]

    static let homeQuickFilters: [HomeQuickFilter] = [
        HomeQuickFilter(title: "Yemek", systemImage: "fork.knife"),
        HomeQuickFilter(title: "Market", systemImage: "basket.fill"),
        HomeQuickFilter(title: "Su", systemImage: "drop.fill"),
        HomeQuickFilter(title: "Kahve", systemImage: "cup.and.saucer.fill")
    ]

    static let homeHeroBanners: [HomeHeroBanner] = [
        HomeHeroBanner(
            style: .uberOne,
            title: "1 AYLIK\nUBER ONE ABONELİĞİ\nHEDİYE!",
            subtitle: "trendyol go by Uber Eats | Uber One",
            detail: "Kampanya 28 Şubat 2026'ya kadar geçerlidir. Üyelik sonrası 1 aylık ücretsiz Uber One kullanım hakkı tanımlar.",
            ctaText: "UBER'E GİT"
        ),
        HomeHeroBanner(
            style: .flashDiscount,
            title: "YEMEKTE FLAŞ İNDİRİM",
            subtitle: "İndirimli sepet tutarının sipariş verilen restoranın minimum tutarını karşılaması gerekir.",
            detail: "Kupon ve sepet indirimi birlikte gösterilir.",
            ctaText: "İncele"
        )
    ]

    static let homeRewardsOverview = HomeRewardsOverview(
        currentPoints: 50,
        title: "Puanın:",
        summary: "250 tl ve üzeri Yemek siparişi ver Yemek Kuponu (60 TL) kazan",
        detail: "Puanlar ve ödüller 01 Mart - 31 Mart tarihleri arasında geçerlidir ve her ay yenilenir",
        milestones: [
            HomeRewardMilestone(points: 100, title: "Yemek Kuponu\n(60 TL)", artwork: .goPlus),
            HomeRewardMilestone(points: 150, title: "Uber'de İlk İki\nYolculukta %100\nİndirim", artwork: .goPlus),
            HomeRewardMilestone(points: 200, title: "Yemek Kuponu\n(60 TL)", artwork: .goPlus),
            HomeRewardMilestone(points: 300, title: "Yemek Kuponu\n(60 TL)", artwork: .goPlus)
        ]
    )

    static let homePersonalRestaurants: [HomeRestaurantSpotlight] = [
        HomeRestaurantSpotlight(
            title: "Sose Pizza",
            promoBadges: ["Belirli Ürünlerde 100 TL İndirim"],
            imageURL: "https://images.unsplash.com/photo-1513104890138-7c749659a591?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .pizza,
            ratingText: "4.8",
            reviewText: "(100+)",
            minimumText: "Min 180 TL",
            distanceText: "1.4 km",
            cuisineText: "Pizza,Tatlı",
            deliveryText: "15-25dk",
            deliveryStyle: .courier,
            sponsored: true,
            goPlus: true
        ),
        HomeRestaurantSpotlight(
            title: "Makarna Kralı",
            promoBadges: ["350 TL'ye 150 TL İndirim", "200 TL'ye Varan İndirim"],
            imageURL: "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .rigatoni,
            ratingText: "4.7",
            reviewText: "(5200+)",
            minimumText: "Min 90 TL",
            distanceText: "0.7 km",
            cuisineText: "Mantı & Makarna",
            deliveryText: "15-25dk · 4.99-9.99TL",
            deliveryStyle: .go,
            sponsored: true,
            goPlus: true
        ),
        HomeRestaurantSpotlight(
            title: "Adana Naz Pizza",
            promoBadges: ["350 TL'ye 150 TL İndirim", "200 TL'ye Varan İndirim"],
            imageURL: "https://images.unsplash.com/photo-1458642849426-cfb724f15ef7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .pizza,
            ratingText: "4.2",
            reviewText: "(500+)",
            minimumText: "Min 90 TL",
            distanceText: "1.0 km",
            cuisineText: "Pizza & İtalyan",
            deliveryText: "20-30dk · 9.99TL",
            deliveryStyle: .go,
            sponsored: false,
            goPlus: true
        )
    ]

    static let homeCampaignRestaurants: [HomeRestaurantSpotlight] = [
        HomeRestaurantSpotlight(
            title: "Koko House",
            promoBadges: [],
            imageURL: "https://images.unsplash.com/photo-1553909489-cd47e0907980?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .burger,
            ratingText: "4.0",
            reviewText: "(900+)",
            minimumText: "Min 175 TL",
            distanceText: "0.3 km",
            cuisineText: "Sokak Lezzetleri",
            deliveryText: "15-25dk",
            deliveryStyle: .courier,
            sponsored: true,
            goPlus: true
        ),
        HomeRestaurantSpotlight(
            title: "Komagene",
            promoBadges: ["400 TL'ye 200 TL İndirim", "Trendyol Özel Ultra Menü"],
            imageURL: "https://images.unsplash.com/photo-1699728088614-7d1d4277414b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .cigkofte,
            ratingText: "4.5",
            reviewText: "(1300+)",
            minimumText: "Min 110 TL",
            distanceText: "1.2 km",
            cuisineText: "Çiğ Köfte",
            deliveryText: "20-30dk · 0-25.99TL",
            deliveryStyle: .go,
            sponsored: true,
            goPlus: true
        ),
        HomeRestaurantSpotlight(
            title: "Popeyes",
            promoBadges: ["Süper Efsane Menü", "600 TL ve Üzeri İndirim"],
            imageURL: "https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            artwork: .friedChicken,
            ratingText: "3.7",
            reviewText: "(2900+)",
            minimumText: "Min 170 TL",
            distanceText: "1.5 km",
            cuisineText: "Tavuk & Burger",
            deliveryText: "15-25dk",
            deliveryStyle: .courier,
            sponsored: false,
            goPlus: false
        )
    ]

    static let homeMarkets: [HomeMarketSpotlight] = [
        HomeMarketSpotlight(
            title: "Nil Hızlı Süpermarket",
            featureBadge: "FIRSAT ÜRÜNÜ",
            productTitle: "SÜTAŞ\nKaymaksız Yoğurt 200Gr",
            oldPriceText: "17,95 TL",
            priceText: "14,95 TL",
            ratingText: "4.6",
            infoText: "Min. 90 TL · 30 - 40 dk",
            artwork: .grocery
        ),
        HomeMarketSpotlight(
            title: "M.y Flowers",
            featureBadge: nil,
            productTitle: nil,
            oldPriceText: nil,
            priceText: nil,
            ratingText: "4.3",
            infoText: "Min. 90 TL · 40 - 50 dk",
            artwork: .flowers
        )
    ]

    static let homeOpportunities: [HomeOpportunitySpotlight] = [
        HomeOpportunitySpotlight(
            badge: "YEMEK",
            title: "Go Plus\nİndirimi",
            theme: .orange,
            artwork: .goPlus
        ),
        HomeOpportunitySpotlight(
            badge: "MARKET",
            title: "Sepete Özel\nİndirimler",
            theme: .green,
            artwork: .cleaning
        ),
        HomeOpportunitySpotlight(
            badge: "YEMEK",
            title: "Lezzete Doyuran\nİndirimler",
            theme: .amber,
            artwork: .friedChicken
        )
    ]

    static let burgerClassic = Product(
        name: "Klasik Burger Menü",
        description: "120 gr köfte, cheddar, özel sos, çıtır patates ve içecek",
        price: 229.90,
        badge: "En Çok Satan",
        systemImage: "takeoutbag.and.cup.and.straw.fill",
        theme: .orange,
        optionGroups: [
            OptionGroup(title: "İçecek Seçimi", required: true, options: ["Kola", "Ayran", "Fuse Tea"]),
            OptionGroup(title: "Ekstra", required: false, options: ["Ekstra cheddar", "Turşu", "Soğan halkası"])
        ]
    )

    static let burgerSmash = Product(
        name: "Double Smash Burger",
        description: "Çift köfte, karamelize soğan, burger sos ve patates",
        price: 269.90,
        badge: "Yeni",
        systemImage: "flame.fill",
        theme: .red,
        optionGroups: [
            OptionGroup(title: "Pişirme", required: true, options: ["Standart", "İyi Pişmiş"]),
            OptionGroup(title: "Sos", required: false, options: ["Acı mayo", "Barbekü", "Sarımsaklı ranch"])
        ]
    )

    static let burgerLoadedFries = Product(
        name: "Loaded Fries",
        description: "Cheddar sos, jalapeno ve çıtır bacon ile dolu patates",
        price: 149.90,
        badge: "Atıştırmalık",
        systemImage: "takeoutbag.fill",
        theme: .amber,
        optionGroups: []
    )

    static let donerWrap = Product(
        name: "Bol Etli Dürüm",
        description: "Odun ateşinde pişmiş et döner, köz biber ve patates eşlik eder",
        price: 194.90,
        badge: "30 dk",
        systemImage: "flame.circle.fill",
        theme: .orange,
        optionGroups: [
            OptionGroup(title: "Yan Ürün", required: true, options: ["Patates", "Pilav"]),
            OptionGroup(title: "Sos", required: false, options: ["Acı sos", "Yoğurtlu sos"])
        ]
    )

    static let donerIskender = Product(
        name: "İskender Menü",
        description: "Tereyağlı sos, yoğurt ve pide üzerinde et döner",
        price: 249.90,
        badge: "Şefin Seçimi",
        systemImage: "fork.knife.circle.fill",
        theme: .red,
        optionGroups: [
            OptionGroup(title: "İçecek", required: true, options: ["Ayran", "Şalgam"])
        ]
    )

    static let fitBowl = Product(
        name: "Protein Bowl",
        description: "Izgara tavuk, kinoalı pilav, avokado ve roka",
        price: 214.90,
        badge: "Fit Seçim",
        systemImage: "leaf.circle.fill",
        theme: .green,
        optionGroups: [
            OptionGroup(title: "Sos", required: true, options: ["Sezar", "Nar ekşili", "Zeytinyağlı"])
        ]
    )

    static let fitWrap = Product(
        name: "Avokadolu Wrap",
        description: "Tam buğday tortilla, humus, avokado ve ızgara sebze",
        price: 189.90,
        badge: "Hafif",
        systemImage: "carrot.fill",
        theme: .teal,
        optionGroups: [
            OptionGroup(title: "Protein", required: true, options: ["Tavuk", "Hellim"])
        ]
    )

    static let fitSmoothie = Product(
        name: "Mango Smoothie",
        description: "Mango, muz ve badem sütü ile hazırlanan enerji içeceği",
        price: 119.90,
        badge: "Soğuk",
        systemImage: "cup.and.saucer.fill",
        theme: .amber,
        optionGroups: []
    )

    static let marketMilk = Product(
        name: "Günlük Süt 1L",
        description: "Soğuk zincir ile teslim edilen tam yağlı süt",
        price: 39.90,
        badge: nil,
        systemImage: "cart.fill",
        theme: .green,
        optionGroups: []
    )

    static let marketEggs = Product(
        name: "Organik Yumurta 10'lu",
        description: "Serbest gezen tavuk yumurtası",
        price: 84.90,
        badge: "Çok Alan",
        systemImage: "oval.fill",
        theme: .amber,
        optionGroups: []
    )

    static let marketSnacks = Product(
        name: "Atıştırmalık Paketi",
        description: "Cips, kraker ve çikolata seti",
        price: 129.90,
        badge: "Paket",
        systemImage: "bag.fill",
        theme: .orange,
        optionGroups: []
    )

    static let waterBottle = Product(
        name: "Damacana Su",
        description: "12 litre su teslimatı ve kapıda iade sistemi",
        price: 69.90,
        badge: "Hızlı",
        systemImage: "drop.circle.fill",
        theme: .blue,
        optionGroups: [
            OptionGroup(title: "Adet", required: true, options: ["1 Damacana", "2 Damacana"])
        ]
    )

    static let waterSparkling = Product(
        name: "Maden Suyu 6'lı",
        description: "Limon aromalı karma paket",
        price: 59.90,
        badge: nil,
        systemImage: "sparkles",
        theme: .teal,
        optionGroups: []
    )

    static let breakfastSauce = Product(
        name: "Kahvaltılık Sos",
        description: "Acuka ve kahvaltılık sos kavanozu",
        price: 74.95,
        badge: nil,
        systemImage: "takeoutbag.fill",
        theme: .red,
        optionGroups: []
    )

    static let frozenSausage = Product(
        name: "Piliç Kokteyl Sosis",
        description: "Dondurulmuş piliç kokteyl sosis",
        price: 89.90,
        badge: nil,
        systemImage: "snowflake",
        theme: .amber,
        optionGroups: []
    )

    static let labnehSpread = Product(
        name: "Labne",
        description: "Sürülebilir labne peyniri",
        price: 42.95,
        badge: nil,
        systemImage: "square.stack.3d.up.fill",
        theme: .green,
        optionGroups: []
    )

    static let falimRed = Product(
        name: "Falım Çilek",
        description: "Şekersiz sakız",
        price: 9.95,
        badge: nil,
        systemImage: "rectangle.and.pencil.and.ellipsis",
        theme: .red,
        optionGroups: []
    )

    static let falimPurple = Product(
        name: "Falım Orman Meyveli",
        description: "Şekersiz sakız",
        price: 9.95,
        badge: nil,
        systemImage: "rectangle.and.pencil.and.ellipsis",
        theme: .teal,
        optionGroups: []
    )

    static let sodaBottle = Product(
        name: "Meyveli Soda",
        description: "Gazlı içecek",
        price: 24.99,
        badge: nil,
        systemImage: "waterbottle.fill",
        theme: .green,
        optionGroups: []
    )

    static let bananaPack = Product(
        name: "Muz",
        description: "Taze muz demeti",
        price: 39.90,
        badge: nil,
        systemImage: "leaf.fill",
        theme: .amber,
        optionGroups: []
    )

    static let persimmonPack = Product(
        name: "Trabzon Hurması",
        description: "Mevsim meyvesi",
        price: 27.85,
        badge: nil,
        systemImage: "leaf.circle.fill",
        theme: .orange,
        optionGroups: []
    )

    static let burgerHouse = Vendor(
        name: "Burger Point",
        summary: "Burger, patates ve gece menüleri",
        kind: .restaurant,
        eta: "20-30 dk",
        rating: 4.7,
        reviewCount: 1284,
        minimumBasket: 180,
        deliveryFee: 24.90,
        coverNote: "Gece açık ve hızlı teslimat",
        promoText: "300 TL üzeri sepetlerde 40 TL indirim",
        tags: ["Yeni", "30 dk", "Kuponlu"],
        theme: .orange,
        isFavorite: true,
        menuSections: [
            MenuSection(title: "Burger Menüler", products: [burgerClassic, burgerSmash]),
            MenuSection(title: "Yan Lezzetler", products: [burgerLoadedFries])
        ]
    )

    static let anadoluDoner = Vendor(
        name: "Anadolu Döner",
        summary: "Et döner, iskender ve dürüm çeşitleri",
        kind: .restaurant,
        eta: "25-35 dk",
        rating: 4.8,
        reviewCount: 3465,
        minimumBasket: 160,
        deliveryFee: 19.90,
        coverNote: "Trendyol Go stilinde sıcak teslimat",
        promoText: "Ayran menüye dahil, ikili siparişte ekstra indirim",
        tags: ["Popüler", "Mega Lezzet", "Hızlı"],
        theme: .red,
        isFavorite: false,
        menuSections: [
            MenuSection(title: "Dönerler", products: [donerWrap, donerIskender])
        ]
    )

    static let fitKitchen = Vendor(
        name: "Fit Kitchen",
        summary: "Sağlıklı bowl, wrap ve smoothie",
        kind: .restaurant,
        eta: "15-25 dk",
        rating: 4.6,
        reviewCount: 952,
        minimumBasket: 170,
        deliveryFee: 17.90,
        coverNote: "Kalori dostu menüler ve taze içerik",
        promoText: "Seçili bowl menülerinde ücretsiz smoothie yükseltmesi",
        tags: ["Fit", "Öğle Menüsü", "Yıldızlı"],
        theme: .green,
        isFavorite: true,
        menuSections: [
            MenuSection(title: "Bowl ve Wrap", products: [fitBowl, fitWrap]),
            MenuSection(title: "İçecekler", products: [fitSmoothie])
        ]
    )

    static let freshMarket = Vendor(
        name: "Nil Hızlı Süpermarket",
        summary: "Atıştırmalık, meyve ve günlük ihtiyaçlar",
        kind: .market,
        eta: "10-15 dk",
        rating: 4.9,
        reviewCount: 640,
        minimumBasket: 120,
        deliveryFee: 9.90,
        coverNote: "Dakikalar içinde kapında market",
        promoText: "Gece teslimatlarında ücretsiz servis",
        tags: ["15 dk", "Ücretsiz Teslimat", "İndirim"],
        theme: .green,
        isFavorite: false,
        menuSections: [
            MenuSection(title: "Sık Alınanlar", products: [falimRed, falimPurple, sodaBottle, bananaPack, persimmonPack])
        ]
    )

    static let a101Kapida = Vendor(
        name: "A101 Kapıda",
        summary: "Temel gıda, kahvaltılık ve dondurulmuş ürünler",
        kind: .market,
        eta: "20-30 dk",
        rating: 4.6,
        reviewCount: 840,
        minimumBasket: 150,
        deliveryFee: 11.90,
        coverNote: "Mahalle market alışverişin kapında",
        promoText: "Haftalık indirimli ürünlerle hızlı teslimat",
        tags: ["Hızlı Market", "Kampanyalı", "Kahvaltılık"],
        theme: .green,
        isFavorite: false,
        menuSections: [
            MenuSection(title: "Öne Çıkanlar", products: [breakfastSauce, frozenSausage, labnehSpread])
        ]
    )

    static let waterHub = Vendor(
        name: "Su Deposu",
        summary: "Damacana su, maden suyu ve içecekler",
        kind: .water,
        eta: "15-20 dk",
        rating: 4.7,
        reviewCount: 312,
        minimumBasket: 50,
        deliveryFee: 0,
        coverNote: "Kapıya kadar taşıma ve hızlı teslimat",
        promoText: "İkinci damacanada indirim uygulanır",
        tags: ["Bedava Teslimat", "Su", "Kapıda Ödeme"],
        theme: .blue,
        isFavorite: false,
        menuSections: [
            MenuSection(title: "Su Siparişi", products: [waterBottle, waterSparkling])
        ]
    )

    static let restaurants: [Vendor] = [anadoluDoner, burgerHouse, fitKitchen]
    static let markets: [Vendor] = [freshMarket, a101Kapida, waterHub]

    static let userProfile = UserProfile(
        fullName: "Samet Bilgin",
        email: "samet@example.com",
        phone: "+90 555 123 45 67",
        walletBalance: 245.50,
        loyaltyPoints: 420,
        addresses: [
            Address(
            title: "mu house",
            line1: "Kültür 3818. Sk. No:8 Bahtılı Köyü Köyü",
            detail: "Kültür Mah",
            regionLine: "Kültür Mah / Kepez / Antalya",
            buildingLine: "Bina No: 8, Kat: 4, Daire No: 65",
            maskedPhone: "546*****36",
            showsMapPreview: true,
            isCurrent: true
        ),
        Address(
            title: "burak yeni ev",
            line1: "Kültür 3814. Sk. No:3",
            detail: "Kültür Mah",
            regionLine: "Kültür Mah / Kepez / Antalya",
            buildingLine: "Bina No: 3, Kat: 3, Daire No: 11",
            maskedPhone: "546*****36",
            showsMapPreview: false,
            isCurrent: false
        ),
            Address(
                title: "birlik apartmanı",
                line1: "Kültür 3821. Sk. No:36 Bahtılı Köyü Köyü",
                detail: "Kültür Mah",
                regionLine: "Kültür Mah / Kepez / Antalya",
                buildingLine: "Bina No: 36, Kat: 4, Daire No: 26",
                maskedPhone: "546*****36",
                showsMapPreview: false,
                isCurrent: false
            ),
            Address(
                title: "evumut",
                line1: "Kültür 3814. Sk. No:5 Bahtılı Köyü Köyü",
                detail: "Kültür Mah",
                regionLine: "Kültür Mah / Kepez / Antalya",
                buildingLine: "Bina No: 5, Kat: 2, Daire No: 8",
                maskedPhone: "546*****36",
                showsMapPreview: false,
                isCurrent: false
            )
        ],
        paymentMethods: [
            PaymentMethod(title: "Mastercard", detail: "**** 2741", isDefault: true),
            PaymentMethod(title: "Trendyol Cüzdan", detail: "Bakiye: 245,50 TL", isDefault: false)
        ]
    )

    static let activeOrder = Order(
        vendorName: "Anadolu Döner",
        items: [
            CartItem(
                product: donerWrap,
                vendorID: anadoluDoner.id,
                vendorName: anadoluDoner.name,
                selectedOptions: ["Patates", "Acı sos"],
                note: "Bol acılı olsun",
                quantity: 1
            ),
            CartItem(
                product: donerIskender,
                vendorID: anadoluDoner.id,
                vendorName: anadoluDoner.name,
                selectedOptions: ["Ayran"],
                note: "",
                quantity: 1
            )
        ],
        total: 489.70,
        dateLabel: "Bugün, 13:05",
        statusLabel: "Kurye yolda",
        addressLine: "Kozyatağı Mah. Meltem Sok. No:18, Kadıköy",
        etaRange: "13:32 - 13:38",
        campaignNote: "Ayran menüye ücretsiz eklendi",
        courier: Courier(
            name: "Mert K.",
            vehicle: "Motosiklet",
            plate: "34 TGO 145",
            phone: "+90 555 845 22 14",
            etaNote: "5 dakika içinde teslim edecek"
        ),
        steps: [
            OrderStep(title: "Sipariş alındı", detail: "Restoran siparişi onayladı", symbol: "checkmark.circle.fill"),
            OrderStep(title: "Hazırlanıyor", detail: "Mutfakta paketleme yapılıyor", symbol: "bag.fill"),
            OrderStep(title: "Kurye yolda", detail: "Kurye siparişi teslim aldı", symbol: "bicycle.circle.fill"),
            OrderStep(title: "Teslim edildi", detail: "Sipariş teslim edildiğinde güncellenir", symbol: "house.fill")
        ],
        activeStep: 2,
        isActive: true
    )

    static let pastOrders: [Order] = [
        Order(
            vendorName: "Chicken Box (Ahatlı)",
            items: [
                CartItem(
                    product: burgerClassic,
                    vendorID: burgerHouse.id,
                    vendorName: burgerHouse.name,
                    selectedOptions: ["Kola", "Ekstra cheddar"],
                    note: "",
                    quantity: 2
                )
            ],
            total: 265.99,
            dateLabel: "07 Mart 2026 / 18:42",
            statusLabel: "Teslim edildi",
            addressLine: "Kozyatağı Mah. Meltem Sok. No:18, Kadıköy",
            etaRange: "20:34",
            campaignNote: "40 TL kupon kullanıldı",
            courier: nil,
            steps: [
                OrderStep(title: "Sipariş alındı", detail: "Sipariş başarıyla tamamlandı", symbol: "checkmark.circle.fill"),
                OrderStep(title: "Hazırlanıyor", detail: "Mutfak siparişi hazırladı", symbol: "bag.fill"),
                OrderStep(title: "Kurye yolda", detail: "Kurye yola çıktı", symbol: "bicycle.circle.fill"),
                OrderStep(title: "Teslim edildi", detail: "Sipariş teslim edildi", symbol: "house.fill")
            ],
            activeStep: 3,
            isActive: false,
            itemSummary: "Chicken Box Special (1 Adet)",
            deliveredItemCount: 1,
            showsRatingAction: true
        ),
        Order(
            vendorName: "Elif Döner (Kültür)",
            items: [
                CartItem(
                    product: donerWrap,
                    vendorID: anadoluDoner.id,
                    vendorName: anadoluDoner.name,
                    selectedOptions: ["Patates"],
                    note: "",
                    quantity: 1
                )
            ],
            total: 209.00,
            dateLabel: "27 Ocak 2026 / 17:46",
            statusLabel: "Teslim edildi",
            addressLine: "Kozyatağı Mah. Meltem Sok. No:18, Kadıköy",
            etaRange: "18:04",
            campaignNote: "Yemek siparişi tamamlandı",
            courier: nil,
            steps: [
                OrderStep(title: "Sipariş alındı", detail: "Sipariş başarıyla tamamlandı", symbol: "checkmark.circle.fill"),
                OrderStep(title: "Hazırlanıyor", detail: "Ürünler hazırlandı", symbol: "bag.fill"),
                OrderStep(title: "Kurye yolda", detail: "Kurye restorandan çıktı", symbol: "bicycle.circle.fill"),
                OrderStep(title: "Teslim edildi", detail: "Sipariş teslim edildi", symbol: "house.fill")
            ],
            activeStep: 3,
            isActive: false,
            itemSummary: "ELİF DÖNER' i keşfet Menü (1 Adet)",
            deliveredItemCount: 1
        ),
        Order(
            vendorName: "Ankara Makarnacısı (Yeni Doğan)",
            items: [
                CartItem(
                    product: fitWrap,
                    vendorID: fitKitchen.id,
                    vendorName: fitKitchen.name,
                    selectedOptions: ["Tavuk"],
                    note: "",
                    quantity: 1
                )
            ],
            total: 254.99,
            dateLabel: "26 Ocak 2026 / 19:43",
            statusLabel: "Teslim edildi",
            addressLine: "Kozyatağı Mah. Meltem Sok. No:18, Kadıköy",
            etaRange: "20:11",
            campaignNote: "Yemek siparişi tamamlandı",
            courier: nil,
            steps: [
                OrderStep(title: "Sipariş alındı", detail: "Sipariş başarıyla tamamlandı", symbol: "checkmark.circle.fill"),
                OrderStep(title: "Hazırlanıyor", detail: "Mutfak siparişi hazırladı", symbol: "bag.fill"),
                OrderStep(title: "Kurye yolda", detail: "Kurye teslimat için yola çıktı", symbol: "bicycle.circle.fill"),
                OrderStep(title: "Teslim edildi", detail: "Sipariş teslim edildi", symbol: "house.fill")
            ],
            activeStep: 3,
            isActive: false,
            itemSummary: "Karışık Makarna Menü (1 Adet)",
            deliveredItemCount: 1
        ),
        Order(
            vendorName: "A101 Kapıda",
            items: [
                CartItem(
                    product: breakfastSauce,
                    vendorID: a101Kapida.id,
                    vendorName: a101Kapida.name,
                    selectedOptions: [],
                    note: "",
                    quantity: 2
                ),
                CartItem(
                    product: frozenSausage,
                    vendorID: a101Kapida.id,
                    vendorName: a101Kapida.name,
                    selectedOptions: [],
                    note: "",
                    quantity: 2
                ),
                CartItem(
                    product: labnehSpread,
                    vendorID: a101Kapida.id,
                    vendorName: a101Kapida.name,
                    selectedOptions: [],
                    note: "Kapıyı çalın",
                    quantity: 1
                )
            ],
            total: 317.50,
            dateLabel: "21 Ocak 2026",
            statusLabel: "Teslim edildi",
            addressLine: "Kültür Mah. 1382. Sok. No:12, Kepez",
            etaRange: "22:24",
            campaignNote: "Market siparişi tamamlandı",
            courier: nil,
            steps: [
                OrderStep(title: "Sipariş alındı", detail: "Sipariş başarıyla tamamlandı", symbol: "checkmark.circle.fill"),
                OrderStep(title: "Hazırlanıyor", detail: "Ürünler toplandı", symbol: "bag.fill"),
                OrderStep(title: "Kurye yolda", detail: "Kurye marketten çıktı", symbol: "bicycle.circle.fill"),
                OrderStep(title: "Teslim edildi", detail: "Sipariş teslim edildi", symbol: "house.fill")
            ],
            activeStep: 3,
            isActive: false,
            kind: .market,
            itemSummary: "5 Ürün Teslim Edildi",
            deliveredItemCount: 5,
            previewThumbnails: [.breakfastSauce, .frozenSausage, .labneh]
        ),
        Order(
            vendorName: "Nil Hızlı Süpermarket",
            items: [
                CartItem(
                    product: falimRed,
                    vendorID: freshMarket.id,
                    vendorName: freshMarket.name,
                    selectedOptions: [],
                    note: "",
                    quantity: 2
                ),
                CartItem(
                    product: falimPurple,
                    vendorID: freshMarket.id,
                    vendorName: freshMarket.name,
                    selectedOptions: [],
                    note: "",
                    quantity: 1
                ),
                CartItem(
                    product: sodaBottle,
                    vendorID: freshMarket.id,
                    vendorName: freshMarket.name,
                    selectedOptions: [],
                    note: "",
                    quantity: 2
                ),
                CartItem(
                    product: bananaPack,
                    vendorID: freshMarket.id,
                    vendorName: freshMarket.name,
                    selectedOptions: [],
                    note: "",
                    quantity: 2
                ),
                CartItem(
                    product: persimmonPack,
                    vendorID: freshMarket.id,
                    vendorName: freshMarket.name,
                    selectedOptions: [],
                    note: "",
                    quantity: 1
                )
            ],
            total: 122.59,
            dateLabel: "11 Aralık 2025",
            statusLabel: "Teslim edildi",
            addressLine: "Kültür Mah. 1382. Sok. No:12, Kepez",
            etaRange: "19:22",
            campaignNote: "Market siparişi tamamlandı",
            courier: nil,
            steps: [
                OrderStep(title: "Sipariş alındı", detail: "Sipariş başarıyla tamamlandı", symbol: "checkmark.circle.fill"),
                OrderStep(title: "Hazırlanıyor", detail: "Ürünler toplandı", symbol: "bag.fill"),
                OrderStep(title: "Kurye yolda", detail: "Kurye marketten çıktı", symbol: "bicycle.circle.fill"),
                OrderStep(title: "Teslim edildi", detail: "Sipariş teslim edildi", symbol: "house.fill")
            ],
            activeStep: 3,
            isActive: false,
            kind: .market,
            itemSummary: "8 Ürün Teslim Edildi",
            deliveredItemCount: 8,
            previewThumbnails: [.falimRed, .falimPurple, .sodaBottle, .bananas, .persimmon]
        )
    ]
}

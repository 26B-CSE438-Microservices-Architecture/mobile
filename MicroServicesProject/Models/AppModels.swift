import Foundation

enum AppTab: Hashable {
    case home
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
        showsRatingAction: Bool = false
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
    }
}

struct Address: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let line1: String
    let detail: String
    let isCurrent: Bool
}

struct PaymentMethod: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
    let isDefault: Bool
}

struct UserProfile: Hashable {
    let fullName: String
    let email: String
    let phone: String
    let walletBalance: Double
    let loyaltyPoints: Int
    let addresses: [Address]
    let paymentMethods: [PaymentMethod]
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
        name: "Fresh Market",
        summary: "Süt ürünleri, atıştırmalık ve günlük ihtiyaçlar",
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
            MenuSection(title: "Sık Alınanlar", products: [marketMilk, marketEggs, marketSnacks])
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
    static let markets: [Vendor] = [freshMarket, waterHub]

    static let userProfile = UserProfile(
        fullName: "Samet Bilgin",
        email: "samet@example.com",
        phone: "+90 555 123 45 67",
        walletBalance: 245.50,
        loyaltyPoints: 420,
        addresses: [
            Address(title: "Ev", line1: "Kozyatağı Mah. Meltem Sok. No:18", detail: "Kadıköy / İstanbul", isCurrent: true),
            Address(title: "Okul", line1: "Üniversite Kampüsü C Blok", detail: "Kartal / İstanbul", isCurrent: false)
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
            vendorName: "Fresh Market",
            items: [
                CartItem(
                    product: marketMilk,
                    vendorID: freshMarket.id,
                    vendorName: freshMarket.name,
                    selectedOptions: [],
                    note: "",
                    quantity: 2
                ),
                CartItem(
                    product: marketEggs,
                    vendorID: freshMarket.id,
                    vendorName: freshMarket.name,
                    selectedOptions: [],
                    note: "Kapıyı çalın",
                    quantity: 1
                )
            ],
            total: 174.70,
            dateLabel: "03 Mart 2026 / 22:08",
            statusLabel: "Teslim edildi",
            addressLine: "Üniversite Kampüsü C Blok, Kartal",
            etaRange: "22:24",
            campaignNote: "Gece teslimatında kurye ücreti alınmadı",
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
            itemSummary: "Günlük Süt 1L, Organik Yumurta 10'lu",
            deliveredItemCount: 3
        )
    ]
}

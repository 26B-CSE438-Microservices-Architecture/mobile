import SwiftUI

struct TrendyolGoPrototypeView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var isCartPresented = false
    @State private var showLaunchFlow = true

    var body: some View {
        Group {
            switch viewModel.selectedTab {
            case .home:
                HomeView()
            case .favorites:
                FavoritesView()
            case .cart:
                CartFlowView(isPresented: .constant(true))
            case .orders:
                OrdersView()
            case .profile:
                ProfileView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ReferenceTabBar(selectedTab: $viewModel.selectedTab)
        }
        .fullScreenCover(isPresented: $showLaunchFlow) {
            LaunchFlowView(isPresented: $showLaunchFlow)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var isSearchPresented = false
    @State private var isShowingAddressSelector = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HomeHeader(
                        address: viewModel.selectedAddress,
                        onAddressTap: { isShowingAddressSelector = true }
                    )

                    Button {
                        isSearchPresented = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(AppTheme.subtleText)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Restoran, ürün veya mağaza ara")
                                    .foregroundStyle(AppTheme.ink)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                Text("Burger, market, kahve...")
                                    .foregroundStyle(AppTheme.subtleText)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 14, y: 8)
                        )
                    }
                    .buttonStyle(.plain)

                    ShortcutGrid(shortcuts: viewModel.shortcuts)

                    NavigationLink {
                        CampaignsView()
                    } label: {
                        CampaignHeroCard(campaigns: viewModel.campaigns)
                    }
                    .buttonStyle(.plain)

                    SectionHeader(title: "30 dakikada kapında", actionLabel: "Kampanyalar") {
                        CampaignsView()
                    }

                    VStack(spacing: 14) {
                        ForEach(viewModel.fastDeliveryVendors.prefix(3)) { vendor in
                            NavigationLink {
                                RestaurantDetailView(vendor: vendor)
                            } label: {
                                VendorCard(vendor: vendor, compact: false)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    SectionHeader(title: "Markette hızlı teslimat", actionLabel: "Tümünü gör") {
                        MarketListView()
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(viewModel.markets) { vendor in
                                NavigationLink {
                                    RestaurantDetailView(vendor: vendor)
                                } label: {
                                    MarketCard(vendor: vendor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }

                    SectionHeader(title: "Sana özel lezzetler", actionLabel: "") {
                    }

                    VStack(spacing: 14) {
                        ForEach(viewModel.featuredRestaurants) { vendor in
                            NavigationLink {
                                RestaurantDetailView(vendor: vendor)
                            } label: {
                                VendorCard(vendor: vendor, compact: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isSearchPresented) {
            SearchView()
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $isShowingAddressSelector) {
            AddressSelectionView(isPresented: $isShowingAddressSelector)
        }
    }
}

struct SearchView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    private let recentSearches = ["Burger", "Döner", "Market", "Protein bowl"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.subtleText)

                        TextField("Ürün, restoran veya market ara", text: $viewModel.searchText)
                            .textInputAutocapitalization(.never)

                        if !viewModel.searchText.isEmpty {
                            Button {
                                viewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppTheme.subtleText)
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                    )

                    if viewModel.searchText.isEmpty {
                        Text("Son aramalar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        FlexibleChips(items: recentSearches)

                        Text("Öne çıkan ürünler")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        VStack(spacing: 12) {
                            ForEach(viewModel.suggestedProducts) { product in
                                SuggestedProductRow(product: product)
                            }
                        }

                        Text("Popüler mağazalar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        VStack(spacing: 14) {
                            ForEach(viewModel.allVendors) { vendor in
                                NavigationLink {
                                    RestaurantDetailView(vendor: vendor)
                                } label: {
                                    VendorCard(vendor: vendor, compact: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                        Text("Sonuçlar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        if viewModel.searchResults.isEmpty {
                            EmptyStateView(
                                title: "Sonuç bulunamadı",
                                subtitle: "\"\(viewModel.searchText)\" için farklı bir arama dene.",
                                systemImage: "magnifyingglass.circle.fill"
                            )
                        } else {
                            VStack(spacing: 14) {
                                ForEach(viewModel.searchResults) { vendor in
                                    NavigationLink {
                                        RestaurantDetailView(vendor: vendor)
                                    } label: {
                                        VendorCard(vendor: vendor, compact: false)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle("Ara")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct OrdersView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var selectedScope: VendorKind = .restaurant
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ReferenceHeader(title: "Siparişlerim")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            OrdersSegmentButton(
                                title: "Yemek",
                                isSelected: selectedScope == .restaurant
                            ) {
                                selectedScope = .restaurant
                            }

                            OrdersSegmentButton(
                                title: "Hızlı Market",
                                isSelected: selectedScope == .market
                            ) {
                                selectedScope = .market
                            }
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(AppTheme.referenceText)

                            TextField("Siparişlerimde ara", text: $searchText)
                                .font(.system(size: 17, weight: .regular))
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(AppTheme.searchBar)
                        )

                        HStack(spacing: 12) {
                            Image(systemName: "seal.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(AppTheme.bannerGold)
                                .overlay(
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                )

                            HStack(spacing: 0) {
                                Text("Siparişini değerlendir, ")
                                    .foregroundStyle(AppTheme.ink)
                                Text("20 Go Plus Puan")
                                    .foregroundStyle(AppTheme.orange)
                                Text(" kazan!")
                                    .foregroundStyle(AppTheme.ink)
                            }
                            .font(.system(size: 15, weight: .semibold))

                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.55))
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(AppTheme.referenceDivider)
                                .frame(height: 1)
                        }

                        if filteredOrders.isEmpty {
                            EmptyStateView(
                                title: "Sipariş bulunamadı",
                                subtitle: "Aramanı temizleyip tekrar deneyebilirsin.",
                                systemImage: "list.bullet.clipboard"
                            )
                            .padding(.top, 36)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredOrders) { order in
                                    ReferenceOrderCard(order: order) {
                                        viewModel.reorder(order)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .background(AppTheme.referenceBackground.ignoresSafeArea())
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var filteredOrders: [Order] {
        let categoryFiltered = viewModel.pastOrders.filter { order in
            switch selectedScope {
            case .market:
                return order.kind == .market
            default:
                return order.kind != .market
            }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return categoryFiltered }

        return categoryFiltered.filter { order in
            order.vendorName.localizedCaseInsensitiveContains(query) ||
            (order.itemSummary ?? "").localizedCaseInsensitiveContains(query)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ReferenceHeader(title: "Hesabım")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(AccountMenuItem.items) { item in
                            NavigationLink {
                                item.destination
                            } label: {
                                AccountRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }

                        VStack(spacing: 0) {
                            Text("v1.2.31 (191)")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(AppTheme.versionText)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                                .frame(maxWidth: .infinity)

                            Color.clear
                                .frame(height: 108)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .background(AppTheme.referenceBackground.ignoresSafeArea())
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct ReferenceHeader: View {
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(AppTheme.referenceTitle)
                .frame(maxWidth: .infinity)
                .padding(.top, 18)
                .padding(.bottom, 16)

            Rectangle()
                .fill(AppTheme.referenceDivider)
                .frame(height: 1)
        }
        .background(Color.white)
    }
}

struct OrdersSegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isSelected ? AppTheme.orange : AppTheme.referenceText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(isSelected ? AppTheme.orange : AppTheme.segmentBorder, lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(Color.white)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct ReferenceOrderCard: View {
    let order: Order
    let onReorder: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(order.vendorName)
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.leading)

                    Text(order.dateLabel)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(AppTheme.referenceMuted)

                    HStack(spacing: 0) {
                        Text("Toplam: ")
                            .foregroundStyle(AppTheme.referenceMuted)
                        Text(order.totalText)
                            .foregroundStyle(AppTheme.orange)
                    }
                    .font(.system(size: 17, weight: .medium))
                }

                Spacer(minLength: 14)

                VStack(alignment: .trailing, spacing: 18) {
                    Button { } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(AppTheme.referenceTitle)
                            .frame(width: 58, height: 58)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 14, y: 6)
                            )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        OrderTrackingView(order: order)
                    } label: {
                        HStack(spacing: 6) {
                            Text("Detaylar")
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppTheme.orange)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 16)

            Rectangle()
                .fill(AppTheme.referenceDivider)
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.successGreen)

                    Text("\(max(order.deliveredItemCount, 1)) Ürün Teslim Edildi")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppTheme.successGreen)
                }

                HStack(spacing: 12) {
                    Button(action: onReorder) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Tekrarla")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(AppTheme.referenceTitle)
                        .frame(height: 44)
                        .frame(maxWidth: order.showsRatingAction ? 130 : 130)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(AppTheme.orange, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)

                    if order.showsRatingAction {
                        Button { } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Değerlendir & Bahşiş Ver")
                                    .font(.system(size: 15, weight: .medium))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AppTheme.buttonOrange)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text(order.itemSummary ?? order.defaultItemSummary)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppTheme.referenceMuted)
                    .lineLimit(2)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 18)
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

struct AccountRow: View {
    let item: AccountMenuItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.systemImage)
                .font(.system(size: 21, weight: .regular))
                .foregroundStyle(AppTheme.orange)
                .frame(width: 28)

            Text(item.title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppTheme.referenceTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            if let badge = item.badgeText {
                Text(badge)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .frame(height: 24)
                    .background(AppTheme.newBadgeRed, in: Capsule())
            }

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(height: 56)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ReferenceTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            ReferenceTabBarItem(
                title: "Keşfet",
                systemImage: "safari.fill",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            Spacer()

            ReferenceTabBarItem(
                title: "Favorilerim",
                systemImage: "heart.fill",
                isSelected: selectedTab == .favorites
            ) {
                selectedTab = .favorites
            }

            Spacer()

            ReferenceTabBarItem(
                title: "Sepetim",
                systemImage: "cart.fill",
                isSelected: selectedTab == .cart
            ) {
                selectedTab = .cart
            }

            Spacer()

            ReferenceTabBarItem(
                title: "Siparişlerim",
                systemImage: "list.clipboard.fill",
                isSelected: selectedTab == .orders
            ) {
                selectedTab = .orders
            }

            Spacer()

            ReferenceTabBarItem(
                title: "Hesabım",
                systemImage: "person.fill",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal, 34)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.referenceDivider)
                .frame(height: 1)
        }
    }
}

struct ReferenceTabBarItem: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .medium))
                Text(title)
                    .font(.system(size: 10, weight: .regular))
            }
            .foregroundStyle(isSelected ? AppTheme.orange : AppTheme.tabBarInactive)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct AccountMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let badgeText: String?
    let destination: AnyView

    static let items: [AccountMenuItem] = [
        AccountMenuItem(title: "Kullanıcı Bilgilerim", systemImage: "person", badgeText: nil, destination: AnyView(SimpleAccountView(title: "Kullanıcı Bilgilerim", subtitle: "Profil düzenleme bu prototipte mock bırakıldı."))),
        AccountMenuItem(title: "Adreslerim", systemImage: "mappin.and.ellipse", badgeText: nil, destination: AnyView(AddressListView())),
        AccountMenuItem(title: "Kayıtlı Kartlarım", systemImage: "creditcard", badgeText: nil, destination: AnyView(PaymentMethodsView())),
        AccountMenuItem(title: "İndirim Kuponlarım", systemImage: "ticket", badgeText: nil, destination: AnyView(CampaignsView())),
        AccountMenuItem(title: "E-Posta Değişikliği", systemImage: "envelope", badgeText: nil, destination: AnyView(SimpleAccountView(title: "E-Posta Değişikliği", subtitle: "E-posta güncelleme akışı mock içerikle gösteriliyor."))),
        AccountMenuItem(title: "Duyuru Tercihlerim", systemImage: "bell", badgeText: nil, destination: AnyView(NotificationsView())),
        AccountMenuItem(title: "Trendyol Go Seni Dinliyor", systemImage: "list.clipboard", badgeText: "YENI", destination: AnyView(SupportView())),
        AccountMenuItem(title: "Güvenlik", systemImage: "shield", badgeText: nil, destination: AnyView(SimpleAccountView(title: "Güvenlik", subtitle: "Şifre ve oturum ayarları burada gösterilebilir."))),
        AccountMenuItem(title: "Daha Fazla", systemImage: "ellipsis.circle", badgeText: nil, destination: AnyView(SimpleAccountView(title: "Daha Fazla", subtitle: "Ek ayarlar ve sık sorulanlar için alan."))),
        AccountMenuItem(title: "Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right", badgeText: nil, destination: AnyView(SimpleAccountView(title: "Çıkış Yap", subtitle: "Bu demo sürümünde çıkış işlemi mock olarak bırakıldı.")))
    ]
}

struct SimpleAccountView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Circle()
                .fill(AppTheme.orangeSoft)
                .frame(width: 92, height: 92)
                .overlay(
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(AppTheme.orange)
                )
            Text(title)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppTheme.referenceTitle)
            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.referenceMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.referenceBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RestaurantDetailView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    let vendor: Vendor
    @State private var selectedProduct: Product?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VendorHero(vendor: vendor)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label(vendor.eta, systemImage: "clock.fill")
                        Spacer()
                        Label("\(vendor.rating, specifier: "%.1f")", systemImage: "star.fill")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)

                    Text(vendor.promoText)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    HStack(spacing: 8) {
                        ForEach(vendor.tags, id: \.self) { tag in
                            TagPill(text: tag, tint: vendor.theme.softTint)
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                )

                ForEach(vendor.menuSections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        ForEach(section.products) { product in
                            ProductRow(
                                vendor: vendor,
                                product: product,
                                onSelect: { selectedProduct = product },
                                onQuickAdd: {
                                    viewModel.addToCart(product: product, from: vendor)
                                }
                            )
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(vendor.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFavorite(for: vendor)
                } label: {
                    Image(systemName: currentVendorState.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(AppTheme.orange)
                }
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailSheet(vendor: vendor, product: product)
                .presentationDetents([.fraction(0.92)])
                .environmentObject(viewModel)
        }
    }

    private var currentVendorState: Vendor {
        viewModel.allVendors.first(where: { $0.id == vendor.id }) ?? vendor
    }
}

struct ProductDetailSheet: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Environment(\.dismiss) private var dismiss

    let vendor: Vendor
    let product: Product

    @State private var quantity: Int
    @State private var note: String
    @State private var selections: [UUID: String]

    init(vendor: Vendor, product: Product) {
        self.vendor = vendor
        self.product = product
        _quantity = State(initialValue: 1)
        _note = State(initialValue: "")
        _selections = State(
            initialValue: Dictionary(
                uniqueKeysWithValues: product.optionGroups.compactMap { group in
                    guard let first = group.options.first else { return nil }
                    return (group.id, first)
                }
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(product.theme.gradient)
                        .frame(height: 220)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: product.systemImage)
                                    .font(.system(size: 54, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(product.name)
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.description)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)

                        if let badge = product.badge {
                            TagPill(text: badge, tint: product.theme.softTint)
                        }
                    }

                    ForEach(product.optionGroups) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            FlexibleSelectableChips(
                                items: group.options,
                                selection: Binding(
                                    get: { selections[group.id] ?? group.options.first ?? "" },
                                    set: { selections[group.id] = $0 }
                                ),
                                tint: product.theme.softTint
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sipariş notu")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        TextField("Örn. Soğansız olsun", text: $note, axis: .vertical)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white)
                            )
                    }

                    HStack(spacing: 12) {
                        CounterButton(symbol: "minus") {
                            quantity = max(1, quantity - 1)
                        }

                        Text("\(quantity)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .frame(minWidth: 36)

                        CounterButton(symbol: "plus") {
                            quantity += 1
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 90)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.orange)
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryActionButton(
                    title: "\(quantity) adet ekle",
                    subtitle: (product.price * Double(quantity)).formatted(.currency(code: "TRY"))
                ) {
                    let selected = product.optionGroups.compactMap { group in
                        selections[group.id]
                    }
                    viewModel.addToCart(
                        product: product,
                        from: vendor,
                        selectedOptions: selected,
                        note: note,
                        quantity: quantity
                    )
                    dismiss()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
    }
}

struct CartFlowView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            CartView(isPresented: $isPresented)
        }
    }
}

struct CartView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.cartItems.isEmpty {
                EmptyStateView(
                    title: "Sepetin boş",
                    subtitle: "Ana sayfadan ürün eklediğinde burada görünecek.",
                    systemImage: "cart.fill"
                )
                .padding(.top, 80)
            } else {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.cartVendorName ?? "Sepet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                        Text("Teslimat adresi: \(viewModel.selectedAddress.title)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)
                    }

                    VStack(spacing: 12) {
                        ForEach(viewModel.cartItems) { item in
                            CartItemRow(item: item)
                        }
                    }

                    PriceSummaryCard(
                        subtotal: viewModel.cartSubtotal,
                        delivery: viewModel.cartDeliveryFee,
                        service: viewModel.cartServiceFee,
                        discount: viewModel.cartDiscount,
                        total: viewModel.cartTotal
                    )
                }
                .padding(16)
                .padding(.bottom, 90)
            }
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Sepetim")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if !viewModel.cartItems.isEmpty {
                NavigationLink {
                    CheckoutView(isPresented: $isPresented)
                } label: {
                    HStack {
                        Text("Ödemeye geç")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Spacer()
                        Text(viewModel.cartTotal.formatted(.currency(code: "TRY")))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(AppTheme.orange, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
    }
}

struct CheckoutView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                CheckoutSection(title: "Teslimat adresi") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.selectedAddress.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                        Text(viewModel.selectedAddress.line1)
                        Text(viewModel.selectedAddress.detail)
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
                }

                CheckoutSection(title: "Ödeme yöntemi") {
                    ForEach(viewModel.userProfile.paymentMethods) { method in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(method.title)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                                Text(method.detail)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.subtleText)
                            }
                            Spacer()
                            if method.isDefault {
                                TagPill(text: "Varsayılan", tint: AppTheme.orangeSoft)
                            }
                        }
                    }
                }

                CheckoutSection(title: "Sipariş özeti") {
                    PriceSummaryCard(
                        subtotal: viewModel.cartSubtotal,
                        delivery: viewModel.cartDeliveryFee,
                        service: viewModel.cartServiceFee,
                        discount: viewModel.cartDiscount,
                        total: viewModel.cartTotal
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 90)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Ödeme")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            PrimaryActionButton(
                title: "Siparişi onayla",
                subtitle: viewModel.cartTotal.formatted(.currency(code: "TRY"))
            ) {
                viewModel.placeOrder()
                isPresented = false
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }
}

struct OrderTrackingView: View {
    let order: Order

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.orange.opacity(0.22), AppTheme.orange.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 210)
                    .overlay(
                        VStack(alignment: .leading, spacing: 12) {
                            Label(order.statusLabel, systemImage: "location.fill")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.orange)

                            Text(order.vendorName)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            Text("Tahmini teslimat: \(order.etaRange)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            Spacer()

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Teslimat adresi")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.subtleText)
                                    Text(order.addressLine)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppTheme.ink)
                                }
                                Spacer()
                            }
                        }
                        .padding(20)
                    )

                if let courier = order.courier {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kurye bilgisi")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        HStack(spacing: 14) {
                            Circle()
                                .fill(AppTheme.orangeSoft)
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Image(systemName: "scooter")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(AppTheme.orange)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(courier.name)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                                Text("\(courier.vehicle) • \(courier.plate)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.subtleText)
                                Text(courier.etaNote)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.orange)
                            }

                            Spacer()
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                    )
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Sipariş durumu")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    ForEach(Array(order.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(index <= order.activeStep ? AppTheme.orange : AppTheme.orangeSoft)
                                    .frame(width: 34, height: 34)

                                Image(systemName: step.symbol)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(index <= order.activeStep ? .white : AppTheme.orange)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.title)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                                Text(step.detail)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.subtleText)
                            }

                            Spacer()
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                )

                CheckoutSection(title: "Sipariş içeriği") {
                    VStack(spacing: 10) {
                        ForEach(order.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(item.quantity)x \(item.product.name)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.ink)
                                    if !item.selectedOptions.isEmpty {
                                        Text(item.selectedOptions.joined(separator: ", "))
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundStyle(AppTheme.subtleText)
                                    }
                                }
                                Spacer()
                                Text((item.product.price * Double(item.quantity)).formatted(.currency(code: "TRY")))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Sipariş Takibi")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FavoritesView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ReferenceHeader(title: "Favorilerim")

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if viewModel.favoriteVendors.isEmpty {
                            EmptyStateView(
                                title: "Henüz favorin yok",
                                subtitle: "Kalp ikonuna basarak mağazaları burada toplayabilirsin.",
                                systemImage: "heart.fill"
                            )
                            .padding(.top, 80)
                        } else {
                            ForEach(viewModel.favoriteVendors) { vendor in
                                NavigationLink {
                                    RestaurantDetailView(vendor: vendor)
                                } label: {
                                    VendorCard(vendor: vendor, compact: false)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
                .background(AppTheme.referenceBackground.ignoresSafeArea())
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct CampaignsView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(viewModel.campaigns) { campaign in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            TagPill(text: campaign.badge, tint: campaign.theme.softTint)
                            Spacer()
                            Image(systemName: "ticket.fill")
                                .foregroundStyle(campaign.theme.accent)
                        }

                        Text(campaign.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        Text(campaign.subtitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        Text(campaign.detail)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [campaign.theme.softTint, Color.white],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Kampanyalar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddressListView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(viewModel.userProfile.addresses) { address in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(address.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Spacer()
                            if address.isCurrent {
                                TagPill(text: "Aktif", tint: AppTheme.orangeSoft)
                            }
                        }
                        Text(address.line1)
                        Text(address.detail)
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white)
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Adreslerim")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaymentMethodsView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(viewModel.userProfile.paymentMethods) { method in
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(method.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Text(method.detail)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.subtleText)
                        }
                        Spacer()
                        if method.isDefault {
                            TagPill(text: "Varsayılan", tint: AppTheme.orangeSoft)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white)
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Ödeme Yöntemleri")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SupportView: View {
    private let items = [
        ("Canlı destek", "Sipariş ve teslimat sorunları", "message.fill"),
        ("İade ve eksik ürün", "Market siparişleri için hızlı çözüm", "arrow.uturn.backward.circle.fill"),
        ("Ödeme yardımı", "Kart ve cüzdan işlemleri", "creditcard.circle.fill")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(items, id: \.0) { item in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(AppTheme.orangeSoft)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: item.2)
                                    .foregroundStyle(AppTheme.orange)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.0)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Text(item.1)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.subtleText)
                        }

                        Spacer()
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white)
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Yardım Merkezi")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MarketListView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(viewModel.markets) { vendor in
                    NavigationLink {
                        RestaurantDetailView(vendor: vendor)
                    } label: {
                        VendorCard(vendor: vendor, compact: false)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Marketler")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum LaunchStage {
    case intro
    case phone
    case otp
}

struct LaunchFlowView: View {
    @Binding var isPresented: Bool
    @State private var stage: LaunchStage = .intro
    @State private var introIndex = 0
    @State private var phoneNumber = "+90 555 123 45 67"
    @State private var otpCode = "4382"

    private let introSlides = [
        ("30 dakikada kapında", "Yemek, market, su ve kahve siparişlerini tek akışta yönet.", "scooter"),
        ("Canlı sipariş takibi", "Kurye durumunu ve teslimat adımlarını gerçek zamanlı gör.", "location.fill"),
        ("Kupon ve kampanya", "Mock data ile kupon, cüzdan ve hızlı ödeme senaryolarını göster.", "ticket.fill")
    ]

    var body: some View {
        NavigationStack {
            Group {
                switch stage {
                case .intro:
                    introView
                case .phone:
                    phoneView
                case .otp:
                    otpView
                }
            }
            .background(AppTheme.canvas.ignoresSafeArea())
        }
    }

    private var introView: some View {
        VStack(spacing: 0) {
            TabView(selection: $introIndex) {
                ForEach(Array(introSlides.enumerated()), id: \.offset) { index, slide in
                    VStack(spacing: 22) {
                        Spacer()

                        Circle()
                            .fill(AppTheme.orangeSoft)
                            .frame(width: 124, height: 124)
                            .overlay(
                                Image(systemName: slide.2)
                                    .font(.system(size: 52, weight: .bold))
                                    .foregroundStyle(AppTheme.orange)
                            )

                        VStack(spacing: 10) {
                            Text(slide.0)
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                                .multilineTextAlignment(.center)

                            Text(slide.1)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.subtleText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 28)
                        }

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: 12) {
                PrimaryActionButton(title: "Devam et", subtitle: "Mock giriş") {
                    stage = .phone
                }

                Button("Atla") {
                    isPresented = false
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)
            }
            .padding(16)
        }
    }

    private var phoneView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text("Telefon numaran ile giriş yap")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.ink)

            Text("Ödev demosu için mock OTP akışı kullanılıyor.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

            TextField("+90 5xx xxx xx xx", text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )

            PrimaryActionButton(title: "Kod gönder", subtitle: "SMS doğrulama") {
                stage = .otp
            }

            Button("Geri") {
                stage = .intro
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(AppTheme.subtleText)

            Spacer()
        }
        .padding(16)
        .navigationBarBackButtonHidden(true)
    }

    private var otpView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text("Doğrulama kodu")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.ink)

            Text("\(phoneNumber) numarasına gönderilen kodu gir.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

            TextField("4382", text: $otpCode)
                .keyboardType(.numberPad)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )

            PrimaryActionButton(title: "Uygulamaya gir", subtitle: "Ana sayfa") {
                isPresented = false
            }

            Button("Kodu tekrar gönder") { }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.orange)

            Spacer()
        }
        .padding(16)
        .navigationBarBackButtonHidden(true)
    }
}

struct NotificationsView: View {
    private let notifications = [
        ("Siparişin yola çıktı", "Anadolu Döner siparişin 5 dakika içinde kapında.", "bicycle.circle.fill"),
        ("Yeni kupon tanımlandı", "250 TL ve üzeri siparişlerde 80 TL indirim aktif.", "ticket.fill"),
        ("Favori marketinde indirim", "Fresh Market gece teslimatta ücretsiz kurye sunuyor.", "bell.badge.fill")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(notifications, id: \.0) { item in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(AppTheme.orangeSoft)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: item.2)
                                    .foregroundStyle(AppTheme.orange)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.0)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Text(item.1)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.subtleText)
                        }

                        Spacer()
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white)
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HomeHeader: View {
    let address: Address
    let onAddressTap: () -> Void

    var body: some View {
        HStack {
            Button {
                // Settings/Profile could go here, replacing the X
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(AppTheme.ink)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onAddressTap) {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.orange)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Teslimat Adresi")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)
                        Text("\(address.title) (\(address.detail.prefix(10))..)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.orange)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(AppTheme.segmentBorder, lineWidth: 1.0)
                        .background(Color.white)
                )
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 16) {
                Button {
                    // Assistant
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "message.badge")
                            .font(.system(size: 20))
                        Text("Asistan")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.ink)
                }
                .buttonStyle(.plain)

                Button {
                    // Coupons
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "percent")
                            .font(.system(size: 14, weight: .bold))
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(AppTheme.canvas)
                            )
                        Text("Kuponlar")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.ink)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ShortcutGrid: View {
    let shortcuts: [CategoryShortcut]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(shortcuts) { shortcut in
                VStack(alignment: .leading, spacing: 10) {
                    Circle()
                        .fill(shortcut.theme.softTint)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: shortcut.systemImage)
                                .foregroundStyle(shortcut.theme.accent)
                        )

                    Text(shortcut.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                    Text(shortcut.subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.subtleText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                )
            }
        }
    }
}

struct CampaignHeroCard: View {
    let campaigns: [Campaign]

    var body: some View {
        let hero = campaigns[0]

        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(hero.theme.gradient)
            .frame(height: 176)
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        TagPill(text: hero.badge, tint: Color.white.opacity(0.18), foreground: .white)
                        Text(hero.title)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(hero.subtitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        Text("Tüm kampanyaları gör")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "scooter")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.white.opacity(0.92))
                }
                .padding(20)
            )
    }
}

struct SectionHeader<Destination: View>: View {
    let title: String
    let actionLabel: String
    let destination: Destination

    init(title: String, actionLabel: String, @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.actionLabel = actionLabel
        self.destination = destination()
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Spacer()
            NavigationLink {
                destination
            } label: {
                Text(actionLabel)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.orange)
            }
        }
    }
}

struct VendorCard: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    let vendor: Vendor
    let compact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(vendor.theme.gradient)
                .frame(height: compact ? 124 : 146)
                .overlay(
                    VStack(alignment: .leading) {
                        HStack {
                            TagPill(text: vendor.kind.rawValue, tint: Color.white.opacity(0.18), foreground: .white)
                            Spacer()
                            Button {
                                viewModel.toggleFavorite(for: vendor)
                            } label: {
                                Image(systemName: currentVendor.isFavorite ? "heart.fill" : "heart")
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(Color.white.opacity(0.15), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()

                        Text(vendor.name)
                            .font(.system(size: compact ? 24 : 26, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(vendor.coverNote)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.92))
                    }
                    .padding(18)
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Label(vendor.eta, systemImage: "clock.fill")
                    Label("\(vendor.rating, specifier: "%.1f")", systemImage: "star.fill")
                    Label("\(vendor.reviewCount)", systemImage: "person.2.fill")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

                Text(vendor.summary)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ink)

                HStack(spacing: 8) {
                    ForEach(vendor.tags.prefix(3), id: \.self) { tag in
                        TagPill(text: tag, tint: vendor.theme.softTint)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 14, y: 8)
        )
    }

    private var currentVendor: Vendor {
        viewModel.allVendors.first(where: { $0.id == vendor.id }) ?? vendor
    }
}

struct MarketCard: View {
    let vendor: Vendor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(vendor.theme.gradient)
                .frame(width: 220, height: 118)
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        Text(vendor.name)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(vendor.coverNote)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.92))
                        Spacer()
                        TagPill(text: vendor.eta, tint: Color.white.opacity(0.18), foreground: .white)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                )

            Text(vendor.promoText)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
        }
        .frame(width: 220, alignment: .leading)
    }
}

struct VendorHero: View {
    let vendor: Vendor

    var body: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(vendor.theme.gradient)
            .frame(height: 240)
            .overlay(
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        TagPill(text: vendor.kind.rawValue, tint: Color.white.opacity(0.18), foreground: .white)
                        Spacer()
                        Text(vendor.minimumBasket.formatted(.currency(code: "TRY")))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Text(vendor.name)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(vendor.summary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                }
                .padding(22)
            )
    }
}

struct ProductRow: View {
    let vendor: Vendor
    let product: Product
    let onSelect: () -> Void
    let onQuickAdd: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(product.theme.softTint)
                .frame(width: 88, height: 88)
                .overlay(
                    Image(systemName: product.systemImage)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(product.theme.accent)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(product.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(2)
                    Spacer()
                    if let badge = product.badge {
                        TagPill(text: badge, tint: product.theme.softTint)
                    }
                }

                Text(product.description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
                    .lineLimit(3)

                HStack {
                    Text(product.price.formatted(.currency(code: "TRY")))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    Spacer()

                    Button(action: onQuickAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(AppTheme.orange, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}

struct SuggestedProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(product.theme.softTint)
                .frame(width: 54, height: 54)
                .overlay(
                    Image(systemName: product.systemImage)
                        .foregroundStyle(product.theme.accent)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text(product.description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
                    .lineLimit(2)
            }

            Spacer()

            Text(product.price.formatted(.currency(code: "TRY")))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct ActiveOrderCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.vendorName)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                    Text(order.statusLabel)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.orange)
                }
                Spacer()
                TagPill(text: order.etaRange, tint: AppTheme.orangeSoft)
            }

            ForEach(Array(order.steps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 10) {
                    Circle()
                        .fill(index <= order.activeStep ? AppTheme.orange : AppTheme.orangeSoft)
                        .frame(width: 10, height: 10)

                    Text(step.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(index <= order.activeStep ? AppTheme.ink : AppTheme.subtleText)
                }
            }

            HStack {
                Label(order.dateLabel, systemImage: "clock.fill")
                Spacer()
                Text(order.total.formatted(.currency(code: "TRY")))
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(AppTheme.subtleText)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 14, y: 8)
        )
    }
}

struct OrderHistoryCard: View {
    let order: Order
    let onRepeat: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.vendorName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                    Text(order.dateLabel)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.subtleText)
                }
                Spacer()
                TagPill(text: order.statusLabel, tint: AppTheme.orangeSoft)
            }

            Text(order.items.map { "\($0.quantity)x \($0.product.name)" }.joined(separator: ", "))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)
                .lineLimit(2)

            HStack {
                Text(order.total.formatted(.currency(code: "TRY")))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Button("Tekrar Sipariş") {
                    onRepeat()
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.orange, in: Capsule())
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct CartItemRow: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    let item: CartItem

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(item.product.theme.softTint)
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: item.product.systemImage)
                        .foregroundStyle(item.product.theme.accent)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(item.product.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)

                if !item.selectedOptions.isEmpty {
                    Text(item.selectedOptions.joined(separator: ", "))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.subtleText)
                }

                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.orange)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 10) {
                Text((item.product.price * Double(item.quantity)).formatted(.currency(code: "TRY")))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)

                HStack(spacing: 10) {
                    CounterButton(symbol: "minus") {
                        viewModel.decrementQuantity(for: item)
                    }
                    Text("\(item.quantity)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    CounterButton(symbol: "plus") {
                        viewModel.incrementQuantity(for: item)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct PriceSummaryCard: View {
    let subtotal: Double
    let delivery: Double
    let service: Double
    let discount: Double
    let total: Double

    var body: some View {
        VStack(spacing: 12) {
            SummaryRow(label: "Ara toplam", value: subtotal)
            SummaryRow(label: "Teslimat", value: delivery)
            SummaryRow(label: "Servis", value: service)
            SummaryRow(label: "İndirim", value: -discount, isDiscount: true)

            Divider()

            HStack {
                Text("Toplam")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text(total.formatted(.currency(code: "TRY")))
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct CheckoutSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct ProfileRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(AppTheme.orangeSoft)
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: systemImage)
                        .foregroundStyle(AppTheme.orange)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.subtleText)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.canvas)
        )
    }
}

struct HeaderIconButton: View {
    let systemImage: String

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 42, height: 42)
            .overlay(
                Image(systemName: systemImage)
                    .foregroundStyle(AppTheme.ink)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
    }
}

struct CartDockButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                }
                Spacer()
                Image(systemName: "cart.fill")
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(AppTheme.orange, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Text(subtitle)
                    .font(.system(size: 15, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(AppTheme.orange, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SummaryRow: View {
    let label: String
    let value: Double
    var isDiscount: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)
            Spacer()
            Text(value.formatted(.currency(code: "TRY")))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(isDiscount ? AppTheme.orange : AppTheme.ink)
        }
    }
}

struct CounterButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.orange)
                .frame(width: 28, height: 28)
                .background(AppTheme.orangeSoft, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

struct TagPill: View {
    let text: String
    let tint: Color
    var foreground: Color = AppTheme.ink

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint, in: Capsule())
    }
}

struct FlexibleChips: View {
    let items: [String]

    var body: some View {
        FlexibleStack(items: items) { item in
            TagPill(text: item, tint: Color.white)
        }
    }
}

struct FlexibleSelectableChips: View {
    let items: [String]
    @Binding var selection: String
    let tint: Color

    var body: some View {
        FlexibleStack(items: items) { item in
            Button {
                selection = item
            } label: {
                Text(item)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(selection == item ? .white : AppTheme.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(selection == item ? AppTheme.orange : tint, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

struct FlexibleStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 84), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 14) {
            Circle()
                .fill(AppTheme.orangeSoft)
                .frame(width: 84, height: 84)
                .overlay(
                    Image(systemName: systemImage)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AppTheme.orange)
                )

            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text(subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}

private extension Order {
    var totalText: String {
        if total == floor(total) {
            return "\(Int(total)) TL"
        }

        return total.formatted(
            .number
                .precision(.fractionLength(2))
                .locale(Locale(identifier: "tr_TR"))
        ) + " TL"
    }

    var defaultItemSummary: String {
        if items.count == 1, let item = items.first {
            return "\(item.product.name) (\(item.quantity) Adet)"
        }

        return items.map { "\($0.product.name) (\($0.quantity) Adet)" }.joined(separator: ", ")
    }
}

enum AppTheme {
    static let orange = Color(red: 0.96, green: 0.47, blue: 0.11)
    static let orangeSoft = Color(red: 1.0, green: 0.94, blue: 0.88)
    static let canvas = Color(red: 0.97, green: 0.97, blue: 0.96)
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let subtleText = Color(red: 0.45, green: 0.47, blue: 0.53)
    static let referenceBackground = Color(red: 0.968, green: 0.968, blue: 0.968)
    static let referenceDivider = Color(red: 0.86, green: 0.86, blue: 0.86)
    static let referenceText = Color(red: 0.24, green: 0.24, blue: 0.24)
    static let referenceTitle = Color(red: 0.20, green: 0.20, blue: 0.21)
    static let referenceMuted = Color(red: 0.48, green: 0.48, blue: 0.49)
    static let versionText = Color(red: 0.66, green: 0.66, blue: 0.67)
    static let segmentBorder = Color(red: 0.84, green: 0.84, blue: 0.84)
    static let searchBar = Color(red: 0.93, green: 0.93, blue: 0.93)
    static let bannerGold = Color(red: 0.95, green: 0.73, blue: 0.22)
    static let buttonOrange = Color(red: 0.90, green: 0.53, blue: 0.21)
    static let successGreen = Color(red: 0.33, green: 0.76, blue: 0.41)
    static let cardBorder = Color(red: 0.84, green: 0.84, blue: 0.84)
    static let newBadgeRed = Color(red: 0.81, green: 0.18, blue: 0.18)
    static let tabBarInactive = Color(red: 0.66, green: 0.66, blue: 0.67)
}

private extension VendorTheme {
    var accent: Color {
        switch self {
        case .orange:
            return Color(red: 0.96, green: 0.47, blue: 0.11)
        case .amber:
            return Color(red: 0.96, green: 0.62, blue: 0.08)
        case .green:
            return Color(red: 0.17, green: 0.63, blue: 0.37)
        case .teal:
            return Color(red: 0.12, green: 0.66, blue: 0.63)
        case .blue:
            return Color(red: 0.18, green: 0.46, blue: 0.86)
        case .red:
            return Color(red: 0.87, green: 0.25, blue: 0.29)
        }
    }

    var softTint: Color {
        accent.opacity(0.12)
    }

    var gradient: LinearGradient {
        switch self {
        case .orange:
            return LinearGradient(colors: [Color(red: 0.99, green: 0.58, blue: 0.19), Color(red: 0.95, green: 0.40, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .amber:
            return LinearGradient(colors: [Color(red: 0.99, green: 0.72, blue: 0.19), Color(red: 0.97, green: 0.49, blue: 0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .green:
            return LinearGradient(colors: [Color(red: 0.29, green: 0.76, blue: 0.45), Color(red: 0.12, green: 0.57, blue: 0.30)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .teal:
            return LinearGradient(colors: [Color(red: 0.21, green: 0.82, blue: 0.75), Color(red: 0.08, green: 0.55, blue: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .blue:
            return LinearGradient(colors: [Color(red: 0.34, green: 0.60, blue: 0.96), Color(red: 0.14, green: 0.38, blue: 0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .red:
            return LinearGradient(colors: [Color(red: 0.97, green: 0.41, blue: 0.39), Color(red: 0.78, green: 0.18, blue: 0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct AddressSelectionView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Düzenle butonuna basarak konumunu ve adres bilgilerini düzenleyebilir veya adresini silebilirsin.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                VStack(spacing: 12) {
                    Button {
                        // Mevcut konum action
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "location.circle")
                                .font(.system(size: 18))
                            Text("Mevcut Konumumu Kullan")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(AppTheme.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AppTheme.segmentBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // Yeni adres ekle action
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 18))
                            Text("Yeni Adres Ekle")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(AppTheme.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AppTheme.segmentBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(viewModel.userProfile.addresses) { address in
                            AddressSelectionCard(
                                address: address,
                                isSelected: viewModel.selectedAddress.id == address.id,
                                onSelect: {
                                    viewModel.selectedAddress = address
                                    isPresented = false
                                }
                            )
                        }
                    }
                    .padding(16)
                }
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle("Teslimat Adresi Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(AppTheme.subtleText)
                            .font(.system(size: 20))
                    }
                }
            }
        }
    }
}

struct AddressSelectionCard: View {
    let address: Address
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    // Radio button
                    ZStack {
                        Circle()
                            .stroke(isSelected ? AppTheme.orange : AppTheme.subtleText, lineWidth: 2)
                            .frame(width: 20, height: 20)
                        
                        if isSelected {
                            Circle()
                                .fill(AppTheme.orange)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(address.title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Spacer()
                            Button {
                                // Düzenle action
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 12))
                                    Text("Düzenle")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                }
                                .foregroundStyle(AppTheme.orange)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Text("\(address.line1)\n\(address.detail)")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(16)
                
                // Optional map view mockup if it's the current selected one? 
                if isSelected && address.title.lowercased() == "ev" {
                    Rectangle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.successGreen)
                        )
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? AppTheme.orange : AppTheme.segmentBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}

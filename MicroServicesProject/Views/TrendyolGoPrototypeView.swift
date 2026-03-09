import Combine
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
    @State private var searchSuggestionIndex = 0

    private let searchSuggestionTimer = Timer.publish(every: 2.8, on: .main, in: .common).autoconnect()

    private var activeSearchSuggestion: String {
        guard !viewModel.homeSearchSuggestions.isEmpty else { return "Döner ara" }
        return viewModel.homeSearchSuggestions[searchSuggestionIndex % viewModel.homeSearchSuggestions.count]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.referenceBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        HomePrimaryServiceGrid(cards: viewModel.homePrimaryServices)

                        HomeMiniServiceRow(cards: viewModel.homeMiniServices)

                        HomeSectionBlock(
                            title: "Mutfaklar",
                            actionTitle: "Tümünü Gör"
                        ) {
                            HomeCuisineRow(cuisines: viewModel.homeCuisines)
                        }

                        HomeBannerCarousel(banners: viewModel.homeHeroBanners)

                        HomeRewardsCard(rewards: viewModel.homeRewardsOverview)

                        HomeSectionBlock(
                            title: "Sana Özel Restoranlar",
                            systemImage: "heart.fill",
                            iconTint: Color(red: 0.85, green: 0.07, blue: 0.22),
                            actionTitle: "Tümünü Gör"
                        ) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.homePersonalRestaurants) { card in
                                        HomeRestaurantSpotlightCard(card: card)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        HomeSectionBlock(
                            title: "Kampanyalı Restoranlar",
                            systemImage: "percent",
                            iconTint: AppTheme.bannerGold,
                            actionTitle: "Tümünü Gör"
                        ) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.homeCampaignRestaurants) { card in
                                        HomeRestaurantSpotlightCard(card: card)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        HomeSectionBlock(title: "Sana Özel Marketler") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.homeMarkets) { market in
                                        HomeMarketSpotlightCard(card: market)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        HomeSectionBlock(title: "Öne Çıkan Fırsatlar") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.homeOpportunities) { deal in
                                        HomeOpportunitySpotlightCard(card: deal)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 74)
                    .background(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(AppTheme.referenceBackground)
                    )
                }
                .scrollClipDisabled()
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 10) {
                    TrendyolGoHomeHeader(
                        address: viewModel.selectedAddress,
                        onAddressTap: { isShowingAddressSelector = true }
                    )

                    Button {
                        isSearchPresented = true
                    } label: {
                        HomeSearchBar(placeholder: activeSearchSuggestion)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 3)
                .padding(.bottom, 7)
                .background(AppTheme.orange)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $isSearchPresented) {
            SearchView()
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $isShowingAddressSelector) {
            AddressSelectionView(isPresented: $isShowingAddressSelector)
        }
        .onReceive(searchSuggestionTimer) { _ in
            guard !viewModel.homeSearchSuggestions.isEmpty else { return }
            searchSuggestionIndex = (searchSuggestionIndex + 1) % viewModel.homeSearchSuggestions.count
        }
    }
}

struct TrendyolGoHomeHeader: View {
    let address: Address
    let onAddressTap: () -> Void

    private var addressText: String {
        "\(address.title) (\(address.detail))"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom, spacing: 0) {
                    Text("trendyol")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                    Text("go")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                    HomeLogoSpeedLines()
                        .padding(.leading, 1)
                        .padding(.bottom, 7)
                }
                Text("by Uber Eats")
                    .font(.system(size: 14.5, weight: .black))
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }
            .frame(width: 104, alignment: .leading)
            .layoutPriority(1)

            Button(action: onAddressTap) {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(AppTheme.orange)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Teslimat Adresi")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundStyle(AppTheme.referenceText)
                        Text(addressText)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                NotificationsView()
            } label: {
                VStack(spacing: 0) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(AppTheme.referenceTitle)
                    Text("Bildirimler")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppTheme.referenceTitle)
                }
                .frame(width: 58)
            }
            .buttonStyle(.plain)
            .frame(width: 54)
        }
    }
}

struct HomeSearchBar: View {
    let placeholder: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(AppTheme.orange)

            Text(placeholder)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.referenceMuted)

            Spacer()
        }
        .padding(.horizontal, 18)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 27, style: .continuous)
                .fill(AppTheme.searchBar)
        )
    }
}

struct HomeLogoSpeedLines: View {
    var body: some View {
        VStack(spacing: 2) {
            Capsule()
                .fill(Color.white)
                .frame(width: 12, height: 2)
            Capsule()
                .fill(Color.white)
                .frame(width: 8, height: 2)
            Capsule()
                .fill(Color.white)
                .frame(width: 4, height: 2)
        }
    }
}

struct HomePrimaryServiceGrid: View {
    let cards: [HomePrimaryService]

    var body: some View {
        HStack(spacing: 10) {
            if cards.indices.contains(0), cards.indices.contains(2) {
                VStack(spacing: 10) {
                    HomePrimaryServiceCard(card: cards[0], isTall: false)
                    HomePrimaryServiceCard(card: cards[2], isTall: true)
                }
            }

            if cards.indices.contains(1) {
                HomePrimaryServiceCard(card: cards[1], isTall: true)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct HomePrimaryServiceCard: View {
    let card: HomePrimaryService
    let isTall: Bool

    private var cardHeight: CGFloat {
        if card.style == .water { return 86 }
        return isTall ? 266 : 170
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundColor)

                VStack(alignment: .leading, spacing: 0) {
                    if card.style != .water {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(titleBackgroundColor)
                            .frame(height: 92)
                            .overlay(
                                VStack(spacing: 5) {
                                    Text(card.title)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(titleColor)
                                    Text(card.subtitle)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(subtitleColor)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .padding(.horizontal, 8)
                            )
                            .padding(.horizontal, 10)
                            .padding(.top, 0)
                    } else {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(red: 0.22, green: 0.73, blue: 0.90))
                            .frame(height: 64)
                            .overlay(
                                Text(card.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.leading)
                            )
                            .padding(.horizontal, 0)
                            .padding(.top, 0)
                    }

                    Spacer(minLength: 0)
                }

                switch card.style {
                case .quickMarket:
                    HomeRemoteImage(urlString: card.imageURL, artwork: card.artwork)
                        .frame(width: width * 0.93, height: 108)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .offset(x: width * 0.035, y: 62)

                case .food:
                    HomeRemoteImage(urlString: card.imageURL, artwork: .burger)
                        .frame(width: width * 0.93, height: 148)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .offset(x: width * 0.035, y: 112)

                case .water:
                    HomeRemoteImage(urlString: card.imageURL, artwork: .water)
                        .frame(width: width * 0.38, height: 58)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .offset(x: width * 0.58, y: 22)
                }
            }
        }
        .frame(height: cardHeight)
    }

    private var backgroundColor: Color {
        switch card.style {
        case .quickMarket:
            return Color(red: 0.78, green: 0.95, blue: 0.79)
        case .food:
            return Color(red: 0.95, green: 0.90, blue: 0.80)
        case .water:
            return Color(red: 0.70, green: 0.89, blue: 0.98)
        }
    }

    private var titleBackgroundColor: Color {
        switch card.style {
        case .quickMarket:
            return Color(red: 0.25, green: 0.80, blue: 0.16)
        case .food:
            return Color(red: 0.99, green: 0.64, blue: 0.01)
        case .water:
            return Color.clear
        }
    }

    private var titleColor: Color {
        switch card.style {
        case .quickMarket:
            return .white
        case .food:
            return .white
        case .water:
            return .white
        }
    }

    private var subtitleColor: Color {
        switch card.style {
        case .quickMarket:
            return .black
        case .food:
            return .black
        case .water:
            return .white
        }
    }
}

struct HomePrimaryBasketArt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.13, green: 0.74, blue: 0.16))
                .frame(height: 22)
                .offset(y: 38)

            HStack(spacing: 8) {
                Circle().fill(Color.orange).frame(width: 28, height: 28)
                Circle().fill(Color.yellow).frame(width: 24, height: 24)
                Circle().fill(Color.red).frame(width: 26, height: 26)
                RoundedRectangle(cornerRadius: 6).fill(Color.white).frame(width: 22, height: 34)
                RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.8)).frame(width: 18, height: 30)
            }
            .offset(y: 8)
        }
    }
}

struct HomeWaterBottleArt: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.50, green: 0.79, blue: 0.97))
                .frame(width: 64, height: 56)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.white)
                .frame(width: 16, height: 8)
                .offset(y: -52)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.5))
                .frame(width: 18, height: 32)
                .offset(x: -16, y: -8)
        }
    }
}

struct HomeMiniServiceRow: View {
    let cards: [HomeMiniService]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(cards) { card in
                    HomeMiniServiceCard(card: card)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct HomeMiniServiceCard: View {
    let card: HomeMiniService

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)

            VStack(alignment: .leading, spacing: 6) {
                Text(card.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.referenceTitle)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)

                Text(card.badgeText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.orange)
                    .padding(.horizontal, 8)
                    .frame(height: 18)
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.orange, lineWidth: 1.2)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .padding(.trailing, 28)

            HomeMiniServiceSticker(artwork: card.artwork)
                .frame(width: 58, height: 44)
                .offset(x: -2, y: -2)
        }
        .frame(width: 102, height: 88)
    }
}

struct HomeMiniServiceSticker: View {
    let artwork: HomeArtwork

    var body: some View {
        switch artwork {
        case .petShop:
            ZStack {
                Circle().fill(Color(red: 0.96, green: 0.97, blue: 0.99)).frame(width: 38, height: 38)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 0.11, green: 0.52, blue: 0.94))
            }

        case .grocery:
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.95, blue: 0.82))
                    .frame(width: 40, height: 30)
                    .offset(x: 8, y: 7)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 0.96, green: 0.83, blue: 0.28))
                    .frame(width: 18, height: 9)
                    .offset(x: 14, y: -2)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 0.88, green: 0.44, blue: 0.34))
                    .frame(width: 20, height: 10)
                    .offset(x: 18, y: 8)
            }

        case .produce:
            ZStack {
                Ellipse()
                    .fill(Color(red: 0.99, green: 0.84, blue: 0.26))
                    .frame(width: 28, height: 12)
                    .offset(x: 4, y: 10)
                Circle().fill(Color(red: 0.67, green: 0.82, blue: 0.35)).frame(width: 12, height: 12).offset(x: 15, y: 4)
                Circle().fill(Color(red: 0.95, green: 0.30, blue: 0.20)).frame(width: 12, height: 12).offset(x: 25, y: 6)
            }

        case .nuts:
            ZStack {
                ForEach(0..<7, id: \.self) { index in
                    Circle()
                        .fill(Color(red: 0.68, green: 0.42, blue: 0.15))
                        .frame(width: 10, height: 10)
                        .offset(
                            x: CGFloat((index % 3) * 10) + 8,
                            y: CGFloat((index / 3) * 10) + 2
                        )
                }
            }

        case .flowers:
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.95, blue: 0.98))
                    .frame(width: 38, height: 38)
                Image(systemName: "flower.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 0.95, green: 0.29, blue: 0.46))
            }

        default:
            Image(systemName: "tag.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.orange)
        }
    }
}

struct HomeCuisineRow: View {
    let cuisines: [HomeCuisine]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(cuisines) { cuisine in
                    HomeCuisineCard(cuisine: cuisine)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct HomeCuisineCard: View {
    let cuisine: HomeCuisine

    var body: some View {
        VStack(spacing: 7) {
            HomeRemoteImage(urlString: cuisine.imageURL, artwork: cuisine.artwork)
                .frame(width: 86, height: 86)
                .clipShape(Circle())

            Text(cuisine.title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(AppTheme.referenceTitle)
                .lineLimit(1)
        }
        .frame(width: 96, height: 126)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct HomeQuickFilterStrip: View {
    let filters: [HomeQuickFilter]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters) { filter in
                    HStack(spacing: 8) {
                        Image(systemName: filter.systemImage)
                            .font(.system(size: 13, weight: .semibold))
                        Text(filter.title)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.white.opacity(0.28))
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.58))
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct HomeBannerCarousel: View {
    let banners: [HomeHeroBanner]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(banners) { banner in
                    HomeHeroBannerCard(banner: banner)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct HomeHeroBannerCard: View {
    let banner: HomeHeroBanner

    var body: some View {
        Group {
            switch banner.style {
            case .uberOne:
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)

                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(banner.subtitle)
                                .font(.system(size: 8.5, weight: .semibold))
                                .foregroundStyle(AppTheme.referenceTitle)
                            Text(banner.title)
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(Color(red: 0.55, green: 0.36, blue: 0.02))
                                .multilineTextAlignment(.leading)
                            Text(banner.detail)
                                .font(.system(size: 5.8, weight: .medium))
                                .foregroundStyle(AppTheme.referenceMuted)
                                .lineLimit(2)

                            HStack(spacing: 8) {
                                Text(banner.ctaText)
                                    .font(.system(size: 8.5, weight: .black))
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 24)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.67, green: 0.46, blue: 0.05))
                            )
                        }

                        Spacer()

                        HomeBannerArtwork(style: .uberOne)
                            .frame(width: 118, height: 92)
                    }
                    .padding(12)
                }
                .frame(width: 270, height: 112)

            case .flashDiscount:
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.69, green: 0.84, blue: 0.39), Color(red: 0.54, green: 0.78, blue: 0.26)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(banner.title)
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                        HStack(spacing: 6) {
                            HomeDiscountBannerValueCard(minimumText: "250 TL ve üzerine", valueText: "100 TL", subtitle: "İNDİRİM")
                            HomeDiscountBannerValueCard(minimumText: "350 TL ve üzerine", valueText: "130 TL", subtitle: "İNDİRİM")
                        }
                        Text(banner.subtitle)
                            .font(.system(size: 6.2, weight: .medium))
                            .foregroundStyle(AppTheme.referenceTitle.opacity(0.7))
                            .lineLimit(1)
                    }
                    .padding(10)
                }
                .frame(width: 206, height: 112)
            }
        }
    }
}

struct HomeDiscountBannerValueCard: View {
    let minimumText: String
    let valueText: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(minimumText)
                .font(.system(size: 6, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .frame(height: 14)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppTheme.orange)
                )
            Text(valueText)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AppTheme.orange)
            Text(subtitle)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(AppTheme.orange)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct HomeRewardsCard: View {
    let rewards: HomeRewardsOverview

    private var progress: CGFloat {
        min(CGFloat(rewards.currentPoints) / 300.0, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.98, green: 0.35, blue: 0.12), Color(red: 0.92, green: 0.15, blue: 0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                    .overlay(
                        Text("go\nplus")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    )

                Text(rewards.title)
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(AppTheme.referenceTitle)
                Text("\(rewards.currentPoints)")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.red)

                Spacer()

                Text("Nasıl Puan Kazanırım?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.referenceTitle)
            }

            Rectangle()
                .fill(AppTheme.referenceDivider)
                .frame(height: 1)

            HStack(alignment: .top, spacing: 12) {
                Text(rewards.summary)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppTheme.referenceTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button { } label: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.42, blue: 0.05), Color(red: 0.91, green: 0.16, blue: 0.09)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(.plain)
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.referenceMuted)
                Text(rewards.detail)
                    .font(.system(size: 7.5, weight: .medium))
                    .foregroundStyle(AppTheme.referenceMuted)
            }

            GeometryReader { geometry in
                let availableWidth = geometry.size.width

                VStack(spacing: 12) {
                    HStack {
                        ForEach(rewards.milestones) { item in
                            Text("\(item.points)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(AppTheme.referenceTitle)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.referenceDivider)
                            .frame(height: 10)

                        Capsule()
                            .fill(Color.red)
                            .frame(width: max(42, availableWidth * progress), height: 10)

                        HStack {
                            ForEach(rewards.milestones) { item in
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        HomeMiniArtwork(artwork: item.artwork)
                                    )
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }

                    HStack(alignment: .top) {
                        ForEach(rewards.milestones) { item in
                            Text(item.title)
                                .font(.system(size: 7.5, weight: .semibold))
                                .foregroundStyle(AppTheme.referenceTitle)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .frame(height: 124)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .padding(.horizontal, 16)
    }
}

struct HomeSectionBlock<Content: View>: View {
    let title: String
    var systemImage: String? = nil
    var iconTint: Color = AppTheme.orange
    var actionTitle: String? = nil
    let content: Content

    init(
        title: String,
        systemImage: String? = nil,
        iconTint: Color = AppTheme.orange,
        actionTitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.iconTint = iconTint
        self.actionTitle = actionTitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(iconTint)
                }

                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppTheme.referenceTitle)

                Spacer()

                if let actionTitle {
                    Text(actionTitle)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppTheme.orange)
                }
            }
            .padding(.horizontal, 16)

            content
        }
    }
}

struct HomeRestaurantSpotlightCard: View {
    let card: HomeRestaurantSpotlight

    var body: some View {
        Button { } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    HomeRemoteImage(urlString: card.imageURL, artwork: card.artwork)
                        .frame(width: 160, height: 110)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(card.promoBadges, id: \.self) { badge in
                            Text(badge)
                                .font(.system(size: 5.5, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .frame(height: 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(AppTheme.orange)
                                )
                                .lineLimit(1)
                        }

                        Spacer()

                        if card.goPlus {
                            Text("Go Plus\nİndirimi")
                                .font(.system(size: 7, weight: .black))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .frame(width: 52, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(AppTheme.orange)
                                )
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8, weight: .bold))
                            Text("\(card.ratingText) \(card.reviewText)")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .frame(height: 18)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.10, green: 0.67, blue: 0.29))
                        )
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.orange)

                        Text(card.title)
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundStyle(AppTheme.referenceTitle)
                            .lineLimit(1)

                        Spacer()

                        if card.sponsored {
                            Text("Sponsorlu")
                                .font(.system(size: 6.5, weight: .semibold))
                                .foregroundStyle(AppTheme.referenceMuted)
                                .padding(.horizontal, 7)
                                .frame(height: 16)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.searchBar)
                                )
                        }
                    }

                    Text("\(card.minimumText) · \(card.distanceText) · \(card.cuisineText)")
                        .font(.system(size: 5.5, weight: .medium))
                        .foregroundStyle(AppTheme.referenceTitle)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        if card.deliveryStyle == .go {
                            Text("go")
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(AppTheme.orange)
                        } else {
                            Image(systemName: "scooter")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(AppTheme.referenceMuted)
                        }
                        Text(card.deliveryText)
                            .font(.system(size: 5.5, weight: .medium))
                            .foregroundStyle(AppTheme.referenceTitle)
                    }
                    .padding(.horizontal, 6)
                    .frame(height: 15)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(red: 0.97, green: 0.92, blue: 0.88))
                    )
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
            }
            .frame(width: 160, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
            )
        }
        .buttonStyle(.plain)
    }
}

struct HomeMarketSpotlightCard: View {
    let card: HomeMarketSpotlight

    var body: some View {
        Button { } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)

                    HomeMarketArtwork(card: card)
                        .frame(width: 252, height: 102)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(card.ratingText)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .frame(height: 20)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.10, green: 0.67, blue: 0.29))
                    )
                    .offset(y: -10)
                    .padding(.bottom, -10)

                    Text(card.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.referenceTitle)
                        .lineLimit(1)

                    Text(card.infoText)
                        .font(.system(size: 7.5, weight: .medium))
                        .foregroundStyle(AppTheme.referenceMuted)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 9)
            }
            .frame(width: 252, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
            )
        }
        .buttonStyle(.plain)
    }
}

struct HomeOpportunitySpotlightCard: View {
    let card: HomeOpportunitySpotlight

    var body: some View {
        Button { } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(card.theme.softTint.opacity(0.85))

                VStack(alignment: .leading, spacing: 9) {
                    Text(card.badge)
                        .font(.system(size: 6.8, weight: .black))
                        .foregroundStyle(card.theme.accent)
                        .padding(.horizontal, 8)
                        .frame(height: 18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(card.theme.accent, lineWidth: 1.5)
                        )

                    Text(card.title)
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(card.theme.accent)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    HStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(card.theme.accent)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(.white)
                            )

                        Spacer()

                        HomeArtworkPlaceholder(artwork: card.artwork)
                            .frame(width: 60, height: 60)
                    }
                }
                .padding(10)

                TriangleRibbon()
                    .fill(card.theme.accent)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "gift.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .offset(x: 8, y: -8),
                        alignment: .topTrailing
                    )
            }
            .frame(width: 132, height: 196)
        }
        .buttonStyle(.plain)
    }
}

struct HomeRemoteImage: View {
    let urlString: String
    let artwork: HomeArtwork

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            default:
                Rectangle()
                    .fill(Color(red: 0.92, green: 0.93, blue: 0.95))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.gray.opacity(0.7))
                    )
            }
        }
    }
}

struct HomeBannerArtwork: View {
    let style: HomeBannerStyle

    var body: some View {
        switch style {
        case .uberOne:
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.04))
                    .frame(width: 76, height: 76)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.96, green: 0.72, blue: 0.16))
                    .frame(width: 84, height: 34)
                    .overlay(
                        Text("Uber")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.black)
                            .offset(x: 16)
                    )
                    .offset(y: 6)

                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.black)
                    .frame(width: 20, height: 7)
                    .offset(y: -18)

                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
                    .offset(x: -24, y: 22)

                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
                    .offset(x: 24, y: 22)
            }

        case .flashDiscount:
            EmptyView()
        }
    }
}

struct HomeMarketArtwork: View {
    let card: HomeMarketSpotlight

    var body: some View {
        ZStack {
            switch card.artwork {
            case .grocery:
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.42, blue: 0.05), Color(red: 1.0, green: 0.54, blue: 0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                WavePattern()
                    .stroke(Color.white.opacity(0.12), lineWidth: 8)
                    .padding(.horizontal, -40)

                HStack(spacing: 9) {
                    VStack(spacing: 5) {
                        if let featureBadge = card.featureBadge {
                            Text(featureBadge)
                                .font(.system(size: 6, weight: .black))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 5)
                                .frame(height: 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(Color.white)
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white.opacity(0.92))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "basket.fill")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundStyle(.red)
                            )
                    }

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 76, height: 76)
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color(red: 0.35, green: 0.69, blue: 0.43))
                                Text("Yoğurt")
                                    .font(.system(size: 7, weight: .medium))
                                    .foregroundStyle(AppTheme.referenceMuted)
                            }
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        if let productTitle = card.productTitle {
                            Text(productTitle)
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                        }
                        if let oldPriceText = card.oldPriceText {
                            Text(oldPriceText)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(.white.opacity(0.88))
                                .strikethrough()
                        }
                        if let priceText = card.priceText {
                            Text(priceText)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)

            case .petShop:
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.95, green: 0.92, blue: 0.96))

                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Circle()
                            .fill(Color.white.opacity(0.75))
                            .frame(width: 90, height: 90)
                            .offset(x: 22, y: 12)
                    }
                }

                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 54, height: 56)
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(.blue)
                        )

                    Spacer()

                    VStack(spacing: 14) {
                        HomeMiniMarketIcon(systemImage: "leaf.fill", tint: .green)
                        HomeMiniMarketIcon(systemImage: "bone.fill", tint: AppTheme.bannerGold)
                    }
                    .offset(x: -10)
                }
                .padding(12)

            default:
                HomeArtworkBackground(artwork: card.artwork)
            }
        }
    }
}

struct HomeMiniMarketIcon: View {
    let systemImage: String
    let tint: Color

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.9))
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tint)
            )
    }
}

struct HomeMiniArtwork: View {
    let artwork: HomeArtwork

    var body: some View {
        switch artwork {
        case .goPlus:
            Text("Uber")
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 30, height: 22)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.gray)
                )

        case .cleaning:
            Image(systemName: "spray.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.green)

        default:
            Image(systemName: "fork.knife")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.orange)
        }
    }
}

struct HomeArtworkBackground: View {
    let artwork: HomeArtwork

    var body: some View {
        ZStack {
            switch artwork {
            case .spaghetti:
                LinearGradient(colors: [Color(red: 0.86, green: 0.29, blue: 0.20), Color(red: 0.22, green: 0.30, blue: 0.32)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 160, height: 160)
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.orange)

            case .rigatoni:
                LinearGradient(colors: [Color(red: 0.83, green: 0.25, blue: 0.15), Color(red: 0.41, green: 0.10, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 180, height: 120)
                    .rotationEffect(.degrees(-12))
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.white)

            case .pizza:
                LinearGradient(colors: [Color(red: 0.95, green: 0.62, blue: 0.17), Color(red: 0.49, green: 0.18, blue: 0.34)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)

            case .burger:
                LinearGradient(colors: [Color(red: 0.46, green: 0.24, blue: 0.12), Color(red: 0.19, green: 0.11, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "takeoutbag.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.bannerGold)

            case .cigkofte:
                LinearGradient(colors: [Color(red: 0.92, green: 0.11, blue: 0.15), Color(red: 0.49, green: 0.04, blue: 0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(.white)

            case .friedChicken:
                LinearGradient(colors: [Color(red: 0.77, green: 0.49, blue: 0.12), Color(red: 0.45, green: 0.29, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "flame.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(.white)

            case .grocery:
                LinearGradient(colors: [Color(red: 1.0, green: 0.54, blue: 0.10), Color(red: 1.0, green: 0.33, blue: 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "basket.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white)

            case .petShop:
                LinearGradient(colors: [Color(red: 0.92, green: 0.90, blue: 0.95), Color(red: 0.82, green: 0.88, blue: 0.95)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue)

            case .goPlus:
                LinearGradient(colors: [Color(red: 1.0, green: 0.95, blue: 0.93), Color(red: 1.0, green: 0.88, blue: 0.78)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "tag.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.orange)

            case .cleaning:
                LinearGradient(colors: [Color(red: 0.95, green: 0.98, blue: 0.91), Color(red: 0.87, green: 0.95, blue: 0.79)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "spray.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)

            case .water:
                LinearGradient(colors: [Color(red: 0.73, green: 0.90, blue: 0.98), Color(red: 0.46, green: 0.78, blue: 0.93)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "drop.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.white)

            case .doner:
                LinearGradient(colors: [Color(red: 0.91, green: 0.77, blue: 0.60), Color(red: 0.74, green: 0.49, blue: 0.30)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "fork.knife")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)

            case .baklava:
                LinearGradient(colors: [Color(red: 0.92, green: 0.84, blue: 0.56), Color(red: 0.71, green: 0.61, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

            case .flowers:
                LinearGradient(colors: [Color(red: 0.96, green: 0.94, blue: 0.98), Color(red: 0.91, green: 0.98, blue: 0.93)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "flower.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.pink)

            case .produce:
                LinearGradient(colors: [Color(red: 0.98, green: 0.95, blue: 0.76), Color(red: 0.88, green: 0.96, blue: 0.70)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.green)

            case .nuts:
                LinearGradient(colors: [Color(red: 0.98, green: 0.90, blue: 0.76), Color(red: 0.91, green: 0.79, blue: 0.64)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(red: 0.64, green: 0.38, blue: 0.12))
            }
        }
    }
}

struct HomeArtworkPlaceholder: View {
    let artwork: HomeArtwork

    var body: some View {
        HomeArtworkBackground(artwork: artwork)
            .clipShape(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
    }
}

struct WavePattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveHeight: CGFloat = 16
        let spacing: CGFloat = 24
        var y: CGFloat = 8

        while y < rect.height {
            path.move(to: CGPoint(x: rect.minX, y: y))
            var x = rect.minX
            while x < rect.maxX {
                path.addCurve(
                    to: CGPoint(x: x + spacing, y: y),
                    control1: CGPoint(x: x + spacing * 0.25, y: y - waveHeight * 0.5),
                    control2: CGPoint(x: x + spacing * 0.75, y: y + waveHeight * 0.5)
                )
                x += spacing
            }
            y += 20
        }
        return path
    }
}

struct TriangleRibbon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
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
                                isSelected: selectedScope == .restaurant,
                                selectedTint: AppTheme.orange
                            ) {
                                selectedScope = .restaurant
                            }

                            OrdersSegmentButton(
                                title: "Hızlı Market",
                                isSelected: selectedScope == .market,
                                selectedTint: AppTheme.marketGreen
                            ) {
                                selectedScope = .market
                            }
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(AppTheme.referenceText)

                            TextField("Siparişlerimde Ara", text: $searchText)
                                .font(.system(size: 17, weight: .regular))
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(AppTheme.searchBar)
                        )

                        if selectedScope != .market {
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
                                    if order.kind == .market {
                                        MarketOrderCard(order: order) {
                                            viewModel.reorder(order)
                                        }
                                    } else {
                                        ReferenceOrderCard(order: order) {
                                            viewModel.reorder(order)
                                        }
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
    let selectedTint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isSelected ? selectedTint : AppTheme.referenceText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(isSelected ? selectedTint : AppTheme.segmentBorder, lineWidth: 1.5)
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

struct MarketOrderCard: View {
    let order: Order
    let onReorder: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(order.vendorName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(AppTheme.referenceTitle)

                    Text(order.dateLabel)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(AppTheme.referenceMuted)

                    HStack(spacing: 0) {
                        Text("Toplam: ")
                            .foregroundStyle(AppTheme.referenceMuted)
                        Text(order.totalText)
                            .foregroundStyle(AppTheme.marketGreen)
                    }
                    .font(.system(size: 18, weight: .medium))
                }

                Spacer()

                NavigationLink {
                    OrderTrackingView(order: order)
                } label: {
                    HStack(spacing: 6) {
                        Text("Detaylar")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppTheme.marketGreen)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.top, 22)
            .padding(.bottom, 18)

            Rectangle()
                .fill(AppTheme.referenceDivider)
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(AppTheme.marketGreen)

                    Text("\(order.deliveredItemCount) Ürün Teslim Edildi")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppTheme.marketGreen)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(order.previewThumbnails.enumerated()), id: \.offset) { _, thumbnail in
                            MarketOrderThumbnailCard(thumbnail: thumbnail)
                        }
                    }
                }

                Text(order.itemSummary ?? "\(order.deliveredItemCount) Ürün Teslim Edildi")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppTheme.versionText)

                Button(action: onReorder) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Tekrarla")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.referenceTitle)
                    .padding(.horizontal, 22)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppTheme.marketGreen, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 22)
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

struct MarketOrderThumbnailCard: View {
    let thumbnail: OrderThumbnailKind

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.white)
            .frame(width: 104, height: 104)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.cardBorder, lineWidth: 1)
            )
            .overlay {
                MarketOrderThumbnailArtwork(thumbnail: thumbnail)
                    .padding(10)
            }
    }
}

struct MarketOrderThumbnailArtwork: View {
    let thumbnail: OrderThumbnailKind

    var body: some View {
        switch thumbnail {
        case .breakfastSauce:
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 0.23, green: 0.34, blue: 0.18))
                    .frame(width: 50, height: 10)
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.99, green: 0.78, blue: 0.48), Color(red: 0.88, green: 0.42, blue: 0.14)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 62, height: 54)
                    .overlay(
                        VStack(spacing: 2) {
                            Text("Çokça")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Kahvaltılık Sos")
                                .font(.system(size: 6, weight: .medium))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                    )
            }

        case .frozenSausage:
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.93, green: 0.89, blue: 0.84))
                .overlay(
                    VStack(spacing: 4) {
                        Text("Piliç\nKokteyl\nSosis")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 2) {
                            Circle().fill(Color.red.opacity(0.8)).frame(width: 7, height: 7)
                            Circle().fill(Color.red.opacity(0.65)).frame(width: 7, height: 7)
                            Circle().fill(Color.red.opacity(0.8)).frame(width: 7, height: 7)
                        }
                    }
                )

        case .labneh:
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.09, green: 0.58, blue: 0.36))
                    .frame(width: 60, height: 42)
                    .offset(y: 10)
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 66, height: 20)
                    .overlay(
                        Text("Labne")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.09, green: 0.58, blue: 0.36))
                    )
                    .offset(y: -8)
            }

        case .falimRed:
            MarketGumPack(primary: .red, secondary: Color(red: 0.18, green: 0.29, blue: 0.77), title: "FALIM")

        case .falimPurple:
            MarketGumPack(primary: Color(red: 0.44, green: 0.18, blue: 0.75), secondary: Color(red: 0.95, green: 0.49, blue: 0.62), title: "FALIM")

        case .sodaBottle:
            ZStack {
                Capsule()
                    .fill(Color(red: 0.14, green: 0.62, blue: 0.28))
                    .frame(width: 24, height: 62)
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color.red)
                    .frame(width: 14, height: 5)
                    .offset(y: -28)
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 16, height: 22)
            }

        case .bananas:
            ZStack {
                Capsule().fill(Color(red: 0.95, green: 0.84, blue: 0.22)).frame(width: 36, height: 12).rotationEffect(.degrees(-28)).offset(x: -10, y: 6)
                Capsule().fill(Color(red: 0.96, green: 0.85, blue: 0.24)).frame(width: 38, height: 12).rotationEffect(.degrees(12))
                Capsule().fill(Color(red: 0.96, green: 0.84, blue: 0.18)).frame(width: 34, height: 11).rotationEffect(.degrees(32)).offset(x: 10, y: 8)
            }

        case .persimmon:
            HStack(spacing: 6) {
                MarketFruit(color: Color(red: 0.96, green: 0.41, blue: 0.15))
                MarketFruit(color: Color(red: 0.92, green: 0.49, blue: 0.18))
            }
        }
    }
}

struct MarketGumPack: View {
    let primary: Color
    let secondary: Color
    let title: String

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(primary)
            .frame(width: 48, height: 18)
            .rotationEffect(.degrees(-10))
            .overlay(
                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Color.white)
            )
            .overlay(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(secondary)
                    .frame(width: 18, height: 18)
            }
    }
}

struct MarketFruit: View {
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color(red: 0.23, green: 0.56, blue: 0.24))
                .frame(width: 10, height: 4)
                .offset(y: -10)
        }
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
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppTheme.referenceDivider)
                .frame(height: 1)

            HStack(spacing: 0) {
                ReferenceTabBarItem(
                    title: "Anasayfa",
                    systemImage: "house.fill",
                    isSelected: selectedTab == .home
                ) {
                    selectedTab = .home
                }

                ReferenceTabBarItem(
                    title: "Siparişlerim",
                    systemImage: "list.clipboard.fill",
                    isSelected: selectedTab == .orders
                ) {
                    selectedTab = .orders
                }

                ReferenceTabBarItem(
                    title: "Hesabım",
                    systemImage: "person.fill",
                    isSelected: selectedTab == .profile
                ) {
                    selectedTab = .profile
                }
            }
            .frame(height: 48)
            .padding(.top, 4)
        }
        .background(Color.white)
        .background(
            Color.white
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct ReferenceTabBarItem: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .medium))
                    .frame(height: 24)
                Text(title)
                    .font(.system(size: 10, weight: .regular))
            }
            .foregroundStyle(isSelected ? AppTheme.orange : AppTheme.tabBarInactive)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
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
                            if viewModel.selectedAddress.id == address.id {
                                TagPill(text: "Aktif", tint: AppTheme.orangeSoft)
                            }
                        }
                        Text(address.regionLine)
                        Text(address.line1)
                        Text(address.buildingLine)
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
    static let marketGreen = Color(red: 0.25, green: 0.69, blue: 0.20)
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
        VStack(spacing: 0) {
            HStack {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(AppTheme.versionText)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Teslimat Adresi Seç")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(AppTheme.referenceTitle)

                Spacer()

                Color.clear
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .background(Color.white)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(AppTheme.referenceDivider)
                    .frame(height: 1)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Düzenle butonuna basarak konumunu ve adres bilgilerini düzenleyebilir veya adresini silebilirsin.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.referenceTitle)
                        .padding(.top, 12)

                    VStack(spacing: 10) {
                        AddressActionRow(
                            systemImage: "scope",
                            title: "Mevcut Konumumu Kullan"
                        ) {
                            if let firstAddress = viewModel.userProfile.addresses.first {
                                viewModel.selectAddress(firstAddress)
                                isPresented = false
                            }
                        }

                        AddressActionRow(
                            systemImage: "plus.circle",
                            title: "Yeni Adres Ekle"
                        ) {
                        }
                    }

                    VStack(spacing: 10) {
                        ForEach(viewModel.userProfile.addresses) { address in
                            AddressSelectionCard(
                                address: address,
                                isSelected: viewModel.selectedAddress.id == address.id,
                                onSelect: {
                                    viewModel.selectAddress(address)
                                    isPresented = false
                                }
                            )
                        }
                    }
                    .padding(.bottom, 14)
                }
                .padding(.horizontal, 22)
            }
            .background(AppTheme.referenceBackground.ignoresSafeArea())
        }
        .background(AppTheme.referenceBackground.ignoresSafeArea())
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
                    ZStack {
                        Circle()
                            .stroke(isSelected ? AppTheme.orange : AppTheme.versionText, lineWidth: 2.5)
                            .frame(width: 20, height: 20)
                        
                        if isSelected {
                            Circle()
                                .fill(AppTheme.orange)
                                .frame(width: 9, height: 9)
                        }
                    }
                    .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(address.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(AppTheme.referenceTitle)
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Düzenle")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(AppTheme.orange)
                        }
                        
                        Text(address.regionLine)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.referenceTitle)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(address.line1)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(AppTheme.referenceMuted)
                            Text(address.buildingLine)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AppTheme.referenceTitle)
                        }

                        Text(address.maskedPhone)
                            .font(.system(size: 11.5, weight: .regular))
                            .foregroundStyle(AppTheme.referenceMuted)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 14)
                .padding(.bottom, address.showsMapPreview ? 9 : 13)
                
                if address.showsMapPreview {
                    AddressMapPreview()
                        .frame(height: 192)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 0, style: .continuous)
                        )
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.segmentBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct AddressActionRow: View {
    let systemImage: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                Text(title)
                    .font(.system(size: 14.5, weight: .semibold))
            }
            .foregroundStyle(AppTheme.orange)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.segmentBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct AddressMapPreview: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.93, green: 0.94, blue: 0.95))

            Group {
                Path { path in
                    path.move(to: CGPoint(x: 20, y: 180))
                    path.addLine(to: CGPoint(x: 280, y: 20))
                    path.move(to: CGPoint(x: 40, y: 40))
                    path.addLine(to: CGPoint(x: 250, y: 220))
                    path.move(to: CGPoint(x: 70, y: 220))
                    path.addLine(to: CGPoint(x: 320, y: 60))
                    path.move(to: CGPoint(x: 0, y: 100))
                    path.addLine(to: CGPoint(x: 360, y: 140))
                    path.move(to: CGPoint(x: 110, y: 0))
                    path.addLine(to: CGPoint(x: 150, y: 250))
                }
                .stroke(Color(red: 0.74, green: 0.79, blue: 0.84), lineWidth: 6)

                Rectangle()
                    .fill(Color(red: 0.78, green: 0.90, blue: 0.78))
                    .frame(width: 84, height: 56)
                    .offset(x: -102, y: -26)

                Circle()
                    .fill(Color(red: 0.70, green: 0.42, blue: 0.95))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .offset(x: -36, y: -12)

                Circle()
                    .fill(Color(red: 0.28, green: 0.41, blue: 0.51))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "tram.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .offset(x: -112, y: 10)

                MapPinShape()
                    .fill(AppTheme.marketGreen)
                    .frame(width: 56, height: 82)
                    .offset(x: 24, y: 2)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .offset(x: 24, y: -6)
                    )
            }

            Text("Google")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(red: 0.22, green: 0.43, blue: 0.89))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, 14)
                .padding(.bottom, 10)
        }
    }
}

struct MapPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width / 2, y: height))
        path.addCurve(
            to: CGPoint(x: 0, y: height * 0.42),
            control1: CGPoint(x: width * 0.18, y: height * 0.76),
            control2: CGPoint(x: 0, y: height * 0.62)
        )
        path.addArc(
            center: CGPoint(x: width / 2, y: height * 0.34),
            radius: width * 0.34,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addCurve(
            to: CGPoint(x: width / 2, y: height),
            control1: CGPoint(x: width, y: height * 0.62),
            control2: CGPoint(x: width * 0.82, y: height * 0.76)
        )

        return path
    }
}

#Preview {
    ContentView()
}

import Combine
import SwiftUI

struct TrendyolGoPrototypeView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @EnvironmentObject private var tabRouter: TabRouterViewModel
    @State private var isCartPresented = false
    @State private var showLaunchFlow = true
    @State private var showsReferenceTabBar = true

    var body: some View {
        Group {
            switch tabRouter.selectedTab {
            case .home:
                HomeView()
            case .favorites:
                FavoritesView()
            case .cart:
                CartFlowView(isPresented: .constant(true), showsReferenceTabBar: $showsReferenceTabBar)
            case .orders:
                OrdersView()
            case .profile:
                ProfileView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showsReferenceTabBar {
                ReferenceTabBar()
            }
        }
        .fullScreenCover(isPresented: $showLaunchFlow) {
            LaunchFlowView(isPresented: $showLaunchFlow)
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
    @EnvironmentObject private var viewModel: ContentViewModel
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
        .onTapGesture {
            if card.style == .food {
                viewModel.isInFoodService = true
            }
        }
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

#Preview {
    ContentView()
}

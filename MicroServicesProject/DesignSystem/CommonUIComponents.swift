import SwiftUI

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
    @EnvironmentObject private var viewModel: ContentViewModel
    @EnvironmentObject private var tabRouter: TabRouterViewModel

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppTheme.referenceDivider)
                .frame(height: 1)

            HStack(spacing: 0) {
                ReferenceTabBarItem(
                    title: "Anasayfa",
                    systemImage: "house.fill",
                    isSelected: tabRouter.selectedTab == .home
                ) {
                    tabRouter.selectTab(.home)
                }

                if viewModel.isInFoodService {
                    ReferenceTabBarItem(
                        title: "Favoriler",
                        systemImage: "heart.fill",
                        isSelected: tabRouter.selectedTab == .favorites
                    ) {
                        tabRouter.selectTab(.favorites)
                    }

                    ReferenceTabBarItem(
                        title: "Sepetim",
                        systemImage: "basket.fill",
                        isSelected: tabRouter.selectedTab == .cart
                    ) {
                        tabRouter.selectTab(.cart)
                    }
                }

                ReferenceTabBarItem(
                    title: "Siparişlerim",
                    systemImage: "list.clipboard.fill",
                    isSelected: tabRouter.selectedTab == .orders
                ) {
                    tabRouter.selectTab(.orders)
                }

                ReferenceTabBarItem(
                    title: "Hesabım",
                    systemImage: "person.fill",
                    isSelected: tabRouter.selectedTab == .profile
                ) {
                    tabRouter.selectTab(.profile)
                }
            }
            .frame(height: 52)
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
        AccountMenuItem(title: "Kullanıcı Bilgilerim", systemImage: "person", badgeText: nil, destination: AnyView(UserInfoView())),
        AccountMenuItem(title: "Adreslerim", systemImage: "mappin.and.ellipse", badgeText: nil, destination: AnyView(AddressListView())),
        AccountMenuItem(title: "Kayıtlı Kartlarım", systemImage: "creditcard", badgeText: nil, destination: AnyView(PaymentMethodsView())),
        AccountMenuItem(title: "İndirim Kuponlarım", systemImage: "ticket", badgeText: nil, destination: AnyView(CampaignsView())),
        AccountMenuItem(title: "E-Posta Değişikliği", systemImage: "envelope", badgeText: nil, destination: AnyView(SimpleAccountView(title: "E-Posta Değişikliği", subtitle: "E-posta güncelleme akışı mock içerikle gösteriliyor."))),
        AccountMenuItem(title: "Duyuru Tercihlerim", systemImage: "bell", badgeText: nil, destination: AnyView(NotificationsView())),
        AccountMenuItem(title: "Trendyol Go Seni Dinliyor", systemImage: "list.clipboard", badgeText: "YENI", destination: AnyView(SupportView())),
        AccountMenuItem(title: "Güvenlik", systemImage: "shield", badgeText: nil, destination: AnyView(SimpleAccountView(title: "Güvenlik", subtitle: "Şifre ve oturum ayarları burada gösterilebilir."))),
        AccountMenuItem(title: "Daha Fazla", systemImage: "ellipsis.circle", badgeText: nil, destination: AnyView(SimpleAccountView(title: "Daha Fazla", subtitle: "Ek ayarlar ve sık sorulanlar için alan.")))
    ]
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
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .layoutPriority(1)
                Spacer()
                Text(subtitle)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(AppTheme.orange, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
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

extension Order {
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

extension VendorTheme {
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

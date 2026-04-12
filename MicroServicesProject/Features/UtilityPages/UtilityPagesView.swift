import SwiftUI

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

import SwiftUI

private struct EmptyStateCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct UserInfoView: View {
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var fullName: String = ""
    @State private var phone: String = ""
    @State private var bannerMessage: String?
    @State private var bannerIsError = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                editableCard(title: "Ad Soyad", text: $fullName, keyboardType: .default)
                infoCard(title: "E-posta", value: viewModel.userProfile.email)
                editableCard(title: "Telefon", text: $phone, keyboardType: .phonePad)
                infoCard(title: "Durum", value: viewModel.userProfile.isActive ? "Aktif" : "Pasif")
                infoCard(title: "Kayıtlı Adres", value: "\(viewModel.userProfile.addresses.count)")

                if let bannerMessage {
                    statusCard(message: bannerMessage, isError: bannerIsError)
                }

                PrimaryActionButton(
                    title: authSession.isSubmitting ? "Kaydediliyor..." : "Bilgileri Kaydet",
                    subtitle: "users/me"
                ) {
                    submit()
                }
                .disabled(authSession.isSubmitting)
                .opacity(authSession.isSubmitting ? 0.7 : 1)
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Kullanıcı Bilgilerim")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fullName = viewModel.userProfile.fullName
            phone = viewModel.userProfile.phone
        }
    }

    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
        )
    }

    private func editableCard(title: String, text: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

            TextField("", text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(keyboardType == .default ? .words : .never)
                .autocorrectionDisabled()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                )
        }
    }

    private func statusCard(message: String, isError: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundStyle(isError ? .red : AppTheme.successGreen)
            Text(message)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
        )
    }

    private func submit() {
        bannerMessage = nil

        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            bannerIsError = true
            bannerMessage = "Ad Soyad boş bırakılamaz."
            return
        }

        guard !trimmedPhone.isEmpty else {
            bannerIsError = true
            bannerMessage = "Telefon boş bırakılamaz."
            return
        }

        Task {
            do {
                try await authSession.updateUserProfile(name: trimmedName, phone: trimmedPhone)
                fullName = authSession.userProfile?.fullName ?? trimmedName
                phone = authSession.userProfile?.phone ?? trimmedPhone
                bannerIsError = false
                bannerMessage = "Kullanıcı bilgileri güncellendi."
            } catch {
                bannerIsError = true
                bannerMessage = error.localizedDescription
            }
        }
    }
}

struct CampaignsView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(viewModel.liveCampaigns.isEmpty ? viewModel.campaigns : viewModel.liveCampaigns) { campaign in
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
        .safeAreaInset(edge: .bottom) {
            if let status = viewModel.gatewayHealthStatus {
                Text("Gateway: \(status)\(viewModel.gatewayInfoVersion.map { " • v\($0)" } ?? "")")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
                    .padding(.vertical, 8)
            }
        }
        .task {
            await viewModel.loadCampaigns()
            await viewModel.loadGatewayMeta()
        }
    }
}

struct AddressListView: View {
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var isShowingAddSheet = false
    @State private var addressPendingDelete: Address?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                if viewModel.userProfile.addresses.isEmpty {
                    EmptyStateCard(
                        title: "Kayıtlı adres bulunamadı",
                        message: "Kullanıcı servisi şu an adres döndürmüyor veya bu hesapta kayıtlı adres yok."
                    )
                } else {
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
                            HStack {
                                Spacer()
                                Button("Sil") {
                                    addressPendingDelete = address
                                }
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.red)
                            }
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
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Adreslerim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(AppTheme.orange)
                }
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddressEditorSheet(prefillWithCurrentLocation: false) { draft in
                do {
                    guard let lat = draft.latitudeValue, let lng = draft.longitudeValue else {
                        throw AppAuthError(message: "Koordinatlar sayısal olmalı.")
                    }
                    try await authSession.createAddress(
                        label: draft.label,
                        street: draft.street,
                        city: draft.city,
                        postalCode: draft.postalCode,
                        lat: lat,
                        lng: lng
                    )
                    if let newAddress = authSession.userProfile?.addresses.last {
                        viewModel.selectAddress(newAddress)
                    }
                    isShowingAddSheet = false
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        .alert("Adres silinsin mi?", isPresented: Binding(
            get: { addressPendingDelete != nil },
            set: { if !$0 { addressPendingDelete = nil } }
        )) {
            Button("Vazgeç", role: .cancel) {
                addressPendingDelete = nil
            }
            Button("Sil", role: .destructive) {
                guard let address = addressPendingDelete else { return }
                Task {
                    do {
                        try await authSession.deleteAddress(id: address.id)
                        addressPendingDelete = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        } message: {
            Text(addressPendingDelete?.title ?? "")
        }
        .alert("Adres Hatası", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

struct PaymentMethodsView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                if viewModel.userProfile.paymentMethods.isEmpty {
                    EmptyStateCard(
                        title: "Kayıtlı kart bulunamadı",
                        message: "Payment methods endpoint'i henüz mobile uygulamaya bağlanmadı."
                    )
                } else {
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

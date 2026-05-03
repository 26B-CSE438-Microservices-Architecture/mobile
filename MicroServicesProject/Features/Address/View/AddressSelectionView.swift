import Combine
import CoreLocation
import MapKit
import SwiftUI

struct AddressSelectionView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var isShowingAddSheet = false
    @State private var shouldPrefillWithCurrentLocation = false
    @State private var errorMessage: String?

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
                            shouldPrefillWithCurrentLocation = true
                            isShowingAddSheet = true
                        }

                        AddressActionRow(
                            systemImage: "plus.circle",
                            title: "Yeni Adres Ekle"
                        ) {
                            isShowingAddSheet = true
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
        .sheet(isPresented: $isShowingAddSheet) {
            AddressEditorSheet(prefillWithCurrentLocation: shouldPrefillWithCurrentLocation) { draft in
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
                    isPresented = false
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
            .onDisappear {
                shouldPrefillWithCurrentLocation = false
            }
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

struct AddressDraft {
    var label: String = ""
    var street: String = ""
    var city: String = ""
    var postalCode: String = ""
    var lat: String = "36.8969"
    var lng: String = "30.7133"

    var isValid: Bool {
        !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !postalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(lat) != nil &&
        Double(lng) != nil
    }

    var latitudeValue: Double? {
        Double(lat)
    }

    var longitudeValue: Double? {
        Double(lng)
    }

    mutating func applyReverseGeocodedAddress(_ placemark: CLPlacemark, coordinate: CLLocationCoordinate2D) {
        let titleCandidate = placemark.subLocality?.nilIfBlank ?? placemark.locality?.nilIfBlank ?? "Konumum"
        let streetCandidate = [placemark.thoroughfare, placemark.subThoroughfare]
            .compactMap { $0?.nilIfBlank }
            .joined(separator: " ")
            .nilIfBlank ?? placemark.name?.nilIfBlank ?? "Konumdan dolduruldu"
        let cityCandidate = placemark.locality?.nilIfBlank ?? placemark.administrativeArea?.nilIfBlank ?? city
        let postalCandidate = placemark.postalCode?.nilIfBlank ?? postalCode

        if label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            label = titleCandidate
        }
        street = streetCandidate
        city = cityCandidate
        postalCode = postalCandidate
        lat = String(format: "%.6f", coordinate.latitude)
        lng = String(format: "%.6f", coordinate.longitude)
    }
}

struct AddressEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @StateObject private var locationService = AddressLocationService()
    @State private var draft = AddressDraft()
    @State private var localErrorMessage: String?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var pendingMapCenter: CLLocationCoordinate2D?
    @State private var isApplyingMapCenter = false

    let prefillWithCurrentLocation: Bool
    let onSubmit: (AddressDraft) async throws -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    locationButton

                    if let coordinate = coordinate {
                        selectedLocationPreview(for: coordinate)
                    }

                    field("Adres Başlığı", text: $draft.label)
                    field("Sokak / Açık Adres", text: $draft.street)
                    field("Şehir", text: $draft.city)
                    field("Posta Kodu", text: $draft.postalCode, keyboardType: .numberPad)
                    field("Latitude", text: $draft.lat, keyboardType: .decimalPad)
                    field("Longitude", text: $draft.lng, keyboardType: .decimalPad)

                    if let localErrorMessage {
                        Text(localErrorMessage)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.red)
                    }

                    PrimaryActionButton(title: "Adresi Kaydet", subtitle: authSession.isSubmitting ? "Kaydediliyor" : "Canlı API") {
                        submit()
                    }
                    .disabled(authSession.isSubmitting)
                    .opacity(authSession.isSubmitting ? 0.7 : 1)
                }
                .padding(16)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle("Yeni Adres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .task {
                if prefillWithCurrentLocation {
                    await fillFromCurrentLocation()
                }
            }
        }
    }

    private var coordinate: CLLocationCoordinate2D? {
        guard let lat = draft.latitudeValue, let lng = draft.longitudeValue else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    private var locationButton: some View {
        Button {
            Task {
                await fillFromCurrentLocation()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "location.fill")
                Text(locationService.isLoading ? "Konum alınıyor..." : "Konumumu Kullan ve Doldur")
                Spacer()
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(AppTheme.orange)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.segmentBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(locationService.isLoading)
    }

    private func selectedLocationPreview(for coordinate: CLLocationCoordinate2D) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Seçilen Konum")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
                Spacer()
                Text("Haritayı kaydırıp merkezi seçebilirsin")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
            }

            ZStack {
                Map(position: $cameraPosition) {
                    if let pendingMapCenter {
                        Marker("Seçilecek Nokta", coordinate: pendingMapCenter)
                            .tint(AppTheme.marketGreen)
                    } else {
                        Marker("Adres", coordinate: coordinate)
                    }
                }
                .onMapCameraChange(frequency: .continuous) { context in
                    pendingMapCenter = context.region.center
                }

                VStack {
                    Spacer()

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AppTheme.orange)
                        .shadow(radius: 8, y: 4)

                    Spacer()
                }

                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        Button {
                            Task {
                                await usePendingMapCenter()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "scope")
                                Text(isApplyingMapCenter ? "İşleniyor..." : "Harita Merkezini Kullan")
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .frame(height: 40)
                            .background(AppTheme.orange, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .disabled(isApplyingMapCenter || pendingMapCenter == nil)
                    }
                    .padding(12)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private func field(_ title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

            TextField("", text: text)
                .keyboardType(keyboardType)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )
        }
    }

    private func submit() {
        localErrorMessage = nil
        guard draft.isValid else {
            localErrorMessage = "Tüm alanları doldur ve koordinatları sayısal gir."
            return
        }

        Task {
            do {
                try await onSubmit(
                    AddressDraft(
                        label: draft.label.trimmingCharacters(in: .whitespacesAndNewlines),
                        street: draft.street.trimmingCharacters(in: .whitespacesAndNewlines),
                        city: draft.city.trimmingCharacters(in: .whitespacesAndNewlines),
                        postalCode: draft.postalCode.trimmingCharacters(in: .whitespacesAndNewlines),
                        lat: draft.lat.trimmingCharacters(in: .whitespacesAndNewlines),
                        lng: draft.lng.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                )
                dismiss()
            } catch {
                localErrorMessage = error.localizedDescription
            }
        }
    }

    private func fillFromCurrentLocation() async {
        localErrorMessage = nil

        do {
            let result = try await locationService.requestCurrentAddressDraft()
            draft.applyReverseGeocodedAddress(result.placemark, coordinate: result.coordinate)
            pendingMapCenter = result.coordinate
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: result.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                )
            )
        } catch {
            localErrorMessage = error.localizedDescription
        }
    }

    private func usePendingMapCenter() async {
        guard let pendingMapCenter else { return }

        localErrorMessage = nil
        isApplyingMapCenter = true
        defer { isApplyingMapCenter = false }

        do {
            let placemark = try await locationService.reverseGeocodeCoordinate(pendingMapCenter)
            draft.applyReverseGeocodedAddress(placemark, coordinate: pendingMapCenter)
        } catch {
            localErrorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class AddressLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    struct Result {
        let coordinate: CLLocationCoordinate2D
        let placemark: CLPlacemark
    }

    @Published private(set) var isLoading = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestCurrentAddressDraft() async throws -> Result {
        isLoading = true
        defer { isLoading = false }

        let location = try await requestCurrentLocation()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw AppAuthError(message: "Konum çözümlendi ama adres bulunamadı.")
        }

        return Result(coordinate: location.coordinate, placemark: placemark)
    }

    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) async throws -> CLPlacemark {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw AppAuthError(message: "Seçilen nokta için adres bulunamadı.")
        }
        return placemark
    }

    private func requestCurrentLocation() async throws -> CLLocation {
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            throw AppAuthError(message: "Konum izni kapalı. Ayarlar'dan izin ver.")
        }

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            continuation?.resume(throwing: AppAuthError(message: "Konum alınamadı."))
            continuation = nil
            return
        }

        continuation?.resume(returning: location)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: AppAuthError(message: error.localizedDescription))
        continuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            continuation?.resume(throwing: AppAuthError(message: "Konum izni verilmedi."))
            continuation = nil
        }
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
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

import SwiftUI

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
                        ) { }
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

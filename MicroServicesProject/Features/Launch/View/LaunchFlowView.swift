import SwiftUI

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

import SwiftUI

private enum LaunchStage {
    case intro
    case auth
}

private enum AuthMode: String {
    case login
    case register
}

struct LaunchFlowView: View {
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @State private var stage: LaunchStage = .intro
    @State private var mode: AuthMode = .login
    @State private var introIndex = 0
    @State private var name = ""
    @State private var surname = ""
    @State private var phoneNumber = "+90 555 123 45 67"
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?

    private let introSlides = [
        ("30 dakikada kapında", "Yemek, market, su ve kahve siparişlerini tek akışta yönet.", "scooter"),
        ("Canlı sipariş takibi", "Kurye durumunu ve teslimat adımlarını gerçek zamanlı gör.", "location.fill"),
        ("Gerçek giriş akışı", "Backend'e bağlanıp register ve login response'larını uygulama içinde doğrula.", "lock.shield.fill")
    ]

    var body: some View {
        NavigationStack {
            Group {
                switch stage {
                case .intro:
                    introView
                case .auth:
                    authView
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
                PrimaryActionButton(title: "Devam et", subtitle: "Giriş yap") {
                    stage = .auth
                }

                Text("Bu sürümde giriş zorunlu.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
                    .padding(.bottom, 4)
            }
            .padding(16)
        }
    }

    private var authView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Spacer(minLength: 12)

                Text(mode == .login ? "Hesabınla giriş yap" : "Yeni hesap oluştur")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.ink)

                Text(mode == .login
                    ? "Canlı auth servisine email ve şifre ile bağlan."
                    : "Şifre en az 6 karakter olmalı; büyük harf, küçük harf ve özel karakter içermeli.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)

                authModePicker

                if let errorMessage {
                    authErrorCard(message: errorMessage)
                }

                if mode == .register {
                    formField(title: "Ad", text: $name, textContentType: .givenName)
                    formField(title: "Soyad", text: $surname, textContentType: .familyName)
                    formField(title: "Telefon", text: $phoneNumber, keyboardType: .phonePad, textContentType: .telephoneNumber)
                }

                formField(title: "E-posta", text: $email, keyboardType: .emailAddress, textContentType: .emailAddress, textInputAutocapitalization: .never)
                secureField(title: "Şifre", text: $password, textContentType: mode == .login ? .password : .newPassword)

                if mode == .register {
                    secureField(title: "Şifre tekrar", text: $confirmPassword, textContentType: .newPassword)
                }

                if authSession.isSubmitting {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(AppTheme.orange)
                        Text(mode == .login ? "Giriş yapılıyor..." : "Hesap oluşturuluyor...")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)
                    }
                }

                PrimaryActionButton(
                    title: mode == .login ? "Giriş yap" : "Kaydı tamamla",
                    subtitle: mode == .login ? "Auth" : "Register"
                ) {
                    submit()
                }
                .disabled(authSession.isSubmitting)
                .opacity(authSession.isSubmitting ? 0.7 : 1)

                Button("Tanıtıma dön") {
                    stage = .intro
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .navigationBarBackButtonHidden(true)
        .scrollDismissesKeyboard(.interactively)
    }

    private var authModePicker: some View {
        HStack(spacing: 10) {
            authModeButton(.login, title: "Giriş Yap")
            authModeButton(.register, title: "Kayıt Ol")
        }
    }

    private func authModeButton(_ targetMode: AuthMode, title: String) -> some View {
        Button(title) {
            mode = targetMode
            errorMessage = nil
        }
        .buttonStyle(.plain)
        .font(.system(size: 15, weight: .bold, design: .rounded))
        .foregroundStyle(mode == targetMode ? .white : AppTheme.ink)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(mode == targetMode ? AppTheme.orange : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(mode == targetMode ? AppTheme.orange : AppTheme.segmentBorder, lineWidth: 1)
        )
    }

    private func formField(
        title: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization = .words
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

            TextField("", text: text)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(textInputAutocapitalization)
                .autocorrectionDisabled()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )
        }
    }

    private func secureField(title: String, text: Binding<String>, textContentType: UITextContentType?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.subtleText)

            SecureField("", text: text)
                .textContentType(textContentType)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )
        }
    }

    private func authErrorCard(message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.red)

            Text(message)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.15), lineWidth: 1)
        )
    }

    private func submit() {
        errorMessage = validateForm()
        guard errorMessage == nil else { return }

        Task {
            do {
                if mode == .login {
                    try await authSession.signIn(
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password
                    )
                } else {
                    try await authSession.register(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        surname: surname.trimmingCharacters(in: .whitespacesAndNewlines),
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password
                    )
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func validateForm() -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            return "E-posta alanı boş bırakılamaz."
        }

        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            return "Geçerli bir e-posta gir."
        }

        guard !trimmedPassword.isEmpty else {
            return "Şifre alanı boş bırakılamaz."
        }

        if mode == .register {
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return "Ad alanı boş bırakılamaz."
            }

            guard !surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return "Soyad alanı boş bırakılamaz."
            }

            guard trimmedPassword.count >= 6 else {
                return "Şifre en az 6 karakter olmalı."
            }

            guard password == confirmPassword else {
                return "Şifreler eşleşmiyor."
            }
        }

        return nil
    }
}

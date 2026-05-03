import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var logoutErrorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ReferenceHeader(title: "Hesabım")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        if let currentUser = authSession.currentUser {
                            VStack(spacing: 6) {
                                Text(currentUser.fullName)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                                Text(currentUser.email)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.subtleText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                            .padding(.bottom, 18)
                        }

                        ForEach(profileViewModel.menuItems) { item in
                            NavigationLink {
                                item.destination
                            } label: {
                                AccountRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            Task {
                                logoutErrorMessage = await authSession.signOut()
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 21, weight: .regular))
                                    .foregroundStyle(.red)
                                    .frame(width: 28)

                                Text(authSession.isSubmitting ? "Çıkış yapılıyor..." : "Çıkış Yap")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundStyle(AppTheme.referenceTitle)

                                Spacer()
                            }
                            .padding(.horizontal, 32)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .disabled(authSession.isSubmitting)

                        VStack(spacing: 0) {
                            Text(profileViewModel.appVersionText)
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
            .alert("Çıkış uyarısı", isPresented: Binding(
                get: { logoutErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        logoutErrorMessage = nil
                    }
                }
            )) {
                Button("Tamam", role: .cancel) { logoutErrorMessage = nil }
            } message: {
                Text(logoutErrorMessage ?? "")
            }
        }
    }
}

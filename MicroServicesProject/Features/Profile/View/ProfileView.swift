import SwiftUI

struct ProfileView: View {
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ReferenceHeader(title: "Hesabım")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(profileViewModel.menuItems) { item in
                            NavigationLink {
                                item.destination
                            } label: {
                                AccountRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }

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
        }
    }
}

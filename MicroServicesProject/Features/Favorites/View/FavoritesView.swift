import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @EnvironmentObject private var authSession: AuthSessionViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ReferenceHeader(title: "Favorilerim")

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if let errorMessage = viewModel.favoritesErrorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.red)
                        }

                        if viewModel.favoriteVendors.isEmpty {
                            EmptyStateView(
                                title: "Henüz favorin yok",
                                subtitle: "Kalp ikonuna basarak mağazaları burada toplayabilirsin.",
                                systemImage: "heart.fill"
                            )
                            .padding(.top, 80)
                        } else {
                            ForEach(viewModel.favoriteVendors) { vendor in
                                NavigationLink {
                                    RestaurantDetailView(vendor: vendor)
                                } label: {
                                    VendorCard(vendor: vendor, compact: false)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
                .background(AppTheme.referenceBackground.ignoresSafeArea())
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            if let accessToken = authSession.accessToken {
                await viewModel.loadFavorites(accessToken: accessToken)
            }
        }
    }
}

import SwiftUI
import Combine

struct FavoritesView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @StateObject private var favoritesViewModel = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ReferenceHeader(title: "Favorilerim")

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if favoritesViewModel.favorites.isEmpty {
                            EmptyStateView(
                                title: "Henüz favorin yok",
                                subtitle: "Kalp ikonuna basarak mağazaları burada toplayabilirsin.",
                                systemImage: "heart.fill"
                            )
                            .padding(.top, 80)
                        } else {
                            ForEach(favoritesViewModel.favorites) { vendor in
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
        .onAppear {
            favoritesViewModel.refresh(from: viewModel.favoriteVendors)
        }
        .onReceive(viewModel.objectWillChange) { _ in
            favoritesViewModel.refresh(from: viewModel.favoriteVendors)
        }
    }
}

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @StateObject private var searchViewModel = SearchViewModel()

    private var searchResults: [Vendor] {
        searchViewModel.results(in: viewModel.allVendors)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.subtleText)

                        TextField("Ürün, restoran veya market ara", text: $searchViewModel.query)
                            .textInputAutocapitalization(.never)

                        if !searchViewModel.query.isEmpty {
                            Button {
                                searchViewModel.clearQuery()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppTheme.subtleText)
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                    )

                    if searchViewModel.query.isEmpty {
                        Text("Son aramalar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        FlexibleChips(items: searchViewModel.recentSearches)

                        Text("Öne çıkan ürünler")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        VStack(spacing: 12) {
                            ForEach(viewModel.suggestedProducts) { product in
                                SuggestedProductRow(product: product)
                            }
                        }

                        Text("Popüler mağazalar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        VStack(spacing: 14) {
                            ForEach(viewModel.allVendors) { vendor in
                                NavigationLink {
                                    RestaurantDetailView(vendor: vendor)
                                } label: {
                                    VendorCard(vendor: vendor, compact: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                        Text("Sonuçlar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        if searchResults.isEmpty {
                            EmptyStateView(
                                title: "Sonuç bulunamadı",
                                subtitle: "\"\(searchViewModel.query)\" için farklı bir arama dene.",
                                systemImage: "magnifyingglass.circle.fill"
                            )
                        } else {
                            VStack(spacing: 14) {
                                ForEach(searchResults) { vendor in
                                    NavigationLink {
                                        RestaurantDetailView(vendor: vendor)
                                    } label: {
                                        VendorCard(vendor: vendor, compact: false)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(AppTheme.canvas.ignoresSafeArea())
            .navigationTitle("Ara")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

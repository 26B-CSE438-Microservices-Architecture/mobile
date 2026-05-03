import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @StateObject private var searchViewModel = SearchViewModel()

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
                        if let errorMessage = searchViewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.red)
                        }

                        Text("Sonuçlar")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        if searchViewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView("Aranıyor...")
                                    .tint(AppTheme.orange)
                                Spacer()
                            }
                            .padding(.vertical, 32)
                        } else if !searchViewModel.hasResults {
                            EmptyStateView(
                                title: "Sonuç bulunamadı",
                                subtitle: "\"\(searchViewModel.query)\" için farklı bir arama dene.",
                                systemImage: "magnifyingglass.circle.fill"
                            )
                        } else {
                            if !searchViewModel.resultVendors.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Restoranlar")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.ink)

                                    ForEach(searchViewModel.resultVendors) { vendor in
                                        NavigationLink {
                                            RestaurantDetailView(vendor: vendor)
                                        } label: {
                                            VendorCard(vendor: vendor, compact: false)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            if !searchViewModel.resultProducts.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Ürünler")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.ink)

                                    ForEach(searchViewModel.resultProducts) { product in
                                        SearchProductResultRow(product: product)
                                    }
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
            .task(id: searchViewModel.normalizedQuery) {
                await searchViewModel.search(selectedAddress: viewModel.selectedAddress)
            }
        }
    }
}

private struct SearchProductResultRow: View {
    let product: SearchProductResponse

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.orange.opacity(0.12))
                    .frame(width: 54, height: 54)

                Image(systemName: "fork.knife")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.orange)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)

                Text(product.vendor_name ?? "Restoran bilgisi yok")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
            }

            Spacer()

            Text(product.price_label ?? "-")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.orange)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
    }
}

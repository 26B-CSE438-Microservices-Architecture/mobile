import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @StateObject private var homeViewModel = HomeViewModel()

    private var activeSearchSuggestion: String {
        homeViewModel.activeSearchSuggestion(from: viewModel.homeSearchSuggestions)
    }

    private var liveRestaurants: [Vendor] {
        viewModel.restaurants
    }

    private var campaignRestaurants: [Vendor] {
        liveRestaurants.filter { !$0.promoText.isEmpty && $0.promoText != "Aktif kampanya bilgisi yok" }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.referenceBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if let activeOrder = viewModel.activeOrder {
                            NavigationLink {
                                OrderTrackingView(order: activeOrder)
                            } label: {
                                ActiveOrderCard(order: activeOrder)
                                    .padding(.horizontal, 16)
                            }
                            .buttonStyle(.plain)
                        }

                        if let homeErrorMessage = viewModel.homeErrorMessage {
                            Text(homeErrorMessage)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 16)
                        }

                        if !viewModel.isInFoodService {
                            HomePrimaryServiceGrid(cards: viewModel.homePrimaryServices)
                        } else {
                            Button {
                                viewModel.isInFoodService = false
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Ana Sayfa'ya Dön")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppTheme.orangeSoft)
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 16)
                        }

                        HomeMiniServiceRow(cards: viewModel.homeMiniServices)

                        HomeBannerCarousel(banners: viewModel.homeHeroBanners)

                        if !liveRestaurants.isEmpty {
                            HomeSectionBlock(
                                title: "Canlı Restoranlar",
                                systemImage: "fork.knife.circle.fill",
                                iconTint: AppTheme.orange,
                                actionTitle: "\(liveRestaurants.count) restoran"
                            ) {
                                VStack(spacing: 14) {
                                    ForEach(liveRestaurants) { vendor in
                                        NavigationLink {
                                            RestaurantDetailView(vendor: vendor)
                                        } label: {
                                            VendorCard(vendor: vendor, compact: false)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        if !campaignRestaurants.isEmpty {
                            HomeSectionBlock(
                                title: "Canlı Kampanyalı Restoranlar",
                                systemImage: "percent",
                                iconTint: AppTheme.bannerGold,
                                actionTitle: "\(campaignRestaurants.count) sonuç"
                            ) {
                                VStack(spacing: 14) {
                                    ForEach(campaignRestaurants) { vendor in
                                        NavigationLink {
                                            RestaurantDetailView(vendor: vendor)
                                        } label: {
                                            VendorCard(vendor: vendor, compact: true)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        if !viewModel.nearbyVendors.isEmpty {
                            HomeSectionBlock(
                                title: "Yakındakiler",
                                systemImage: "location.circle.fill",
                                iconTint: AppTheme.orange,
                                actionTitle: "\(viewModel.nearbyVendors.count) sonuç"
                            ) {
                                VStack(spacing: 14) {
                                    ForEach(viewModel.nearbyVendors) { vendor in
                                        NavigationLink {
                                            RestaurantDetailView(vendor: vendor)
                                        } label: {
                                            VendorCard(vendor: vendor, compact: true)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 74)
                    .background(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(AppTheme.referenceBackground)
                    )
                }
                .scrollClipDisabled()
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 10) {
                    TrendyolGoHomeHeader(
                        address: viewModel.selectedAddress,
                        onAddressTap: { homeViewModel.openAddressSelector() }
                    )

                    Button {
                        homeViewModel.openSearch()
                    } label: {
                        HomeSearchBar(placeholder: activeSearchSuggestion)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 3)
                .padding(.bottom, 7)
                .background(AppTheme.orange)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $homeViewModel.isSearchPresented) {
            SearchView()
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $homeViewModel.isShowingAddressSelector) {
            AddressSelectionView(isPresented: $homeViewModel.isShowingAddressSelector)
        }
        .onReceive(homeViewModel.searchSuggestionTimer) { _ in
            homeViewModel.advanceSuggestion(total: viewModel.homeSearchSuggestions.count)
        }
        .task {
            await viewModel.loadNearbyVendors()
            await viewModel.loadCampaigns()
            await viewModel.loadGatewayMeta()
        }
    }
}

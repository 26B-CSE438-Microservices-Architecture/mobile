import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @StateObject private var homeViewModel = HomeViewModel()

    private var activeSearchSuggestion: String {
        homeViewModel.activeSearchSuggestion(from: viewModel.homeSearchSuggestions)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.referenceBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
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

                        HomeSectionBlock(
                            title: "Mutfaklar",
                            actionTitle: "Tümünü Gör"
                        ) {
                            HomeCuisineRow(cuisines: viewModel.homeCuisines)
                        }

                        HomeBannerCarousel(banners: viewModel.homeHeroBanners)
                        HomeRewardsCard(rewards: viewModel.homeRewardsOverview)

                        HomeSectionBlock(
                            title: "Sana Özel Restoranlar",
                            systemImage: "heart.fill",
                            iconTint: Color(red: 0.85, green: 0.07, blue: 0.22),
                            actionTitle: "Tümünü Gör"
                        ) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.homePersonalRestaurants) { card in
                                        HomeRestaurantSpotlightCard(card: card)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        HomeSectionBlock(
                            title: "Kampanyalı Restoranlar",
                            systemImage: "percent",
                            iconTint: AppTheme.bannerGold,
                            actionTitle: "Tümünü Gör"
                        ) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.homeCampaignRestaurants) { card in
                                        HomeRestaurantSpotlightCard(card: card)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        HomeSectionBlock(title: "Sana Özel Marketler") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.homeMarkets) { market in
                                        HomeMarketSpotlightCard(card: market)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        HomeSectionBlock(title: "Öne Çıkan Fırsatlar") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.homeOpportunities) { deal in
                                        HomeOpportunitySpotlightCard(card: deal)
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
    }
}

import SwiftUI

struct OrdersView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @StateObject private var ordersViewModel = OrdersViewModel()

    private var filteredOrders: [Order] {
        ordersViewModel.filteredOrders(from: viewModel.pastOrders)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ReferenceHeader(title: "Siparişlerim")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            OrdersSegmentButton(
                                title: "Yemek",
                                isSelected: ordersViewModel.selectedScope == .restaurant,
                                selectedTint: AppTheme.orange
                            ) {
                                ordersViewModel.selectedScope = .restaurant
                            }

                            OrdersSegmentButton(
                                title: "Hızlı Market",
                                isSelected: ordersViewModel.selectedScope == .market,
                                selectedTint: AppTheme.marketGreen
                            ) {
                                ordersViewModel.selectedScope = .market
                            }
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(AppTheme.referenceText)

                            TextField("Siparişlerimde Ara", text: $ordersViewModel.searchText)
                                .font(.system(size: 17, weight: .regular))
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(AppTheme.searchBar)
                        )

                        if ordersViewModel.selectedScope != .market {
                            HStack(spacing: 12) {
                                Image(systemName: "seal.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(AppTheme.bannerGold)
                                    .overlay(
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                    )

                                HStack(spacing: 0) {
                                    Text("Siparişini değerlendir, ")
                                        .foregroundStyle(AppTheme.ink)
                                    Text("20 Go Plus Puan")
                                        .foregroundStyle(AppTheme.orange)
                                    Text(" kazan!")
                                        .foregroundStyle(AppTheme.ink)
                                }
                                .font(.system(size: 15, weight: .semibold))

                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.55))
                            .overlay(alignment: .top) {
                                Rectangle()
                                    .fill(AppTheme.referenceDivider)
                                    .frame(height: 1)
                            }
                        }

                        if let errorMessage = viewModel.ordersErrorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if filteredOrders.isEmpty {
                            EmptyStateView(
                                title: "Sipariş bulunamadı",
                                subtitle: "Aramanı temizleyip tekrar deneyebilirsin.",
                                systemImage: "list.bullet.clipboard"
                            )
                            .padding(.top, 36)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredOrders) { order in
                                    if order.kind == .market {
                                        MarketOrderCard(order: order) {
                                            viewModel.reorder(order)
                                        }
                                    } else {
                                        ReferenceOrderCard(order: order) {
                                            viewModel.reorder(order)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .background(AppTheme.referenceBackground.ignoresSafeArea())
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            if let accessToken = authSession.accessToken {
                await viewModel.loadOrders(accessToken: accessToken)
            }
        }
    }
}

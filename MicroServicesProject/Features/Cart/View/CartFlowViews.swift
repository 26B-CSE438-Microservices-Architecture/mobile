import SwiftUI
import Combine

struct CartFlowView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            CartView(isPresented: $isPresented)
        }
    }
}

struct CartView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Binding var isPresented: Bool
    @StateObject private var cartViewModel = CartViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            if cartViewModel.cartItems.isEmpty {
                EmptyStateView(
                    title: "Sepetin boş",
                    subtitle: "Ana sayfadan ürün eklediğinde burada görünecek.",
                    systemImage: "cart.fill"
                )
                .padding(.top, 80)
            } else {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cartViewModel.cartVendorName ?? "Sepet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                        Text("Teslimat adresi: \(cartViewModel.selectedAddressTitle)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)
                    }

                    VStack(spacing: 12) {
                        ForEach(cartViewModel.cartItems) { item in
                            CartItemRow(item: item)
                        }
                    }

                    PriceSummaryCard(
                        subtotal: cartViewModel.cartSubtotal,
                        delivery: cartViewModel.cartDeliveryFee,
                        service: cartViewModel.cartServiceFee,
                        discount: cartViewModel.cartDiscount,
                        total: cartViewModel.cartTotal
                    )
                }
                .padding(16)
                .padding(.bottom, 90)
            }
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Sepetim")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if !cartViewModel.cartItems.isEmpty {
                NavigationLink {
                    CheckoutView(isPresented: $isPresented)
                } label: {
                    HStack {
                        Text("Ödemeye geç")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Spacer()
                        Text(cartViewModel.cartTotal.formatted(.currency(code: "TRY")))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(AppTheme.orange, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
        .onAppear {
            cartViewModel.sync(from: viewModel)
        }
        .onReceive(viewModel.objectWillChange) { _ in
            cartViewModel.sync(from: viewModel)
        }
    }
}

struct CheckoutView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Binding var isPresented: Bool
    @StateObject private var checkoutViewModel = CheckoutViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                CheckoutSection(title: "Teslimat adresi") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.selectedAddress.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                        Text(viewModel.selectedAddress.line1)
                        Text(viewModel.selectedAddress.detail)
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
                }

                CheckoutSection(title: "Ödeme yöntemi") {
                    ForEach(viewModel.userProfile.paymentMethods) { method in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(method.title)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                                Text(method.detail)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.subtleText)
                            }
                            Spacer()
                            if method.isDefault {
                                TagPill(text: "Varsayılan", tint: AppTheme.orangeSoft)
                            }
                        }
                    }
                }

                CheckoutSection(title: "Sipariş özeti") {
                    PriceSummaryCard(
                        subtotal: viewModel.cartSubtotal,
                        delivery: viewModel.cartDeliveryFee,
                        service: viewModel.cartServiceFee,
                        discount: viewModel.cartDiscount,
                        total: viewModel.cartTotal
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 90)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Ödeme")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            PrimaryActionButton(
                title: "Siparişi onayla",
                subtitle: viewModel.cartTotal.formatted(.currency(code: "TRY"))
            ) {
                checkoutViewModel.confirmOrder(using: viewModel)
                isPresented = false
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }
}

struct OrderTrackingView: View {
    @StateObject private var orderTrackingViewModel: OrderTrackingViewModel

    init(order: Order) {
        _orderTrackingViewModel = StateObject(wrappedValue: OrderTrackingViewModel(order: order))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.orange.opacity(0.22), AppTheme.orange.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 210)
                    .overlay(
                        VStack(alignment: .leading, spacing: 12) {
                            Label(orderTrackingViewModel.order.statusLabel, systemImage: "location.fill")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.orange)

                            Text(orderTrackingViewModel.order.vendorName)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            Text("Tahmini teslimat: \(orderTrackingViewModel.order.etaRange)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            Spacer()

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Teslimat adresi")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.subtleText)
                                    Text(orderTrackingViewModel.order.addressLine)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppTheme.ink)
                                }
                                Spacer()
                            }
                        }
                        .padding(20)
                    )

                if let courier = orderTrackingViewModel.order.courier {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kurye bilgisi")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        HStack(spacing: 14) {
                            Circle()
                                .fill(AppTheme.orangeSoft)
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Image(systemName: "scooter")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(AppTheme.orange)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(courier.name)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                                Text("\(courier.vehicle) • \(courier.plate)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.subtleText)
                                Text(courier.etaNote)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.orange)
                            }

                            Spacer()
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                    )
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Sipariş durumu")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    ForEach(Array(orderTrackingViewModel.order.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(index <= orderTrackingViewModel.order.activeStep ? AppTheme.orange : AppTheme.orangeSoft)
                                    .frame(width: 34, height: 34)

                                Image(systemName: step.symbol)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(index <= orderTrackingViewModel.order.activeStep ? .white : AppTheme.orange)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.title)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                                Text(step.detail)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.subtleText)
                            }

                            Spacer()
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                )

                CheckoutSection(title: "Sipariş içeriği") {
                    VStack(spacing: 10) {
                        ForEach(orderTrackingViewModel.order.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(item.quantity)x \(item.product.name)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.ink)
                                    if !item.selectedOptions.isEmpty {
                                        Text(item.selectedOptions.joined(separator: ", "))
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundStyle(AppTheme.subtleText)
                                    }
                                }
                                Spacer()
                                Text((item.product.price * Double(item.quantity)).formatted(.currency(code: "TRY")))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Sipariş Takibi")
        .navigationBarTitleDisplayMode(.inline)
    }
}

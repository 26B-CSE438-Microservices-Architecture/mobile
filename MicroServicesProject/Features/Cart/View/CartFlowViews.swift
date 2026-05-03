import SwiftUI
import Combine
import WebKit

struct CartFlowView: View {
    @Binding var isPresented: Bool
    @Binding var showsReferenceTabBar: Bool

    var body: some View {
        NavigationStack {
            CartView(isPresented: $isPresented, showsReferenceTabBar: $showsReferenceTabBar)
        }
    }
}

struct CartView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @Binding var isPresented: Bool
    @Binding var showsReferenceTabBar: Bool
    @StateObject private var cartViewModel = CartViewModel()
    @State private var isCheckoutActive = false

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

                    if let errorMessage = viewModel.cartErrorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(isActive: $isCheckoutActive) {
                        CheckoutView(isPresented: $isPresented, showsReferenceTabBar: $showsReferenceTabBar)
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
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle("Sepetim")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            cartViewModel.sync(from: viewModel)
        }
        .onReceive(viewModel.objectWillChange) { _ in
            cartViewModel.sync(from: viewModel)
        }
        .onAppear {
            showsReferenceTabBar = true
        }
        .task {
            if let accessToken = authSession.accessToken {
                await viewModel.loadCart(accessToken: accessToken)
                cartViewModel.sync(from: viewModel)
            }
        }
    }
}

struct CheckoutView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Binding var isPresented: Bool
    @Binding var showsReferenceTabBar: Bool
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
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Kart bilgisi uygulamada tutulmaz", systemImage: "lock.shield.fill")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)

                        Text("payment-service hosted checkout form döndürüyor. Doğru akışta mobile yalnızca bu HTML içeriğini WebView içinde render eder; kart numarası, CVC ve SKT native ekranda tutulmaz.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)

                        VStack(alignment: .leading, spacing: 8) {
                            PaymentFlowRow(title: "1. Checkout", detail: "POST /payments ile checkout form alınıyor")
                            PaymentFlowRow(title: "2. WebView", detail: "checkoutForm.content render ediliyor")
                            PaymentFlowRow(title: "3. Callback", detail: "callback intercept edilip /checkout-form/callback çağrılıyor")
                            PaymentFlowRow(title: "4. Sipariş", detail: "Payment AUTHORIZED olunca sipariş tamamlanıyor")
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

                CheckoutSection(title: "Demo notları") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bu ekran local Docker üstündeki payment-service mock provider’ına bağlanır. Test kartları hosted form içinde hazır gelir.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)

                        PaymentTestHint(text: "Başarılı kart: 5528 7900 0000 0008")
                        PaymentTestHint(text: "Declined: 4111 1111 1111 1129")
                        PaymentTestHint(text: "Insufficient: 4111 1111 1111 1111")
                        PaymentTestHint(text: "Expired: 4111 1111 1111 1100")
                    }
                }

                if let banner = checkoutViewModel.banner {
                    PaymentBannerCard(banner: banner)
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
                title: checkoutViewModel.isPreparingCheckout ? "Ödeme ekranı hazırlanıyor..." : "Hosted checkout aç",
                subtitle: viewModel.cartTotal.formatted(.currency(code: "TRY"))
            ) {
                guard !checkoutViewModel.isPreparingCheckout else { return }
                Task {
                    await checkoutViewModel.startHostedCheckout(using: viewModel)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .sheet(item: hostedCheckoutBinding) { session in
            HostedCheckoutSheet(
                session: session,
                isCompleting: checkoutViewModel.isCompletingCheckout,
                onClose: {
                    checkoutViewModel.dismissHostedCheckout()
                },
                onCallbackIntercepted: {
                    Task {
                        await checkoutViewModel.handleHostedCheckoutCallback(using: viewModel)
                        if checkoutViewModel.hostedCheckoutSession == nil {
                            isPresented = false
                        }
                    }
                }
            )
        }
        .onAppear {
            showsReferenceTabBar = false
        }
        .onDisappear {
            showsReferenceTabBar = true
        }
    }
}

private struct HostedCheckoutSheet: View {
    let session: CheckoutViewModel.HostedCheckoutSession
    let isCompleting: Bool
    let onClose: () -> Void
    let onCallbackIntercepted: () -> Void

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                HostedCheckoutWebView(
                    htmlContent: session.htmlContent,
                    callbackURL: session.callbackURL,
                    onCallbackIntercepted: onCallbackIntercepted
                )
                .ignoresSafeArea(edges: .bottom)

                if isCompleting {
                    ProgressView("Ödeme sonucu doğrulanıyor...")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle("Hosted Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat", action: onClose)
                }
            }
        }
    }
}

private struct HostedCheckoutWebView: UIViewRepresentable {
    let htmlContent: String
    let callbackURL: URL
    let onCallbackIntercepted: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(callbackURL: callbackURL, onCallbackIntercepted: onCallbackIntercepted)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.loadHTMLString(htmlContent, baseURL: nil)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let callbackURL: URL
        private let onCallbackIntercepted: () -> Void
        private var hasIntercepted = false

        init(callbackURL: URL, onCallbackIntercepted: @escaping () -> Void) {
            self.callbackURL = callbackURL
            self.onCallbackIntercepted = onCallbackIntercepted
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if !hasIntercepted,
               let url = navigationAction.request.url,
               url.scheme == callbackURL.scheme,
               url.host == callbackURL.host {
                hasIntercepted = true
                onCallbackIntercepted()
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }
    }
}

private struct PaymentFlowRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(AppTheme.orangeSoft)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.orange)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text(detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
            }
        }
    }
}

private struct PaymentTestHint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .monospaced))
            .foregroundStyle(AppTheme.subtleText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PaymentBannerCard: View {
    let banner: CheckoutViewModel.PaymentBanner

    private var tint: Color {
        switch banner.style {
        case .info:
            return Color.blue
        case .success:
            return AppTheme.successGreen
        case .error:
            return Color.red
        }
    }

    private var symbol: String {
        switch banner.style {
        case .info:
            return "info.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 4) {
                Text(banner.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text(banner.message)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleText)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
    }
}

private extension CheckoutView {
    var hostedCheckoutBinding: Binding<CheckoutViewModel.HostedCheckoutSession?> {
        Binding(
            get: { checkoutViewModel.hostedCheckoutSession },
            set: { newValue in
                if newValue == nil {
                    checkoutViewModel.dismissHostedCheckout()
                }
            }
        )
    }
}

struct OrderTrackingView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @EnvironmentObject private var authSession: AuthSessionViewModel
    @StateObject private var orderTrackingViewModel: OrderTrackingViewModel
    @State private var orderActionMessage: String?

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

                if let accessToken = authSession.accessToken, orderTrackingViewModel.order.backendID != nil {
                    CheckoutSection(title: "Sipariş işlemleri") {
                        VStack(spacing: 10) {
                            Button("Siparişi İptal Et") {
                                Task {
                                    await viewModel.cancelOrder(orderTrackingViewModel.order, accessToken: accessToken)
                                    orderActionMessage = "İptal isteği gönderildi."
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!viewModel.canCancel(order: orderTrackingViewModel.order))

                            Button("İade Talep Et") {
                                Task {
                                    await viewModel.requestRefund(orderTrackingViewModel.order, accessToken: accessToken)
                                    orderActionMessage = "İade talebi gönderildi."
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(!viewModel.canRequestRefund(order: orderTrackingViewModel.order))

                            if let orderActionMessage {
                                Text(orderActionMessage)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.subtleText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
        .task {
            let detailedOrder = await viewModel.refreshOrderDetailIfNeeded(
                for: orderTrackingViewModel.order,
                accessToken: authSession.accessToken
            )
            orderTrackingViewModel.replace(order: detailedOrder)
        }
    }
}

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
    @State private var isCheckoutActive = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.cartItems.isEmpty {
                EmptyStateView(
                    title: "Sepetin boş",
                    subtitle: "Ana sayfadan ürün eklediğinde burada görünecek.",
                    systemImage: "cart.fill"
                )
                .padding(.top, 80)
            } else {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.cartVendorName ?? "Sepet")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Text("Teslimat adresi: \(viewModel.selectedAddress.summaryText)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.subtleText)
                        }

                        Spacer()

                        Button("Sepeti Temizle") {
                            viewModel.clearCart()
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.orange)
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                        .background(
                            Capsule()
                                .fill(AppTheme.orangeSoft)
                        )
                    }

                    VStack(spacing: 12) {
                        ForEach(viewModel.cartItems) { item in
                            CartItemRow(item: item)
                        }
                    }

                    PriceSummaryCard(
                        subtotal: viewModel.cartSubtotal,
                        delivery: viewModel.cartDeliveryFee,
                        discount: viewModel.cartDiscount,
                        total: viewModel.cartTotal
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
                            Text(viewModel.cartTotal.formatted(.currency(code: "TRY")))
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
            showsReferenceTabBar = true
        }
        .task {
            if let accessToken = authSession.accessToken {
                await viewModel.loadCart(accessToken: accessToken)
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
                        if viewModel.selectedAddress.isEmpty {
                            Text("Henüz kayıtlı adres yok")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Text("Devam etmeden önce adres eklemelisin.")
                        } else {
                            Text(viewModel.selectedAddress.title)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                            Text(viewModel.selectedAddress.line1)
                            Text(viewModel.selectedAddress.detail)
                        }
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
                        discount: viewModel.cartDiscount,
                        total: viewModel.cartTotal
                    )
                }

                CheckoutSection(title: "Ödeme notları") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ödeme formu servis tarafından üretilir ve WebView içinde açılır. Kart alanları native uygulamada tutulmaz.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.subtleText)

                        PaymentTestHint(text: "Toplam tutar ödeme isteğinde sepet kalemlerinin toplamından üretilir.")
                        PaymentTestHint(text: "Checkout tamamlanınca callback ile payment durumu doğrulanır.")
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
                title: checkoutViewModel.isPreparingCheckout ? "Ödeme ekranı hazırlanıyor..." : "Ödemeye geç",
                subtitle: viewModel.cartTotal.formatted(.currency(code: "TRY"))
            ) {
                guard !checkoutViewModel.isPreparingCheckout else { return }
                Task {
                    await checkoutViewModel.startHostedCheckout(using: viewModel)
                }
            }
            .disabled(checkoutViewModel.isPreparingCheckout || checkoutViewModel.hostedCheckoutSession != nil)
            .opacity((checkoutViewModel.isPreparingCheckout || checkoutViewModel.hostedCheckoutSession != nil) ? 0.7 : 1)
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
                onCallbackIntercepted: { payload in
                    Task {
                        await checkoutViewModel.handleHostedCheckoutCallback(using: viewModel, payload: payload)
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
    let onCallbackIntercepted: (CheckoutViewModel.HostedCheckoutCallbackPayload?) -> Void

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                HostedCheckoutWebView(
                    pageURL: session.pageURL,
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
            .navigationTitle("Ödeme Ekranı")
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
    let pageURL: URL?
    let htmlContent: String
    let callbackURL: URL
    let onCallbackIntercepted: (CheckoutViewModel.HostedCheckoutCallbackPayload?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(callbackURL: callbackURL, onCallbackIntercepted: onCallbackIntercepted)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: Coordinator.messageHandlerName)
        contentController.addUserScript(
            WKUserScript(
                source: context.coordinator.callbackCaptureScript,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )
        configuration.userContentController = contentController
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        if let pageURL {
            webView.load(URLRequest(url: pageURL))
        } else {
            webView.loadHTMLString(htmlContent, baseURL: URL(string: "https://sandbox-cpp.iyzipay.com"))
        }
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        static let messageHandlerName = "paymentCallback"

        private let callbackURL: URL
        private let onCallbackIntercepted: (CheckoutViewModel.HostedCheckoutCallbackPayload?) -> Void
        private var hasIntercepted = false

        init(
            callbackURL: URL,
            onCallbackIntercepted: @escaping (CheckoutViewModel.HostedCheckoutCallbackPayload?) -> Void
        ) {
            self.callbackURL = callbackURL
            self.onCallbackIntercepted = onCallbackIntercepted
        }

        var callbackCaptureScript: String {
            let callbackURLString = callbackURL.absoluteString
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")

            return """
            (function() {
              const callbackURL = "\(callbackURLString)";
              function sendPayload(form) {
                try {
                  if (!form) return false;
                  const action = form.getAttribute('action') || '';
                  const resolved = new URL(action, window.location.href).toString();
                  if (resolved !== callbackURL) return false;
                  const formData = new FormData(form);
                  const payload = {};
                  formData.forEach(function(value, key) {
                    payload[key] = String(value);
                  });
                  window.webkit.messageHandlers.\(Self.messageHandlerName).postMessage(payload);
                  return true;
                } catch (error) {
                  return false;
                }
              }
              document.addEventListener('submit', function(event) {
                if (sendPayload(event.target)) {
                  event.preventDefault();
                  event.stopPropagation();
                }
              }, true);
              const nativeSubmit = HTMLFormElement.prototype.submit;
              HTMLFormElement.prototype.submit = function() {
                if (sendPayload(this)) {
                  return;
                }
                return nativeSubmit.call(this);
              };
            })();
            """
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard !hasIntercepted, message.name == Self.messageHandlerName else { return }
            hasIntercepted = true
            onCallbackIntercepted(payload(from: message.body))
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if !hasIntercepted,
               let url = navigationAction.request.url,
               url.scheme == callbackURL.scheme,
               url.host == callbackURL.host {
                hasIntercepted = true
                onCallbackIntercepted(payload(from: url))
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        private func payload(from body: Any) -> CheckoutViewModel.HostedCheckoutCallbackPayload? {
            guard let dictionary = body as? [String: Any] else { return nil }
            let token = (dictionary["token"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let mockOutcome = (dictionary["mockOutcome"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let cardNumber = (dictionary["cardNumber"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return CheckoutViewModel.HostedCheckoutCallbackPayload(
                token: token,
                mockOutcome: mockOutcome?.isEmpty == false ? mockOutcome : nil,
                cardNumber: cardNumber?.isEmpty == false ? cardNumber : nil
            )
        }

        private func payload(from url: URL) -> CheckoutViewModel.HostedCheckoutCallbackPayload? {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
            let token = components.queryItems?.first(where: { $0.name == "token" })?.value ?? ""
            let mockOutcome = components.queryItems?.first(where: { $0.name == "mockOutcome" })?.value
            let cardNumber = components.queryItems?.first(where: { $0.name == "cardNumber" })?.value
            return CheckoutViewModel.HostedCheckoutCallbackPayload(
                token: token,
                mockOutcome: mockOutcome?.isEmpty == false ? mockOutcome : nil,
                cardNumber: cardNumber?.isEmpty == false ? cardNumber : nil
            )
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
                            HStack(spacing: 8) {
                                TagPill(
                                    text: orderTrackingViewModel.order.statusLabel,
                                    tint: orderTrackingViewModel.order.statusAccent.opacity(0.12),
                                    foreground: orderTrackingViewModel.order.statusAccent
                                )
                                TagPill(
                                    text: orderTrackingViewModel.order.formattedDateLabel,
                                    tint: .white.opacity(0.7),
                                    foreground: AppTheme.referenceTitle
                                )
                            }

                            Text(orderTrackingViewModel.order.displayTitle)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.ink)

                            Text(orderTrackingViewModel.order.displaySubtitle)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.referenceMuted)
                                .lineLimit(2)

                            HStack(spacing: 6) {
                                Image(systemName: "timer")
                                Text("Tahmini teslimat: \(orderTrackingViewModel.order.etaRange)")
                            }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
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
                            VStack(spacing: 0) {
                                ZStack {
                                    Circle()
                                        .fill(index <= orderTrackingViewModel.order.activeStep ? orderTrackingViewModel.order.statusAccent : AppTheme.orangeSoft)
                                        .frame(width: 34, height: 34)

                                    Image(systemName: step.symbol)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(index <= orderTrackingViewModel.order.activeStep ? .white : orderTrackingViewModel.order.statusAccent)
                                }

                                if index < orderTrackingViewModel.order.steps.count - 1 {
                                    Rectangle()
                                        .fill(index < orderTrackingViewModel.order.activeStep ? orderTrackingViewModel.order.statusAccent.opacity(0.45) : AppTheme.referenceDivider)
                                        .frame(width: 2, height: 30)
                                        .padding(.vertical, 4)
                                }
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
                            TrackingActionButton(
                                title: "Siparişi İptal Et",
                                tint: AppTheme.newBadgeRed,
                                isEnabled: viewModel.canCancel(order: orderTrackingViewModel.order)
                            ) {
                                Task {
                                    await viewModel.cancelOrder(orderTrackingViewModel.order, accessToken: accessToken)
                                    orderActionMessage = "İptal isteği gönderildi."
                                }
                            }

                            TrackingActionButton(
                                title: "İade Talep Et",
                                tint: AppTheme.orange,
                                isEnabled: viewModel.canRequestRefund(order: orderTrackingViewModel.order),
                                isFilled: false
                            ) {
                                Task {
                                    await viewModel.requestRefund(orderTrackingViewModel.order, accessToken: accessToken)
                                    orderActionMessage = "İade talebi gönderildi."
                                }
                            }

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

private struct TrackingActionButton: View {
    let title: String
    let tint: Color
    let isEnabled: Bool
    var isFilled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(isFilled ? .white : (isEnabled ? tint : AppTheme.subtleText))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isFilled ? (isEnabled ? tint : AppTheme.referenceDivider) : .white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isFilled ? .clear : (isEnabled ? tint : AppTheme.referenceDivider), lineWidth: 1.5)
                )
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
    }
}

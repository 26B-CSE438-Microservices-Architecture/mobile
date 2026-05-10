import Foundation
import Combine

@MainActor
final class CheckoutViewModel: ObservableObject {
    struct HostedCheckoutCallbackPayload: Equatable {
        let token: String
        let mockOutcome: String?
        let cardNumber: String?
    }

    struct HostedCheckoutSession: Identifiable, Equatable {
        let id: String
        let orderID: String
        let paymentID: String
        let callbackURL: URL
        let callbackToken: String
        let pageURL: URL?
        let htmlContent: String
    }

    struct PaymentBanner: Equatable {
        enum Style {
            case info
            case success
            case error
        }

        let title: String
        let message: String
        let style: Style
    }

    private struct StartSagaRequest: Encodable {
        struct DeliveryAddress: Encodable {
            let street: String
            let district: String
            let city: String
            let postalCode: String
            let lat: Double
            let lng: Double
        }

        let deliveryAddress: DeliveryAddress
        let paymentMethod: String
        let orderType: String
        let notes: String
    }

    private struct StartSagaAcceptedResponse: Decodable {
        let sagaId: String
    }

    private struct SagaStateResponse: Decodable {
        struct CheckoutForm: Decodable {
            let token: String
            let content: String
            let paymentPageUrl: String?

            private enum CodingKeys: String, CodingKey {
                case token
                case content
                case paymentPageUrl
                case hostedPageUrl
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                token = try container.decode(String.self, forKey: .token)
                content = try container.decode(String.self, forKey: .content)
                let directURL = try container.decodeIfPresent(String.self, forKey: .paymentPageUrl)
                let hostedURL = try container.decodeIfPresent(String.self, forKey: .hostedPageUrl)
                paymentPageUrl = directURL ?? hostedURL
            }
        }

        let orderId: String?
        let paymentId: String?
        let status: String
        let failureReason: String?
        let checkoutForm: CheckoutForm?
    }

    private struct GatewayErrorResponse: Decodable {
        struct ErrorDetail: Decodable {
            let message: String
        }
        let error: ErrorDetail
    }

    @Published private(set) var hostedCheckoutSession: HostedCheckoutSession?
    @Published private(set) var isPreparingCheckout = false
    @Published private(set) var isCompletingCheckout = false
    @Published private(set) var banner: PaymentBanner?

    private let baseURL = URL(string: "https://gw.cse.akdeniz.edu.tr/cse-438/api/v1")!

    func startHostedCheckout(using source: ContentViewModel) async {
        guard !isPreparingCheckout, hostedCheckoutSession == nil else { return }
        guard !source.cartItems.isEmpty else { return }
        guard !source.selectedAddress.isEmpty else {
            banner = PaymentBanner(
                title: "Adres gerekli",
                message: "Ödeme ekranını açmadan önce adres eklemelisin.",
                style: .error
            )
            return
        }

        isPreparingCheckout = true
        banner = nil
        defer { isPreparingCheckout = false }

        do {
            let idempotencyKey = "ios-\(UUID().uuidString.lowercased())"
            let requestBody = buildStartSagaRequest(from: source)

            var request = URLRequest(url: baseURL.appendingPathComponent("saga/orders/start"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(idempotencyKey, forHTTPHeaderField: "Idempotency-Key")
            request.setValue(idempotencyKey, forHTTPHeaderField: "X-Correlation-Id")
            if let token = source.remoteAccessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(requestBody)

            print("[CheckoutViewModel] HTTP \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
            print("[CheckoutViewModel] Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("[CheckoutViewModel] Request body: \(bodyString)")
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[CheckoutViewModel] Invalid response")
                throw CheckoutError.invalidResponse
            }
            
            print("[CheckoutViewModel] Response status: \(httpResponse.statusCode)")
            if let rawString = String(data: data, encoding: .utf8) {
                print("[CheckoutViewModel] Response body: \(rawString)")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if let gatewayError = try? JSONDecoder().decode(GatewayErrorResponse.self, from: data) {
                    throw CheckoutError.backend(gatewayError.error.message)
                }
                if let rawString = String(data: data, encoding: .utf8), !rawString.isEmpty {
                    throw CheckoutError.backend("HTTP \(httpResponse.statusCode): \(rawString)")
                }
                throw CheckoutError.backend("HTTP Error \(httpResponse.statusCode)")
            }

            let accepted = try JSONDecoder().decode(StartSagaAcceptedResponse.self, from: data)
            let sagaState = try await pollSagaState(sagaID: accepted.sagaId, accessToken: source.remoteAccessToken)

            guard sagaState.status == "PaymentInitiated",
                  let orderID = sagaState.orderId,
                  let paymentID = sagaState.paymentId,
                  let checkoutForm = sagaState.checkoutForm else {
                throw CheckoutError.backend(sagaState.failureReason ?? "Checkout form alınamadı.")
            }

            guard let resolvedCallbackURL = callbackURL(orderID: orderID, paymentID: paymentID) else {
                throw CheckoutError.invalidCallbackURL
            }

            hostedCheckoutSession = HostedCheckoutSession(
                id: paymentID,
                orderID: orderID,
                paymentID: paymentID,
                callbackURL: resolvedCallbackURL,
                callbackToken: checkoutForm.token,
                pageURL: checkoutForm.paymentPageUrl.flatMap(URL.init(string:)),
                htmlContent: decodeCheckoutHTML(from: checkoutForm.content)
            )
            banner = PaymentBanner(
                title: "Ödeme ekranı hazır",
                message: "Kart bilgileri iyzico hosted form içinde açılacak.",
                style: .info
            )
        } catch {
            banner = PaymentBanner(
                title: "Payment service ulaşılamadı",
                message: error.localizedDescription,
                style: .error
            )
        }
    }

    func handleHostedCheckoutCallback(
        using source: ContentViewModel,
        payload: HostedCheckoutCallbackPayload?
    ) async {
        guard let session = hostedCheckoutSession, !isCompletingCheckout else { return }

        isCompletingCheckout = true
        defer { isCompletingCheckout = false }

        do {
            var request = URLRequest(url: session.callbackURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let resolvedPayload = HostedCheckoutCallbackPayload(
                token: {
                    let candidate = payload?.token.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    return candidate.isEmpty ? session.callbackToken : candidate
                }(),
                mockOutcome: payload?.mockOutcome,
                cardNumber: payload?.cardNumber
            )
            var requestBody: [String: String] = ["token": resolvedPayload.token]
            if let mockOutcome = resolvedPayload.mockOutcome {
                requestBody["mockOutcome"] = mockOutcome
            }
            if let cardNumber = resolvedPayload.cardNumber {
                requestBody["cardNumber"] = cardNumber
            }
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            print("[CheckoutViewModel] HTTP \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
            print("[CheckoutViewModel] Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("[CheckoutViewModel] Request body: \(bodyString)")
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[CheckoutViewModel] Invalid callback response")
                throw CheckoutError.invalidResponse
            }
            
            print("[CheckoutViewModel] Callback Response status: \(httpResponse.statusCode)")
            if let rawString = String(data: data, encoding: .utf8) {
                print("[CheckoutViewModel] Callback Response body: \(rawString)")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw CheckoutError.invalidResponse
            }

            let sagaState = try await pollSagaState(sagaID: session.orderID, accessToken: source.remoteAccessToken)

            if sagaState.status == "PaymentAuthorized" {
                hostedCheckoutSession = nil
                banner = PaymentBanner(
                    title: "Ödeme başarılı",
                    message: "Ödeme ekranı tamamlandı, sipariş oluşturuldu.",
                    style: .success
                )
                if let accessToken = source.remoteAccessToken {
                    await source.loadCart(accessToken: accessToken)
                    await source.loadOrders(accessToken: accessToken)
                }
                source.onTabChange?(.orders)
                return
            }

            throw CheckoutError.backend(sagaState.failureReason ?? "Ödeme yetkilendirilemedi.")
        } catch {
            banner = PaymentBanner(
                title: "Ödeme tamamlanamadı",
                message: error.localizedDescription,
                style: .error
            )
        }
    }

    func dismissHostedCheckout() {
        hostedCheckoutSession = nil
    }

    private func buildStartSagaRequest(from source: ContentViewModel) -> StartSagaRequest {
        StartSagaRequest(
            deliveryAddress: .init(
                street: source.selectedAddress.line1,
                district: source.selectedAddress.regionLine,
                city: "Antalya",
                postalCode: "07000",
                lat: source.selectedAddress.latitude ?? 36.8848,
                lng: source.selectedAddress.longitude ?? 30.7056
            ),
            paymentMethod: "CREDIT_CARD",
            orderType: "DELIVERY",
            notes: source.selectedAddress.detail
        )
    }

    private func callbackURL(orderID: String, paymentID: String) -> URL? {
        baseURL
            .appendingPathComponent("saga/orders")
            .appendingPathComponent(orderID)
            .appendingPathComponent("payment-callback")
            .appendingPathComponent(paymentID)
    }

    private func pollSagaState(sagaID: String, accessToken: String?) async throws -> SagaStateResponse {
        var lastState: SagaStateResponse?

        for _ in 0..<40 {
            var request = URLRequest(url: baseURL.appendingPathComponent("saga/orders").appendingPathComponent(sagaID))
            request.httpMethod = "GET"
            if let accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CheckoutError.invalidResponse
            }

            if httpResponse.statusCode == 404 {
                try await Task.sleep(nanoseconds: 500_000_000)
                continue
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if let gatewayError = try? JSONDecoder().decode(GatewayErrorResponse.self, from: data) {
                    throw CheckoutError.backend(gatewayError.error.message)
                }
                throw CheckoutError.backend("HTTP Error \(httpResponse.statusCode)")
            }

            let state = try JSONDecoder().decode(SagaStateResponse.self, from: data)
            lastState = state

            if state.checkoutForm != nil || state.status == "Failed" || state.status == "Compensated" || state.status == "PaymentAuthorized" {
                return state
            }

            try await Task.sleep(nanoseconds: 500_000_000)
        }

        if let lastState {
            return lastState
        }

        throw CheckoutError.backend("SAGA durumu zamanında hazır olmadı.")
    }

    private func decodeCheckoutHTML(from content: String) -> String {
        let rawHTML: String
        if let data = Data(base64Encoded: content), let html = String(data: data, encoding: .utf8) {
            rawHTML = html
        } else {
            rawHTML = content
        }

        if rawHTML.range(of: "<html", options: .caseInsensitive) != nil {
            return rawHTML
        }

        return """
        <!DOCTYPE html>
        <html lang="tr">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
          <style>
            html, body {
              margin: 0;
              padding: 0;
              min-height: 100%;
              background: #ffffff;
            }
            body {
              display: block;
            }
            #iyzipay-checkout-form {
              min-height: 100vh;
            }
          </style>
        </head>
        <body>
          <div id="iyzipay-checkout-form" class="responsive"></div>
          \(rawHTML)
        </body>
        </html>
        """
    }
}

private enum CheckoutError: LocalizedError {
    case invalidResponse
    case invalidCallbackURL
    case backend(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Servisten beklenen cevap alınamadı."
        case .invalidCallbackURL:
            return "Callback URL oluşturulamadı."
        case .backend(let message):
            return message
        }
    }
}

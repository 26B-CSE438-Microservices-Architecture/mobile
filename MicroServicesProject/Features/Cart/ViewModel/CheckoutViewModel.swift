import Foundation
import Combine

@MainActor
final class CheckoutViewModel: ObservableObject {
    struct HostedCheckoutSession: Identifiable, Equatable {
        let id: String
        let paymentID: String
        let callbackURL: URL
        let callbackToken: String
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

    private struct CreatePaymentRequest: Encodable {
        struct Buyer: Encodable {
            let id: String
            let name: String
            let surname: String
            let email: String
            let identityNumber: String
            let gsmNumber: String
            let registrationAddress: String
            let ip: String
            let city: String
            let country: String
            let zipCode: String
        }

        struct Item: Encodable {
            let id: String
            let name: String
            let category1: String
            let itemType: String
            let price: String
        }

        let orderId: String
        let amount: Int
        let currency: String
        let paymentMethod: String
        let buyer: Buyer
        let items: [Item]
        let callbackUrl: String
    }

    private struct CreatePaymentResponse: Decodable {
        struct Payment: Decodable {
            let id: String
            let status: String
            let failureReason: String?
        }

        struct CheckoutForm: Decodable {
            let token: String
            let content: String
        }

        let payment: Payment
        let checkoutForm: CheckoutForm?
    }

    private struct PaymentResponse: Decodable {
        struct Payment: Decodable {
            let id: String
            let status: String
            let failureReason: String?
        }

        let payment: Payment
    }

    @Published private(set) var hostedCheckoutSession: HostedCheckoutSession?
    @Published private(set) var isPreparingCheckout = false
    @Published private(set) var isCompletingCheckout = false
    @Published private(set) var banner: PaymentBanner?

    private let baseURL = URL(string: "http://127.0.0.1:3000")!
    private let demoUserID = "ios_demo_user"

    func startHostedCheckout(using source: ContentViewModel) async {
        guard !source.cartItems.isEmpty else { return }

        isPreparingCheckout = true
        banner = nil
        defer { isPreparingCheckout = false }

        do {
            let orderID = "ord_\(UUID().uuidString.lowercased())"
            let callbackURL = "microservicesproject://payment-callback/{paymentId}"
            let requestBody = buildCreatePaymentRequest(orderID: orderID, callbackURL: callbackURL, source: source)

            var request = URLRequest(url: baseURL.appendingPathComponent("payments"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("idem-\(UUID().uuidString.lowercased())", forHTTPHeaderField: "Idempotency-Key")
            request.setValue(demoUserID, forHTTPHeaderField: "X-User-Id")
            request.httpBody = try JSONEncoder().encode(requestBody)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CheckoutError.invalidResponse
            }

            let payload = try JSONDecoder().decode(CreatePaymentResponse.self, from: data)

            guard (200...299).contains(httpResponse.statusCode) else {
                throw CheckoutError.backend(payload.payment.failureReason ?? "Payment service isteği başarısız oldu.")
            }

            guard payload.payment.status == "AWAITING_FORM", let checkoutForm = payload.checkoutForm else {
                throw CheckoutError.backend(payload.payment.failureReason ?? "Checkout form alınamadı.")
            }

            let resolvedCallbackURL = URL(string: callbackURL.replacingOccurrences(of: "{paymentId}", with: payload.payment.id))
            guard let resolvedCallbackURL else {
                throw CheckoutError.invalidCallbackURL
            }

            hostedCheckoutSession = HostedCheckoutSession(
                id: payload.payment.id,
                paymentID: payload.payment.id,
                callbackURL: resolvedCallbackURL,
                callbackToken: checkoutForm.token,
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

    func handleHostedCheckoutCallback(using source: ContentViewModel) async {
        guard let session = hostedCheckoutSession, !isCompletingCheckout else { return }

        isCompletingCheckout = true
        defer { isCompletingCheckout = false }

        do {
            var request = URLRequest(url: baseURL
                .appendingPathComponent("payments")
                .appendingPathComponent(session.paymentID)
                .appendingPathComponent("checkout-form")
                .appendingPathComponent("callback"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: ["token": session.callbackToken])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw CheckoutError.invalidResponse
            }

            let payload = try JSONDecoder().decode(PaymentResponse.self, from: data)

            if payload.payment.status == "AUTHORIZED" {
                hostedCheckoutSession = nil
                banner = PaymentBanner(
                    title: "Ödeme başarılı",
                    message: "Hosted checkout tamamlandı, sipariş oluşturuldu.",
                    style: .success
                )
                source.placeOrder()
                return
            }

            throw CheckoutError.backend(payload.payment.failureReason ?? "Ödeme yetkilendirilemedi.")
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

    private func buildCreatePaymentRequest(orderID: String, callbackURL: String, source: ContentViewModel) -> CreatePaymentRequest {
        let nameParts = source.userProfile.fullName.split(separator: " ")
        let firstName = nameParts.first.map { String($0) } ?? "Test"
        let surnameValue = nameParts.dropFirst().map { String($0) }.joined(separator: " ")
        let surname = surnameValue.isEmpty ? "User" : surnameValue
        let addressLine = "\(source.selectedAddress.line1), \(source.selectedAddress.detail)"

        let items = source.cartItems.map { item in
            CreatePaymentRequest.Item(
                id: item.product.id.uuidString.lowercased(),
                name: item.product.name,
                category1: source.cartVendor?.kind == .market ? "Market" : "Food",
                itemType: "PHYSICAL",
                price: item.product.price.formatted(.number.precision(.fractionLength(2)).locale(Locale(identifier: "en_US_POSIX")))
            )
        }

        return CreatePaymentRequest(
            orderId: orderID,
            amount: Int((source.cartTotal * 100).rounded()),
            currency: "TRY",
            paymentMethod: "card",
            buyer: .init(
                id: demoUserID,
                name: firstName,
                surname: surname,
                email: source.userProfile.email,
                identityNumber: "74300864791",
                gsmNumber: source.userProfile.phone,
                registrationAddress: addressLine,
                ip: "127.0.0.1",
                city: "Istanbul",
                country: "Turkey",
                zipCode: "34000"
            ),
            items: items,
            callbackUrl: callbackURL
        )
    }

    private func decodeCheckoutHTML(from content: String) -> String {
        if let data = Data(base64Encoded: content), let html = String(data: data, encoding: .utf8) {
            return html
        }

        return content
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

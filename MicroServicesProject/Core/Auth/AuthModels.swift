import Foundation

struct SessionUser: Codable, Equatable {
    let id: String
    let fullName: String
    let email: String
    let phone: String
}

struct AuthSessionSnapshot: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let user: SessionUser
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequestBody: Encodable {
    let name: String
    let surname: String
    let email: String
    let phone_number: String
    let password: String
}

struct LoginResponse: Decodable {
    struct User: Decodable {
        let id: String
        let name: String
        let surname: String
        let email: String
        let phone_number: String?
    }

    let access_token: String
    let refresh_token: String
    let expires_in: Int
    let user: User
}

struct RegisterResponse: Decodable {
    let message: String
    let user_id: String
}

struct RefreshTokenRequestBody: Encodable {
    let refresh_token: String
}

struct RefreshTokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
}

struct LogoutRequestBody: Encodable {
    let refresh_token: String
}

struct ChangePasswordRequestBody: Encodable {
    let current_password: String
    let new_password: String
}

struct ForgotPasswordRequestBody: Encodable {
    let email: String
}

struct ResetPasswordRequestBody: Encodable {
    let token: String
    let new_password: String
}

struct VerifyTokenRequestBody: Encodable {
    let token: String
}

struct RegisterDeviceRequestBody: Encodable {
    let device_token: String
    let platform: String
}

struct AddCartItemRequestBody: Encodable {
    let productId: String
    let restaurantId: String?
    let quantity: Int
}

struct UpdateCartItemRequestBody: Encodable {
    let quantity: Int
}

struct GenericMessageResponse: Decodable {
    let message: String?
}

struct CreateAddressRequestBody: Encodable {
    let label: String
    let street: String
    let city: String
    let postalCode: String
    let lat: Double
    let lng: Double
}

struct UpdateUserProfileRequestBody: Encodable {
    let name: String
    let phone: String
}

struct CurrentUserProfileResponse: Decodable {
    struct AddressResponse: Decodable {
        let id: String
        let label: String?
        let street: String?
        let city: String?
        let postalCode: String?
        let lat: Double
        let lng: Double
    }

    let id: String
    let name: String
    let email: String
    let phone: String?
    let role: String?
    let active: Bool?
    let addresses: [AddressResponse]?
}

extension CurrentUserProfileResponse {
    var sessionUser: SessionUser {
        SessionUser(
            id: id,
            fullName: name,
            email: email,
            phone: phone ?? ""
        )
    }

    var appUserProfile: UserProfile {
        UserProfile(
            fullName: name,
            email: email,
            phone: phone ?? "",
            walletBalance: 0,
            loyaltyPoints: 0,
            addresses: (addresses ?? []).enumerated().map { index, address in
                address.appAddress(contactPhone: phone ?? "", isCurrent: index == 0)
            },
            paymentMethods: [],
            role: role ?? "Customer",
            isActive: active ?? true
        )
    }
}

private extension CurrentUserProfileResponse.AddressResponse {
    func appAddress(contactPhone: String, isCurrent: Bool) -> Address {
        let resolvedTitle = label?.nilIfBlank ?? "Adres"
        let resolvedStreet = street?.nilIfBlank ?? "Adres bilgisi yok"
        let resolvedCity = city?.nilIfBlank ?? "Şehir bilgisi yok"
        let postal = postalCode?.nilIfBlank
        let coordinateLine = String(format: "%.4f, %.4f", lat, lng)

        return Address(
            id: id,
            title: resolvedTitle,
            line1: resolvedStreet,
            detail: resolvedCity,
            regionLine: resolvedCity,
            buildingLine: postal.map { "Posta Kodu: \($0)" } ?? "Konum: \(coordinateLine)",
            maskedPhone: contactPhone.maskedPhone,
            showsMapPreview: false,
            isCurrent: isCurrent,
            latitude: lat,
            longitude: lng
        )
    }
}

private extension String {
    var nilIfBlank: String? {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self
    }
}

private extension String {
    var maskedPhone: String {
        let digits = filter(\.isNumber)
        guard digits.count >= 7 else { return self }

        let prefix = String(digits.prefix(3))
        let suffix = String(digits.suffix(2))
        return "\(prefix)*****\(suffix)"
    }
}

import Foundation

struct AuthAPIClient {
    private let baseURL = URL(string: "https://gw.cse.akdeniz.edu.tr/cse-438")!
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func login(email: String, password: String) async throws -> AuthSessionSnapshot {
        let response: LoginResponse = try await sendRequest(
            path: "/api/v1/auth/login",
            method: "POST",
            body: LoginRequest(email: email, password: password)
        )

        return AuthSessionSnapshot(
            accessToken: response.access_token,
            refreshToken: response.refresh_token,
            user: SessionUser(
                id: response.user.id,
                fullName: [response.user.name, response.user.surname]
                    .filter { !$0.isEmpty }
                    .joined(separator: " "),
                email: response.user.email,
                phone: response.user.phone_number ?? ""
            )
        )
    }

    func register(
        name: String,
        surname: String,
        email: String,
        phoneNumber: String,
        password: String
    ) async throws -> RegisterResponse {
        try await sendRequest(
            path: "/api/v1/auth/register",
            method: "POST",
            body: RegisterRequestBody(
                name: name,
                surname: surname,
                email: email,
                phone_number: phoneNumber,
                password: password
            )
        )
    }

    func refreshAccessToken(refreshToken: String) async throws -> RefreshTokenResponse {
        try await sendRequest(
            path: "/api/v1/auth/refresh-token",
            method: "POST",
            body: RefreshTokenRequestBody(refresh_token: refreshToken)
        )
    }

    func fetchCurrentUserProfile(accessToken: String) async throws -> CurrentUserProfileResponse {
        try await sendRequest(
            path: "/api/v1/users/me",
            method: "GET",
            accessToken: accessToken
        )
    }

    func logout(refreshToken: String) async throws {
        let _: EmptyResponse = try await sendRequest(
            path: "/api/v1/auth/logout",
            method: "POST",
            body: LogoutRequestBody(refresh_token: refreshToken)
        )
    }

    func createAddress(
        accessToken: String,
        label: String,
        street: String,
        city: String,
        postalCode: String,
        lat: Double,
        lng: Double
    ) async throws {
        let _: EmptyResponse = try await sendRequest(
            path: "/api/v1/users/me/addresses",
            method: "POST",
            body: CreateAddressRequestBody(
                label: label,
                street: street,
                city: city,
                postalCode: postalCode,
                lat: lat,
                lng: lng
            ),
            accessToken: accessToken
        )
    }

    func deleteAddress(accessToken: String, id: String) async throws {
        let _: EmptyResponse = try await sendRequest(
            path: "/api/v1/users/me/addresses/\(id)",
            method: "DELETE",
            accessToken: accessToken
        )
    }

    private func sendRequest<Response: Decodable>(
        path: String,
        method: String,
        accessToken: String? = nil
    ) async throws -> Response {
        try await sendRequest(
            path: path,
            method: method,
            body: Optional<EmptyBody>.none,
            accessToken: accessToken
        )
    }

    private func sendRequest<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body? = nil,
        accessToken: String? = nil
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppAuthError(message: "Servisten geçerli bir cevap alınamadı.")
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw AppAuthError(message: decodeErrorMessage(from: data, statusCode: httpResponse.statusCode))
        }

        if Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw AppAuthError(message: "Beklenmeyen response formatı alındı.")
        }
    }

    private func decodeErrorMessage(from data: Data, statusCode: Int) -> String {
        if let structured = try? decoder.decode(StructuredErrorResponse.self, from: data),
           let message = structured.error.message,
           !message.isEmpty {
            return message
        }

        if let flat = try? decoder.decode(FlatErrorResponse.self, from: data) {
            if let message = flat.message, !message.isEmpty {
                return message
            }
            if let error = flat.error, !error.isEmpty {
                return error
            }
        }

        if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
            return raw
        }

        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}

private struct StructuredErrorResponse: Decodable {
    struct ErrorBody: Decodable {
        let code: String?
        let message: String?
        let status: Int?
    }

    let error: ErrorBody
}

private struct FlatErrorResponse: Decodable {
    let error: String?
    let message: String?
}

private struct EmptyBody: Encodable {}
private struct EmptyResponse: Decodable {}

struct AppAuthError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}

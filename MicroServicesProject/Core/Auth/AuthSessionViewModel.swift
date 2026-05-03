import Combine
import Foundation

@MainActor
final class AuthSessionViewModel: ObservableObject {
    @Published private(set) var currentUser: SessionUser?
    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var isRestoringSession = true
    @Published private(set) var isSubmitting = false

    var isAuthenticated: Bool {
        snapshot != nil
    }

    private let client = AuthAPIClient()
    private let storageKey = "auth.session.snapshot"
    private var snapshot: AuthSessionSnapshot?

    init() {
        Task {
            await restoreSession()
        }
    }

    func signIn(email: String, password: String) async throws {
        isSubmitting = true
        defer { isSubmitting = false }

        let session = try await client.login(email: email, password: password)
        let profileResponse = try await client.fetchCurrentUserProfile(accessToken: session.accessToken)
        apply(
            session: AuthSessionSnapshot(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                user: profileResponse.sessionUser
            ),
            userProfile: profileResponse.appUserProfile
        )
    }

    func register(
        name: String,
        surname: String,
        email: String,
        phoneNumber: String,
        password: String
    ) async throws {
        isSubmitting = true
        defer { isSubmitting = false }

        _ = try await client.register(
            name: name,
            surname: surname,
            email: email,
            phoneNumber: phoneNumber,
            password: password
        )

        let session = try await client.login(email: email, password: password)
        let profileResponse = try await client.fetchCurrentUserProfile(accessToken: session.accessToken)
        apply(
            session: AuthSessionSnapshot(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                user: profileResponse.sessionUser
            ),
            userProfile: profileResponse.appUserProfile
        )
    }

    func signOut() async -> String? {
        isSubmitting = true
        defer { isSubmitting = false }

        let refreshToken = snapshot?.refreshToken
        clearSession()

        guard let refreshToken else {
            return nil
        }

        do {
            try await client.logout(refreshToken: refreshToken)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    func createAddress(
        label: String,
        street: String,
        city: String,
        postalCode: String,
        lat: Double,
        lng: Double
    ) async throws {
        guard let snapshot else {
            throw AppAuthError(message: "Oturum bulunamadı.")
        }

        isSubmitting = true
        defer { isSubmitting = false }

        try await client.createAddress(
            accessToken: snapshot.accessToken,
            label: label,
            street: street,
            city: city,
            postalCode: postalCode,
            lat: lat,
            lng: lng
        )

        try await refreshUserProfile(using: snapshot)
    }

    func deleteAddress(id: String) async throws {
        guard let snapshot else {
            throw AppAuthError(message: "Oturum bulunamadı.")
        }

        isSubmitting = true
        defer { isSubmitting = false }

        try await client.deleteAddress(accessToken: snapshot.accessToken, id: id)
        try await refreshUserProfile(using: snapshot)
    }

    private func restoreSession() async {
        defer { isRestoringSession = false }

        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }

        do {
            let storedSession = try JSONDecoder().decode(AuthSessionSnapshot.self, from: data)
            let refreshResponse = try await client.refreshAccessToken(refreshToken: storedSession.refreshToken)
            try await refreshUserProfile(
                using: AuthSessionSnapshot(
                    accessToken: refreshResponse.access_token,
                    refreshToken: storedSession.refreshToken,
                    user: storedSession.user
                )
            )
        } catch {
            clearSession()
        }
    }

    private func apply(session: AuthSessionSnapshot, userProfile: UserProfile) {
        snapshot = session
        currentUser = session.user
        self.userProfile = userProfile

        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func clearSession() {
        snapshot = nil
        currentUser = nil
        userProfile = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func refreshUserProfile(using session: AuthSessionSnapshot) async throws {
        let profileResponse = try await client.fetchCurrentUserProfile(accessToken: session.accessToken)
        apply(
            session: AuthSessionSnapshot(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                user: profileResponse.sessionUser
            ),
            userProfile: profileResponse.appUserProfile
        )
    }
}

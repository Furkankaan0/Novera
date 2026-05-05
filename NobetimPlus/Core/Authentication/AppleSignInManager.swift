import AuthenticationServices
import Combine
import Foundation

@MainActor
final class AppleSignInManager: NSObject, ObservableObject {
    @Published private(set) var userIdentifier: String?

    private let userIdentifierKey = "apple.userIdentifier"

    override init() {
        self.userIdentifier = KeychainService.read(userIdentifierKey)
        super.init()
    }

    func makeRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleAuthorization(_ authorization: ASAuthorization, currentProfile: UserProfile) -> UserProfile? {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return nil }
        let identifier = credential.user
        KeychainService.save(identifier, for: userIdentifierKey)
        userIdentifier = identifier

        var profile = currentProfile
        profile.appleUserIdentifier = identifier
        if let email = credential.email {
            profile.email = email
        }
        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        if !fullName.isEmpty {
            profile.fullName = fullName
        }
        return profile
    }

    func signOut() {
        KeychainService.delete(userIdentifierKey)
        userIdentifier = nil
    }
}

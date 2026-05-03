// AuthService.swift
// Növera — Authentication Service (MVP: Local Profile)

import Foundation
import Combine
import AuthenticationServices

final class AuthService: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    private let userRepo = UserRepository.shared
    private let keychain = KeychainService.shared

    init() {
        loadSession()
    }

    // MARK: - Session
    private func loadSession() {
        if let user = userRepo.getCurrentUser() {
            currentUser = user
            isAuthenticated = true
        }
    }

    // MARK: - Local Profile Creation (MVP)
    func createLocalProfile(
        name: String,
        email: String,
        profession: Profession,
        department: String
    ) {
        let user = User(
            name: name,
            email: email,
            role: .member,
            profession: profession,
            department: department
        )
        userRepo.saveUser(user)
        currentUser = user
        isAuthenticated = true
    }

    // MARK: - Sign In with Apple (Skeleton)
    // TODO: Complete with backend endpoint when ready
    func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }

            let userId = credential.user
            let email = credential.email ?? "\(userId)@privaterelay.appleid.com"
            let name = [
                credential.fullName?.givenName,
                credential.fullName?.familyName
            ].compactMap { $0 }.joined(separator: " ")

            if let tokenData = credential.identityToken,
               let tokenString = String(data: tokenData, encoding: .utf8) {
                // TODO: Send to backend for verification
                keychain.authToken = tokenString
            }

            let user = User(
                name: name.isEmpty ? "Apple Kullanıcısı" : name,
                email: email,
                profession: .other,
                department: ""
            )
            userRepo.saveUser(user)
            currentUser = user
            isAuthenticated = true

        case .failure(let err):
            error = err.localizedDescription
        }
    }

    // MARK: - Sign Out
    func signOut() {
        userRepo.clearUser()
        keychain.clearAll()
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Update Profile
    func updateProfile(
        name: String,
        profession: Profession,
        department: String,
        hourlyRate: Double?
    ) {
        guard var user = currentUser else { return }
        user.name = name
        user.profession = profession
        user.department = department
        user.hourlyRate = hourlyRate
        userRepo.updateUser(user)
        currentUser = user
    }
}

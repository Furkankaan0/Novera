// KeychainService.swift
// Növera — Secure Token Storage

import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private let service = NoveraConstants.bundleID

    // MARK: - Save
    @discardableResult
    func save(_ value: String, for key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete existing
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    // MARK: - Load
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    // MARK: - Delete
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    // MARK: - Token Helpers
    var authToken: String? {
        get { load(key: "authToken") }
        set {
            if let token = newValue {
                save(token, for: "authToken")
            } else {
                delete(key: "authToken")
            }
        }
    }

    var refreshToken: String? {
        get { load(key: "refreshToken") }
        set {
            if let token = newValue {
                save(token, for: "refreshToken")
            } else {
                delete(key: "refreshToken")
            }
        }
    }

    func clearAll() {
        delete(key: "authToken")
        delete(key: "refreshToken")
    }
}

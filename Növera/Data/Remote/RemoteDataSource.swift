// RemoteDataSource.swift
// Növera — Remote Data Source Protocol (Backend-ready)

import Foundation
import Combine

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case notFound
    case serverError(Int)
    case decodingError
    case networkUnavailable
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Geçersiz URL"
        case .unauthorized: return "Yetkisiz erişim. Lütfen tekrar giriş yapın."
        case .notFound: return "Kayıt bulunamadı."
        case .serverError(let code): return "Sunucu hatası: \(code)"
        case .decodingError: return "Veri işleme hatası."
        case .networkUnavailable: return "İnternet bağlantısı yok."
        case .unknown: return "Bilinmeyen hata."
        }
    }
}

// MARK: - Remote Shift Data Source Protocol
// TODO: Implement with URLSession when backend is ready
protocol RemoteShiftDataSource {
    func fetchShifts(userId: UUID, since: Date?) async throws -> [Shift]
    func createShift(_ shift: Shift) async throws -> Shift
    func updateShift(_ shift: Shift) async throws -> Shift
    func deleteShift(id: UUID) async throws
}

// MARK: - Remote Team Data Source Protocol
protocol RemoteTeamDataSource {
    func fetchTeams(userId: UUID) async throws -> [Team]
    func createTeam(_ team: Team) async throws -> Team
    func joinTeam(inviteCode: String, userId: UUID) async throws -> Team
    func fetchAnnouncements(teamId: UUID) async throws -> [Announcement]
    func postAnnouncement(_ announcement: Announcement) async throws -> Announcement
    func fetchSwapRequests(userId: UUID) async throws -> [ShiftSwapRequest]
    func createSwapRequest(_ request: ShiftSwapRequest) async throws -> ShiftSwapRequest
    func respondToSwapRequest(id: UUID, status: SwapStatus) async throws -> ShiftSwapRequest
}

// MARK: - Remote Auth Data Source Protocol
protocol RemoteAuthDataSource {
    func signIn(email: String, password: String) async throws -> (User, String)  // returns (user, token)
    func signInWithApple(identityToken: String, nonce: String) async throws -> (User, String)
    func signUp(name: String, email: String, password: String) async throws -> (User, String)
    func refreshToken(_ token: String) async throws -> String
    func signOut(token: String) async throws
}

// MARK: - Stub Remote Shift Implementation (returns errors until backend connects)
final class StubRemoteShiftDataSource: RemoteShiftDataSource {
    func fetchShifts(userId: UUID, since: Date?) async throws -> [Shift] {
        throw APIError.networkUnavailable
    }
    func createShift(_ shift: Shift) async throws -> Shift {
        throw APIError.networkUnavailable
    }
    func updateShift(_ shift: Shift) async throws -> Shift {
        throw APIError.networkUnavailable
    }
    func deleteShift(id: UUID) async throws {
        throw APIError.networkUnavailable
    }
}

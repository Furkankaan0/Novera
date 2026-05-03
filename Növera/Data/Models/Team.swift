// Team.swift
// Növera — Team Data Model

import Foundation
import SwiftUI

// MARK: - Team Member
struct TeamMember: Identifiable, Codable, Equatable {
    var id: UUID
    var userId: UUID
    var name: String
    var profession: Profession
    var role: UserRole
    var joinedAt: Date

    static func preview(name: String, role: UserRole = .member) -> TeamMember {
        TeamMember(
            id: UUID(),
            userId: UUID(),
            name: name,
            profession: .nurse,
            role: role,
            joinedAt: Date()
        )
    }
}

// MARK: - Team Model
struct Team: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var description: String
    var inviteCode: String
    var members: [TeamMember]
    var createdBy: UUID
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        inviteCode: String = Self.generateInviteCode(),
        members: [TeamMember] = [],
        createdBy: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.inviteCode = inviteCode
        self.members = members
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var memberCount: Int { members.count }

    static func generateInviteCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    static let preview = Team(
        name: "Acil Servis Ekibi",
        description: "A Blok Acil Servis",
        members: [
            .preview(name: "Ayşe Kaya", role: .teamLead),
            .preview(name: "Mehmet Yılmaz"),
            .preview(name: "Zeynep Demir"),
        ],
        createdBy: UUID()
    )
}

// MARK: - Announcement
struct Announcement: Identifiable, Codable, Equatable {
    var id: UUID
    var teamId: UUID
    var title: String
    var message: String
    var createdBy: UUID
    var createdByName: String
    var createdAt: Date
    var isRead: Bool = false

    static let preview = Announcement(
        id: UUID(),
        teamId: UUID(),
        title: "Yarınki Nöbet Değişikliği",
        message: "29 Nisan gece vardiyasında ek personel ihtiyacı oluşmuştur. Gönüllü olan ekip üyeleri lütfen mesaj atsın.",
        createdBy: UUID(),
        createdByName: "Dr. Ahmet Çelik",
        createdAt: Date()
    )
}

// MARK: - ShiftSwapRequest
enum SwapStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"

    var displayName: String {
        switch self {
        case .pending: return "Bekliyor"
        case .accepted: return "Kabul Edildi"
        case .rejected: return "Reddedildi"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .pending: return NoveraColors.warning
        case .accepted: return NoveraColors.success
        case .rejected: return NoveraColors.error
        }
    }
}

struct ShiftSwapRequest: Identifiable, Codable, Equatable {
    var id: UUID
    var shiftId: UUID
    var requestedBy: UUID
    var requestedByName: String
    var requestedTo: UUID?
    var requestedToName: String?
    var status: SwapStatus
    var message: String
    var createdAt: Date
    var updatedAt: Date

    static let preview = ShiftSwapRequest(
        id: UUID(),
        shiftId: UUID(),
        requestedBy: UUID(),
        requestedByName: "Ayşe Kaya",
        status: .pending,
        message: "Bu gece vardiyasını değiştirebilir miyiz?",
        createdAt: Date(),
        updatedAt: Date()
    )
}

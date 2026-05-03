// User.swift
// Növera — User Data Model

import Foundation
import SwiftUI

// MARK: - User Role
enum UserRole: String, Codable, CaseIterable {
    case admin = "admin"
    case teamLead = "teamLead"
    case member = "member"

    var displayName: String {
        switch self {
        case .admin: return "Yönetici"
        case .teamLead: return "Ekip Sorumlusu"
        case .member: return "Üye"
        }
    }

    var icon: String {
        switch self {
        case .admin: return "crown.fill"
        case .teamLead: return "star.fill"
        case .member: return "person.fill"
        }
    }

    var color: Color {
        switch self {
        case .admin: return NoveraColors.warning
        case .teamLead: return NoveraColors.primary
        case .member: return NoveraColors.textSecondary
        }
    }
}

// MARK: - Profession
enum Profession: String, Codable, CaseIterable {
    case nurse = "nurse"
    case doctor = "doctor"
    case clinicSupport = "clinicSupport"
    case security = "security"
    case technician = "technician"
    case other = "other"

    var displayName: String {
        switch self {
        case .nurse: return "Hemşire"
        case .doctor: return "Doktor"
        case .clinicSupport: return "Klinik Destek"
        case .security: return "Güvenlik"
        case .technician: return "Teknik Personel"
        case .other: return "Diğer"
        }
    }

    var icon: String {
        switch self {
        case .nurse: return "cross.case.fill"
        case .doctor: return "stethoscope"
        case .clinicSupport: return "heart.text.square.fill"
        case .security: return "shield.fill"
        case .technician: return "wrench.and.screwdriver.fill"
        case .other: return "person.fill"
        }
    }
}

// MARK: - User Model
struct User: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var email: String
    var role: UserRole
    var profession: Profession
    var department: String
    var teamIds: [UUID]
    var hourlyRate: Double?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        role: UserRole = .member,
        profession: Profession = .other,
        department: String = "",
        teamIds: [UUID] = [],
        hourlyRate: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.profession = profession
        self.department = department
        self.teamIds = teamIds
        self.hourlyRate = hourlyRate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.dropFirst().first?.prefix(1) ?? ""
        return "\(first)\(last)".uppercased()
    }

    // MARK: - Preview Stub
    static let preview = User(
        name: "Ayşe Kaya",
        email: "ayse.kaya@novera.app",
        role: .teamLead,
        profession: .nurse,
        department: "Acil Servis"
    )
}

// EarningsSummary.swift
// Növera — Earnings Summary Model

import Foundation

struct EarningsSummary: Codable, Equatable {
    var month: Date
    var normalHours: Double
    var overtimeHours: Double
    var holidayHours: Double
    var nightHours: Double
    var hourlyRate: Double
    var overtimeMultiplier: Double
    var holidayMultiplier: Double
    var nightBonusRate: Double

    // MARK: - Computed Revenue
    var normalRevenue: Double {
        normalHours * hourlyRate
    }

    var overtimeRevenue: Double {
        overtimeHours * hourlyRate * overtimeMultiplier
    }

    var holidayRevenue: Double {
        holidayHours * hourlyRate * holidayMultiplier
    }

    var nightBonus: Double {
        nightHours * hourlyRate * nightBonusRate
    }

    var estimatedRevenue: Double {
        normalRevenue + overtimeRevenue + holidayRevenue + nightBonus
    }

    var totalHours: Double {
        normalHours + overtimeHours + holidayHours
    }

    var monthFormatted: String {
        month.monthYearFormatted
    }

    // MARK: - Preview
    static let preview = EarningsSummary(
        month: Date(),
        normalHours: 160,
        overtimeHours: 24,
        holidayHours: 8,
        nightHours: 48,
        hourlyRate: 150,
        overtimeMultiplier: 1.5,
        holidayMultiplier: 2.0,
        nightBonusRate: 0.25
    )
}

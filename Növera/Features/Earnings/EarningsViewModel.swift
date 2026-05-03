// EarningsViewModel.swift
// Növera — Earnings ViewModel

import SwiftUI
import Combine

final class EarningsViewModel: ObservableObject {
    @Published var currentMonthSummary: EarningsSummary? = nil
    @Published var last6Months: [EarningsSummary] = []
    @Published var selectedMonth: Date = Date()
    @Published var hourlyRate: Double = NoveraConstants.defaultHourlyRate
    @Published var overtimeMultiplier: Double = NoveraConstants.defaultOvertimeMultiplier
    @Published var holidayMultiplier: Double = NoveraConstants.defaultHolidayMultiplier
    @Published var showSettings: Bool = false

    private let revenueService = RevenueCalculationService.shared
    private let repo = ShiftRepository.shared
    private let userRepo = UserRepository.shared

    init() {
        loadSettings()
    }

    func loadData() {
        let userId = userRepo.getCurrentUser()?.id ?? UUID()
        let allShifts = repo.getShifts().filter { $0.userId == userId }

        // Load user's custom rate if set
        if let userRate = userRepo.getCurrentUser()?.hourlyRate {
            hourlyRate = userRate
        }

        currentMonthSummary = revenueService.calculateMonthlySummary(
            shifts: allShifts,
            for: selectedMonth,
            hourlyRate: hourlyRate,
            overtimeMultiplier: overtimeMultiplier,
            holidayMultiplier: holidayMultiplier
        )

        last6Months = revenueService.last6MonthsSummaries(shifts: allShifts, hourlyRate: hourlyRate)
    }

    func navigateMonth(by offset: Int) {
        withAnimation(NoveraAnimation.spring) {
            selectedMonth = Calendar.current.date(byAdding: .month, value: offset, to: selectedMonth) ?? selectedMonth
        }
        loadData()
    }

    func saveSettings() {
        UserDefaults.standard.set(hourlyRate, forKey: NoveraConstants.Keys.hourlyRate)
        UserDefaults.standard.set(overtimeMultiplier, forKey: NoveraConstants.Keys.overtimeMultiplier)
        UserDefaults.standard.set(holidayMultiplier, forKey: NoveraConstants.Keys.holidayMultiplier)
        loadData()
    }

    private func loadSettings() {
        let savedRate = UserDefaults.standard.double(forKey: NoveraConstants.Keys.hourlyRate)
        if savedRate > 0 { hourlyRate = savedRate }
        let savedOT = UserDefaults.standard.double(forKey: NoveraConstants.Keys.overtimeMultiplier)
        if savedOT > 0 { overtimeMultiplier = savedOT }
        let savedHoliday = UserDefaults.standard.double(forKey: NoveraConstants.Keys.holidayMultiplier)
        if savedHoliday > 0 { holidayMultiplier = savedHoliday }
    }

    var revenueChartData: [(String, Double)] {
        last6Months.map { summary in
            let label = summary.month.formatted("MMM")
            return (label, summary.estimatedRevenue)
        }
    }

    var maxRevenue: Double {
        last6Months.map { $0.estimatedRevenue }.max() ?? 1
    }
}

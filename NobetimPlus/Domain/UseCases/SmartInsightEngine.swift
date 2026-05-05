import Foundation

enum SmartInsightKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case info
    case warning
    case success
    case money
    case workload

    var id: String { rawValue }
}

struct SmartInsight: Identifiable, Codable, Hashable {
    var id = UUID()
    var kind: SmartInsightKind
    var title: String
    var message: String
}

struct SmartInsightEngine {
    private let calculator: WorkCalculationEngine
    private let calendar: Calendar

    init(calculator: WorkCalculationEngine = WorkCalculationEngine(), calendar: Calendar = .current) {
        self.calculator = calculator
        self.calendar = calendar
    }

    func generateInsights(shifts: [Shift], profile: UserProfile, month: Date = .now) -> [SmartInsight] {
        let monthShifts = shifts.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
        let summary = calculator.makeMonthlySummary(
            shifts: shifts,
            month: month,
            settings: WorkCalculationSettings(
                monthlyNormalHours: profile.monthlyNormalHours,
                overtimeHourlyRate: profile.overtimeHourlyRate,
                holidayHourlyRate: profile.holidayHourlyRate,
                nightWorkMultiplier: profile.nightWorkMultiplier,
                additionalPayment: profile.additionalPayment
            )
        )
        var insights: [SmartInsight] = []

        if summary.nightShiftHours > 0 {
            insights.append(SmartInsight(kind: .info, title: "Gece nöbeti", message: "Bu ay \(Int(summary.nightShiftHours)) saat gece mesain var. Dinlenme aralıklarını planlaman iyi olabilir."))
        }

        let longShiftCount = monthShifts.filter { calculator.calculateShiftDuration($0) >= 12 }.count
        if longShiftCount >= 3 {
            insights.append(SmartInsight(kind: .warning, title: "Uzun vardiya yoğunluğu", message: "Son planında \(longShiftCount) uzun vardiya görünüyor. Bu yalnızca çalışma yükü farkındalığı içindir."))
        }

        if summary.officialHolidayHours > 0 {
            insights.append(SmartInsight(kind: .money, title: "Resmi tatil mesaisi", message: "Resmi tatil olarak işaretlenen \(Int(summary.officialHolidayHours)) saat var. Gelir hesabı tahminidir."))
        }

        if summary.overtimeHours > profile.monthlyNormalHours * 0.15 {
            insights.append(SmartInsight(kind: .workload, title: "Fazla mesai artıyor", message: "Bu ay fazla mesai sınırına yaklaşıyorsun. Kurum planını ayrıca kontrol et."))
        }

        if insights.isEmpty {
            insights.append(SmartInsight(kind: .success, title: "Dengeli görünüm", message: "Bu ay vardiya dağılımın dengeli görünüyor."))
        }

        return insights
    }
}

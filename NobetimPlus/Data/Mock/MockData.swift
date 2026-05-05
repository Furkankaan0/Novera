import Foundation

enum MockData {
    static let profile = UserProfile.demo

    static let shifts: [Shift] = {
        let calendar = Calendar.current
        let today = Date()

        func shift(
            dayOffset: Int,
            hour: Int,
            minute: Int = 0,
            duration: Double,
            title: String,
            unit: String,
            kind: WorkEntryKind,
            type: ShiftType,
            holiday: Bool = false,
            night: Bool = false
        ) -> Shift {
            let day = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
            let start = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
            let end = start.addingTimeInterval(duration * 3600)
            return Shift(
                title: title,
                date: day,
                startDate: start,
                endDate: end,
                department: "Acil Servis",
                unit: unit,
                type: type,
                workKind: kind,
                notes: "Hasta adı, TC kimlik veya protokol numarası girilmemelidir.",
                isNightShift: night,
                isOfficialHoliday: holiday,
                isWeekend: calendar.isDateInWeekend(day),
                colorTag: kind.colorTag,
                reminderEnabled: true
            )
        }

        return [
            shift(dayOffset: 0, hour: 8, duration: 12, title: "08-20 Nöbet", unit: "Acil Triaj", kind: .normalShift, type: .day),
            shift(dayOffset: 1, hour: 17, duration: 3, title: "17-20 Ek Mesai", unit: "Gözlem", kind: .overtime, type: .overtime),
            shift(dayOffset: 3, hour: 20, duration: 12, title: "20-08 Gece", unit: "Acil", kind: .nightWork, type: .night, night: true),
            shift(dayOffset: 5, hour: 9, duration: 7.5, title: "7.5s Resmi Tatil", unit: "Servis", kind: .officialHoliday, type: .officialHoliday, holiday: true),
            shift(dayOffset: 8, hour: 8, duration: 24, title: "24 Saat Nöbet", unit: "Yoğun Bakım", kind: .normalShift, type: .twentyFourHour)
        ]
    }()

    static let teams: [Team] = {
        let owner = UUID()
        let members = [
            TeamMember(id: owner, name: "Ayşe Demir", role: .owner, department: "Acil Servis", avatarColor: .blue, phoneOptional: nil, emailOptional: nil, workloadScore: 72, isOnDutyToday: true, isOnLeave: false),
            TeamMember(id: UUID(), name: "Mehmet Kaya", role: .manager, department: "Acil Servis", avatarColor: .mint, phoneOptional: nil, emailOptional: nil, workloadScore: 61, isOnDutyToday: true, isOnLeave: false),
            TeamMember(id: UUID(), name: "Zeynep Şahin", role: .member, department: "Acil Servis", avatarColor: .purple, phoneOptional: nil, emailOptional: nil, workloadScore: 45, isOnDutyToday: false, isOnLeave: true),
            TeamMember(id: UUID(), name: "Can Yılmaz", role: .member, department: "Acil Servis", avatarColor: .orange, phoneOptional: nil, emailOptional: nil, workloadScore: 83, isOnDutyToday: false, isOnLeave: false)
        ]
        return [Team(id: UUID(), name: "Acil A Ekibi", department: "Acil Servis", inviteCode: "NOBET-PLUS", members: members, createdBy: owner, createdAt: .now)]
    }()
}

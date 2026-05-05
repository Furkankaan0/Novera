import Foundation

struct ExportReportUseCase {
    func makeCSV(shifts: [Shift], calculator: WorkCalculationEngine = WorkCalculationEngine()) -> String {
        let header = "Tarih,Başlık,Birim,Tür,Saat,Süre\n"
        let rows = shifts.map { shift in
            let range = "\(shift.startDate.formatted(date: .omitted, time: .shortened))-\(shift.endDate.formatted(date: .omitted, time: .shortened))"
            return "\(shift.date.formatted(date: .numeric, time: .omitted)),\(shift.title),\(shift.unit),\(shift.workKind.localizedTitle),\(range),\(calculator.calculateShiftDuration(shift))"
        }
        return header + rows.joined(separator: "\n")
    }
}

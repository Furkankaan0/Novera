// ShiftDetailView.swift
// Növera — Shift Detail Screen

import SwiftUI

struct ShiftDetailView: View {
    let shift: Shift
    @State private var showEdit = false
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) var dismiss
    private let shiftService = ShiftService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: NoveraSpacing.lg) {
                // Hero card
                heroCard

                // Detail grid
                detailGrid

                // Notes
                if !shift.notes.isEmpty {
                    notesCard
                }

                // Actions
                actionButtons
            }
            .padding(NoveraSpacing.md)
            .padding(.bottom, NoveraSpacing.xl)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Vardiya Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Düzenle", systemImage: "pencil") { showEdit = true }
                    Button("Sil", systemImage: "trash", role: .destructive) { showDeleteConfirm = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(NoveraColors.primary)
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            AddShiftView(editingShift: shift)
        }
        .confirmationDialog(
            "Vardiyayı Sil",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Sil", role: .destructive) {
                shiftService.deleteShift(id: shift.id)
                HapticManager.notification(.success)
                dismiss()
            }
        } message: {
            Text("Bu vardiyayı silmek istediğinizden emin misiniz?")
        }
    }

    // MARK: - Hero Card
    var heroCard: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.md) {
            HStack {
                ShiftTypeBadge(type: shift.shiftType)
                Spacer()
                if shift.isActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(NoveraColors.success)
                            .frame(width: 8, height: 8)
                        Text("Aktif")
                            .font(NoveraFonts.caption(.semibold))
                            .foregroundStyle(NoveraColors.success)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(NoveraColors.success.opacity(0.12)))
                }
            }

            Text(shift.title)
                .font(NoveraFonts.title1(.bold))
                .foregroundStyle(NoveraColors.textPrimary)

            HStack(spacing: NoveraSpacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Süre")
                        .font(NoveraFonts.caption())
                        .foregroundStyle(NoveraColors.textSecondary)
                    Text(shift.durationInHours.hoursFormatted)
                        .font(NoveraFonts.display(28))
                        .foregroundStyle(shift.shiftType.color)
                }

                Divider().frame(height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Zaman")
                        .font(NoveraFonts.caption())
                        .foregroundStyle(NoveraColors.textSecondary)
                    Text(shift.timeRangeFormatted)
                        .font(NoveraFonts.headline(.semibold))
                }
            }
        }
        .padding(NoveraSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: NoveraRadius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            shift.shiftType.color.opacity(0.15),
                            shift.shiftType.color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: NoveraRadius.xl, style: .continuous)
                        .strokeBorder(shift.shiftType.color.opacity(0.2), lineWidth: 1)
                )
        )
        .noveraShadow(NoveraShadows.soft)
    }

    // MARK: - Detail Grid
    var detailGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NoveraSpacing.sm) {
            DetailCell(icon: "calendar", label: "Tarih", value: shift.startDate.dayFormatted)
            DetailCell(icon: "mappin", label: "Konum", value: shift.location.isEmpty ? "Belirtilmedi" : shift.location)
            if shift.isHoliday {
                DetailCell(icon: "flag.fill", label: "Resmi Tatil", value: "Evet", color: NoveraColors.shiftHoliday)
            }
            if shift.isOvertime {
                DetailCell(icon: "clock.badge.plus", label: "Fazla Mesai", value: "Evet", color: NoveraColors.shiftOvertime)
            }
            if let rate = shift.hourlyRate {
                DetailCell(icon: "turkishlirasign", label: "Saatlik Ücret", value: "₺\(Int(rate))")
                DetailCell(
                    icon: "chart.bar.fill",
                    label: "Tahmini Kazanç",
                    value: "₺\(Int(shift.durationInHours * rate))",
                    color: NoveraColors.accentGreen
                )
            }
        }
    }

    // MARK: - Notes
    var notesCard: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            Label("Notlar", systemImage: "note.text")
                .font(NoveraFonts.subheadline(.semibold))
                .foregroundStyle(NoveraColors.textSecondary)
            Text(shift.notes)
                .font(NoveraFonts.callout())
                .foregroundStyle(NoveraColors.textPrimary)
        }
        .padding(NoveraSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassBackground(cornerRadius: NoveraRadius.lg)
        .noveraShadow(NoveraShadows.soft)
    }

    // MARK: - Action Buttons
    var actionButtons: some View {
        VStack(spacing: NoveraSpacing.sm) {
            NoveraSecondaryButton("Takas İsteği Gönder", icon: "arrow.left.arrow.right") {
                // TODO: Show swap request sheet
            }
        }
    }
}

// MARK: - Detail Cell
struct DetailCell: View {
    let icon: String
    let label: String
    let value: String
    var color: Color = NoveraColors.primary

    var body: some View {
        HStack(spacing: NoveraSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(NoveraFonts.caption())
                    .foregroundStyle(NoveraColors.textSecondary)
                Text(value)
                    .font(NoveraFonts.subheadline(.semibold))
                    .foregroundStyle(NoveraColors.textPrimary)
                    .lineLimit(1)
            }
        }
        .padding(NoveraSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassBackground(cornerRadius: NoveraRadius.sm)
    }
}

#Preview {
    NavigationStack {
        ShiftDetailView(shift: .previewDay)
    }
}

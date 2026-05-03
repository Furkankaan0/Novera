// ShiftDetailView.swift
// Növera — Premium Shift Detail Screen

import SwiftUI

struct ShiftDetailView: View {
    let shift: Shift
    @State private var showEdit = false
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) var dismiss
    private let shiftService = ShiftService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: NSpacing.xl) {
                // Hero card
                heroCard
                    .entrance(delay: 0)

                // Detail grid
                detailGrid
                    .entrance(delay: 0.06)

                // Notes
                if !shift.notes.isEmpty {
                    notesCard
                        .entrance(delay: 0.10)
                }

                // Actions
                actionButtons
                    .entrance(delay: 0.14)
            }
            .padding(NSpacing.base)
            .padding(.bottom, NSpacing.xxl)
        }
        .screenBackground()
        .navigationTitle("Vardiya Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Düzenle", systemImage: "pencil") { showEdit = true }
                    Button("Sil", systemImage: "trash", role: .destructive) { showDeleteConfirm = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(NColor.primaryFallback)
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
        VStack(alignment: .leading, spacing: NSpacing.lg) {
            HStack {
                ShiftTypeBadge(type: shift.shiftType)
                Spacer()
                if shift.isActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(NColor.success)
                            .frame(width: 8, height: 8)
                        Text("Aktif")
                            .font(NFont.caption(.bold))
                            .foregroundStyle(NColor.success)
                    }
                    .padding(.horizontal, NSpacing.md)
                    .padding(.vertical, NSpacing.xs)
                    .background(
                        Capsule()
                            .fill(NColor.success.opacity(0.12))
                            .overlay(Capsule().stroke(NColor.success.opacity(0.25), lineWidth: 0.5))
                    )
                }
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: NSpacing.sm) {
                    Text(shift.title)
                        .font(NFont.title1(.bold))
                        .foregroundStyle(NColor.textPrimary)

                    HStack(spacing: NSpacing.lg) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Süre")
                                .font(NFont.caption(.medium))
                                .foregroundStyle(NColor.textSecondary)
                            Text(shift.durationInHours.hoursFormatted)
                                .font(NFont.display(28))
                                .foregroundStyle(shift.shiftType.color)
                                .contentTransition(.numericText())
                        }

                        Divider().frame(height: 44)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Zaman")
                                .font(NFont.caption(.medium))
                                .foregroundStyle(NColor.textSecondary)
                            Text(shift.timeRangeFormatted)
                                .font(NFont.headline(.semibold))
                                .foregroundStyle(NColor.textPrimary)
                        }
                    }
                }

                Spacer()

                Soft3DIcon(
                    icon: shift.shiftType.icon,
                    size: .large,
                    color: shift.shiftType.color
                )
            }
        }
        .padding(NSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: NRadius.large, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            shift.shiftType.color.opacity(0.12),
                            shift.shiftType.color.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: NRadius.large, style: .continuous)
                        .strokeBorder(shift.shiftType.color.opacity(0.2), lineWidth: 1)
                )
        )
        .depth3D(radius: NRadius.large)
        .nShadow(NShadow.colored(shift.shiftType.color))
    }

    // MARK: - Detail Grid
    var detailGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NSpacing.md) {
            PremiumDetailCell(icon: "calendar", label: "Tarih", value: shift.startDate.dayFormatted, color: NColor.primaryFallback)
            PremiumDetailCell(icon: "mappin", label: "Konum", value: shift.location.isEmpty ? "Belirtilmedi" : shift.location, color: NColor.info)
            if shift.isHoliday {
                PremiumDetailCell(icon: "flag.fill", label: "Resmi Tatil", value: "Evet", color: NColor.shiftHoliday)
            }
            if shift.isOvertime {
                PremiumDetailCell(icon: "clock.badge.plus", label: "Fazla Mesai", value: "Evet", color: NColor.shiftOvertime)
            }
            if let rate = shift.hourlyRate {
                PremiumDetailCell(icon: "turkishlirasign", label: "Saatlik Ücret", value: "₺\(Int(rate))", color: NColor.warning)
                PremiumDetailCell(
                    icon: "chart.bar.fill",
                    label: "Tahmini Kazanç",
                    value: "₺\(Int(shift.durationInHours * rate))",
                    color: NColor.success
                )
            }
        }
    }

    // MARK: - Notes
    var notesCard: some View {
        VStack(alignment: .leading, spacing: NSpacing.sm) {
            Label("Notlar", systemImage: "note.text")
                .font(NFont.subheadline(.semibold))
                .foregroundStyle(NColor.textSecondary)
            Text(shift.notes)
                .font(NFont.callout())
                .foregroundStyle(NColor.textPrimary)
                .lineSpacing(4)
        }
        .premiumGlass(radius: NRadius.large, padding: NSpacing.lg)
    }

    // MARK: - Action Buttons
    var actionButtons: some View {
        VStack(spacing: NSpacing.md) {
            PremiumSecondaryButton(title: "Takas İsteği Gönder", icon: "arrow.left.arrow.right") {
                // TODO: Show swap request sheet
            }
        }
    }
}

// MARK: - Premium Detail Cell
struct PremiumDetailCell: View {
    let icon: String
    let label: String
    let value: String
    var color: Color = NColor.primaryFallback

    var body: some View {
        HStack(spacing: NSpacing.md) {
            Soft3DIcon(icon: icon, size: .small, color: color)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(NFont.caption(.medium))
                    .foregroundStyle(NColor.textSecondary)
                Text(value)
                    .font(NFont.subheadline(.semibold))
                    .foregroundStyle(NColor.textPrimary)
                    .lineLimit(1)
            }
        }
        .premiumGlass(radius: NRadius.small, padding: NSpacing.md)
    }
}

// Legacy alias
typealias DetailCell = PremiumDetailCell

#Preview {
    NavigationStack {
        ShiftDetailView(shift: .previewDay)
    }
}

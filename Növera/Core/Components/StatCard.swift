// StatCard.swift
// Növera — Statistics & Chart Components

import SwiftUI

// MARK: - Mini Bar Chart
struct MiniBarChart: View {
    let values: [Double]
    let color: Color
    var maxValue: Double? = nil

    private var computedMax: Double {
        maxValue ?? (values.max() ?? 1.0)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color.opacity(0.2 + (value / computedMax) * 0.8))
                    .frame(maxWidth: .infinity)
                    .frame(height: max(4, CGFloat(value / computedMax) * 48))
                    .animation(NoveraAnimation.spring, value: value)
            }
        }
        .frame(height: 48)
    }
}

// MARK: - Ring Progress
struct RingProgress: View {
    let progress: Double // 0.0 - 1.0
    let color: Color
    var lineWidth: CGFloat = 8
    var size: CGFloat = 56

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(NoveraAnimation.spring, value: animatedProgress)
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = min(progress, 1.0)
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(NoveraAnimation.spring) {
                animatedProgress = min(newValue, 1.0)
            }
        }
        .accessibilityLabel("İlerleme: %\(Int(progress * 100))")
    }
}

// MARK: - Weekly Hours Bar
struct WeeklyHoursBar: View {
    let days: [(String, Double)]
    let maxHours: Double
    let color: Color

    var body: some View {
        HStack(alignment: .bottom, spacing: NoveraSpacing.xs) {
            ForEach(days, id: \.0) { day, hours in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(hours > 0 ? color : color.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: max(4, CGFloat(hours / maxHours) * 60))

                    Text(day)
                        .font(NoveraFonts.caption())
                        .foregroundStyle(NoveraColors.textTertiary)
                }
            }
        }
        .frame(height: 80)
    }
}

// MARK: - Earnings Progress Card
struct EarningsProgressCard: View {
    let currentAmount: Double
    let targetAmount: Double
    let currency: String = "₺"

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }

    @State private var barWidth: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tahmini Aylık Kazanç")
                        .font(NoveraFonts.footnote(.medium))
                        .foregroundStyle(NoveraColors.textSecondary)
                    Text("\(currency)\(Int(currentAmount).formatted())")
                        .font(NoveraFonts.display(28))
                        .foregroundStyle(NoveraColors.textPrimary)
                }
                Spacer()
                RingProgress(progress: progress, color: NoveraColors.accentGreen, lineWidth: 6, size: 50)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(NoveraColors.accentGreen.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(NoveraColors.accentGreen)
                        .frame(width: barWidth, height: 6)
                        .onAppear {
                            withAnimation(NoveraAnimation.spring.delay(0.2)) {
                                barWidth = geo.size.width * progress
                            }
                        }
                }
            }
            .frame(height: 6)

            HStack {
                Text("Hedef: \(currency)\(Int(targetAmount).formatted())")
                    .font(NoveraFonts.caption())
                    .foregroundStyle(NoveraColors.textTertiary)
                Spacer()
                Text("%\(Int(progress * 100))")
                    .font(NoveraFonts.caption(.semibold))
                    .foregroundStyle(NoveraColors.accentGreen)
            }
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.lg)
        .noveraShadow(NoveraShadows.soft)
    }
}

#Preview {
    VStack(spacing: 20) {
        MiniBarChart(
            values: [4, 8, 6, 12, 8, 4, 10],
            color: NoveraColors.primary
        )
        .frame(height: 60)
        .padding()
        .glassBackground()

        EarningsProgressCard(currentAmount: 8500, targetAmount: 12000)

        WeeklyHoursBar(
            days: [("Pt", 8), ("Sa", 0), ("Ça", 12), ("Pe", 8), ("Cu", 8), ("Ct", 0), ("Pz", 0)],
            maxHours: 12,
            color: NoveraColors.primary
        )
        .padding()
        .glassBackground()
    }
    .padding()
}

//
//  WeightView.swift
//  WakeFit
//
//  Weight tracking and progress screen
//  Shows stat cards, line graph, and logging functionality
//

import SwiftUI
import SwiftData

struct WeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - SwiftData Queries

    @Query(sort: \WeightEntry.date, order: .reverse) var weightEntries: [WeightEntry]
    @Query var users: [User]

    // MARK: - State

    @State private var showLogSheet: Bool = false
    @State private var newWeight: String = ""
    @State private var showSaved: Bool = false

    // MARK: - Computed Properties

    private var currentWeight: Double? {
        weightEntries.sorted { $0.date > $1.date }.first?.weight
    }

    private var startingWeight: Double? {
        users.first?.startingWeight
    }

    private var targetWeight: Double? {
        users.first?.targetWeight
    }

    private var totalChange: Double? {
        guard let current = currentWeight, let start = startingWeight else { return nil }
        return current - start
    }

    private var last30DaysEntries: [WeightEntry] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return weightEntries.filter { $0.date >= thirtyDaysAgo }.sorted { $0.date < $1.date }
    }

    var body: some View {
        ZStack {
            AppColors.bgBase
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppColors.textMuted)
                        }

                        Spacer()

                        Text("Discipline")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        Button {
                            // Settings
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColors.accentTeal)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight Progress")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Track your tactical mass.")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Stat Cards
                    HStack(spacing: 12) {
                        StatCard(
                            label: "STARTING",
                            value: startingWeight != nil ? String(format: "%.1f lbs", startingWeight! * 2.20462) : "—",
                            isHighlighted: false
                        )

                        StatCard(
                            label: "CURRENT",
                            value: currentWeight != nil ? String(format: "%.1f lbs", currentWeight! * 2.20462) : "—",
                            isHighlighted: true
                        )

                        StatCard(
                            label: "TOTAL\nCHANGE",
                            value: totalChange != nil ? String(format: "%.1f lbs", totalChange! * 2.20462) : "—",
                            isHighlighted: false,
                            changeColor: totalChange != nil ? (totalChange! < 0 ? AppColors.success : AppColors.danger) : nil
                        )
                    }
                    .padding(.horizontal, 20)

                    // Graph Card
                    if !weightEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("LBS")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppColors.textMuted)
                                    .tracking(0.08 * 12)

                                Spacer()

                                Text("LAST 30 DAYS")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppColors.textMuted)
                                    .tracking(0.08 * 12)
                            }

                            WeightGraphView(
                                entries: last30DaysEntries,
                                targetWeight: targetWeight
                            )
                            .frame(height: 200)
                        }
                        .padding(20)
                        .background(AppColors.bgCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }

                    // Log Weight Button
                    Button {
                        showLogSheet = true
                    } label: {
                        Text("LOG TODAY'S WEIGHT")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppColors.accentTeal)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showLogSheet) {
            LogWeightSheet(
                newWeight: $newWeight,
                showSaved: $showSaved,
                onSave: {
                    saveWeight()
                }
            )
        }
    }

    // MARK: - Functions

    private func saveWeight() {
        guard let w = Double(newWeight), w > 0, w < 300 else { return }
        // Convert from lbs to kg
        let weightInKg = w / 2.20462
        let entry = WeightEntry(date: Date(), weight: weightInKg)
        modelContext.insert(entry)
        try? modelContext.save()
        showSaved = true
        newWeight = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showLogSheet = false
            showSaved = false
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let label: String
    let value: String
    let isHighlighted: Bool
    var changeColor: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.textMuted)
                .tracking(0.08 * 11)
                .lineLimit(2)
                .frame(height: 24, alignment: .top)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(changeColor ?? (isHighlighted ? AppColors.accentTeal : AppColors.textPrimary))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(isHighlighted ? AppColors.bgCard : AppColors.bgCard.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHighlighted ? AppColors.accentTeal : AppColors.cardBorder, lineWidth: isHighlighted ? 2 : 1)
        )
    }
}

// MARK: - Weight Graph Component

struct WeightGraphView: View {
    let entries: [WeightEntry]
    let targetWeight: Double?

    private var minWeight: Double {
        let allWeights = entries.map { $0.weight * 2.20462 }
        if let target = targetWeight {
            return min(allWeights.min() ?? 0, target * 2.20462) - 5
        }
        return (allWeights.min() ?? 0) - 5
    }

    private var maxWeight: Double {
        let allWeights = entries.map { $0.weight * 2.20462 }
        if let target = targetWeight {
            return max(allWeights.max() ?? 200, target * 2.20462) + 5
        }
        return (allWeights.max() ?? 200) + 5
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Target line (dashed)
                if let target = targetWeight {
                    let targetLbs = target * 2.20462
                    let yPosition = geometry.size.height * CGFloat(1 - (targetLbs - minWeight) / (maxWeight - minWeight))

                    Path { path in
                        path.move(to: CGPoint(x: 0, y: yPosition))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .foregroundStyle(AppColors.textMuted)

                    Text("Target: \(Int(targetLbs))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.textMuted)
                        .position(x: geometry.size.width - 60, y: yPosition - 12)
                }

                // Weight line
                if entries.count > 1 {
                    Path { path in
                        for (index, entry) in entries.enumerated() {
                            let weightLbs = entry.weight * 2.20462
                            let x = geometry.size.width * CGFloat(index) / CGFloat(max(entries.count - 1, 1))
                            let y = geometry.size.height * CGFloat(1 - (weightLbs - minWeight) / (maxWeight - minWeight))

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(AppColors.accentTeal, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    // Data points
                    ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                        let weightLbs = entry.weight * 2.20462
                        let x = geometry.size.width * CGFloat(index) / CGFloat(max(entries.count - 1, 1))
                        let y = geometry.size.height * CGFloat(1 - (weightLbs - minWeight) / (maxWeight - minWeight))

                        Circle()
                            .fill(AppColors.accentTeal)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
}

// MARK: - Log Weight Sheet Component

struct LogWeightSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var newWeight: String
    @Binding var showSaved: Bool
    let onSave: () -> Void

    var body: some View {
        ZStack {
            AppColors.bgCard
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Log Weight")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                            .frame(width: 36, height: 36)
                            .background(AppColors.bgBase)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("WEIGHT (LBS)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.textMuted)
                        .tracking(0.08 * 12)

                    TextField("182.4", text: $newWeight)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(20)
                        .background(AppColors.bgBase)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.cardBorder, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)

                Spacer()

                // Save Button
                Button {
                    onSave()
                } label: {
                    HStack(spacing: 8) {
                        if showSaved {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                        }

                        Text(showSaved ? "Logged!" : "Save Entry")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(newWeight.isEmpty ? AppColors.textMuted : (showSaved ? AppColors.success : AppColors.accentTeal))
                    .cornerRadius(16)
                }
                .disabled(newWeight.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        WeightView()
            .modelContainer(for: [WeightEntry.self, User.self], inMemory: true)
    }
}

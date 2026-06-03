//
//  SleepView.swift
//  WakeFit
//
//  Sleep discipline tracking screen
//  Log whether you slept on time (before 11:50 PM)
//

import SwiftUI
import SwiftData

struct SleepView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - SwiftData Query

    @Query(sort: \SleepEntry.date, order: .reverse) var sleepEntries: [SleepEntry]

    // MARK: - State

    @State private var sleptOnTime: Bool? = nil
    @State private var notes: String = ""
    @State private var showSaved: Bool = false

    // MARK: - Computed Properties

    /// Today's sleep entry (if exists)
    private var todayEntry: SleepEntry? {
        sleepEntries.first { Calendar.current.isDateInToday($0.date) }
    }

    /// Last 7 days of sleep entries
    private var last7Days: [SleepEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            return sleepEntries.first { calendar.isDate($0.date, inSameDayAs: date) }
        }
    }

    /// Sleep streak percentage
    private var streakPercentage: Int {
        let onTimeCount = last7Days.filter { $0.sleptOnTime }.count
        return last7Days.isEmpty ? 0 : Int((Double(onTimeCount) / Double(last7Days.count)) * 100)
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
                        Text("SLEEP CHECK-IN")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Did you sleep on time last night?")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Toggle Cards
                    VStack(spacing: 16) {
                        // Yes Card
                        SleepToggleCard(
                            title: "Yes",
                            subtitle: "before 11:50 PM",
                            icon: "checkmark",
                            isSelected: sleptOnTime == true,
                            isLogged: todayEntry != nil && todayEntry?.sleptOnTime == true,
                            isPositive: true
                        ) {
                            sleptOnTime = true
                        }

                        // No Card
                        SleepToggleCard(
                            title: "No",
                            subtitle: "I stayed up late",
                            icon: "xmark",
                            isSelected: sleptOnTime == false,
                            isLogged: todayEntry != nil && todayEntry?.sleptOnTime == false,
                            isPositive: false
                        ) {
                            sleptOnTime = false
                        }
                    }
                    .padding(.horizontal, 20)

                    // Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("NOTES")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                            .tracking(0.08 * 12)

                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Any disruptions? Caffeine late in the day?")
                                    .font(.system(size: 15))
                                    .foregroundStyle(AppColors.textMuted.opacity(0.5))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                            }

                            TextEditor(text: $notes)
                                .font(.system(size: 15))
                                .foregroundStyle(AppColors.textPrimary)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(height: 100)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        .background(AppColors.bgCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.cardBorder, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)

                    // Save Button
                    Button {
                        saveSleepEntry()
                    } label: {
                        HStack(spacing: 8) {
                            if showSaved {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                            }

                            Text(showSaved ? "Logged!" : "SAVE LOG")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(sleptOnTime != nil ? (showSaved ? AppColors.success : AppColors.accentTeal) : AppColors.textMuted)
                        .cornerRadius(16)
                    }
                    .disabled(sleptOnTime == nil)
                    .padding(.horizontal, 20)

                    // 7-Day History
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("7-DAY HISTORY")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.textMuted)
                                .tracking(0.08 * 12)

                            Spacer()

                            Text("\(streakPercentage)% Streak")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.accentTeal)
                        }

                        HStack(spacing: 12) {
                            ForEach(0..<7, id: \.self) { index in
                                SleepHistoryDot(entry: last7Days[safe: index], isToday: index == 0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Pre-populate if already logged today
            if let entry = todayEntry {
                sleptOnTime = entry.sleptOnTime
                notes = entry.notes
            }
        }
    }

    // MARK: - Functions

    /// Save sleep entry
    private func saveSleepEntry() {
        guard let onTime = sleptOnTime else { return }

        // Check if already logged today
        if let existing = todayEntry {
            existing.sleptOnTime = onTime
            existing.notes = notes
        } else {
            let entry = SleepEntry(
                date: Calendar.current.startOfDay(for: Date()),
                sleptOnTime: onTime,
                notes: notes
            )
            modelContext.insert(entry)
        }

        try? modelContext.save()
        showSaved = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showSaved = false
        }
    }
}

// MARK: - Sleep Toggle Card Component

struct SleepToggleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let isLogged: Bool
    let isPositive: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(isSelected ? (isPositive ? AppColors.accentTeal : AppColors.danger) : AppColors.textMuted)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(isSelected ? (isPositive ? AppColors.accentTeal.opacity(0.15) : AppColors.danger.opacity(0.15)) : AppColors.bgBase)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(isSelected ? (isPositive ? AppColors.accentTeal : AppColors.danger) : AppColors.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                if isLogged {
                    Text("LOGGED")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.accentTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.accentTeal.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(20)
            .background(isSelected ? (isPositive ? AppColors.bgCard : AppColors.bgCard) : AppColors.bgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? (isPositive ? AppColors.accentTeal : AppColors.danger) : AppColors.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sleep History Dot Component

struct SleepHistoryDot: View {
    let entry: SleepEntry?
    let isToday: Bool

    var body: some View {
        ZStack {
            if let entry = entry {
                // Has data
                Circle()
                    .fill(entry.sleptOnTime ? AppColors.accentTeal : AppColors.danger)
                    .frame(width: 40, height: 40)

                Image(systemName: entry.sleptOnTime ? "checkmark" : "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
            } else if isToday {
                // Today - not logged yet
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                    .foregroundStyle(AppColors.accentTeal)
                    .frame(width: 40, height: 40)

                Text("T")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.accentTeal)
            } else {
                // No data
                Circle()
                    .fill(AppColors.cardBorder)
                    .frame(width: 40, height: 40)
            }
        }
    }
}

// MARK: - Array Safe Subscript Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        SleepView()
            .modelContainer(for: SleepEntry.self, inMemory: true)
    }
}

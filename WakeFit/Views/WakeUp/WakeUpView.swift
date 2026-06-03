//
//  WakeUpView.swift
//  WakeFit
//
//  Wake-up time logging screen
//  Allows users to log their daily wake-up time
//

import SwiftUI
import SwiftData

struct WakeUpView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - SwiftData Query

    @Query(sort: \WakeUpEntry.date, order: .reverse) var wakeUpEntries: [WakeUpEntry]

    // MARK: - State

    @State private var selectedTime: Date = Date()
    @State private var showSaved: Bool = false

    // MARK: - Computed Properties

    /// Today's wake-up entry (if exists)
    private var todayEntry: WakeUpEntry? {
        wakeUpEntries.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        ZStack {
            AppColors.bgBase
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Wake-Up Log")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(AppColors.accentTeal)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Today's Status Card
                    if let entry = todayEntry {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TODAY'S WAKE-UP")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.accentTeal)
                                .tracking(0.08 * 12)

                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(AppColors.success)

                                Text("Already logged: \(formatTime(entry.wakeUpTime))")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(AppColors.textPrimary)
                            }

                            Text("Tap below to update your wake-up time")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(20)
                        .background(AppColors.bgCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.success, lineWidth: 1)
                        )
                    }

                    // Time Picker Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SELECT TIME")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                            .tracking(0.08 * 12)

                        DatePicker("", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()

                        // Use Current Time Button
                        Button {
                            selectedTime = Date()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 16))

                                Text("USE CURRENT TIME")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(AppColors.accentTeal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppColors.bgBase)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.accentTeal, lineWidth: 1.5)
                            )
                        }
                    }
                    .padding(20)
                    .background(AppColors.bgCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.cardBorder, lineWidth: 1)
                    )

                    // Log Button
                    Button {
                        logWakeUp()
                    } label: {
                        HStack(spacing: 8) {
                            if showSaved {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                            }

                            Text(showSaved ? "Logged!" : (todayEntry != nil ? "Update Wake-Up" : "Log Wake-Up"))
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(showSaved ? AppColors.success : AppColors.accentTeal)
                        .cornerRadius(16)
                    }

                    // History Section
                    if !wakeUpEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("RECENT HISTORY")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.textMuted)
                                .tracking(0.08 * 12)

                            VStack(spacing: 12) {
                                ForEach(wakeUpEntries.prefix(7), id: \.id) { entry in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(formatDate(entry.date))
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(AppColors.textPrimary)

                                            Text(formatTime(entry.wakeUpTime))
                                                .font(.system(size: 12))
                                                .foregroundStyle(AppColors.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(AppColors.accentTeal)
                                    }
                                    .padding(16)
                                    .background(AppColors.bgBase)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(20)
                        .background(AppColors.bgCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.cardBorder, lineWidth: 1)
                        )
                    }

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundStyle(AppColors.accentTeal)
                }
            }
        }
    }

    // MARK: - Functions

    /// Logs or updates wake-up time
    private func logWakeUp() {
        // Check if already logged today
        if let existing = todayEntry {
            // Update existing entry
            existing.wakeUpTime = selectedTime
        } else {
            // Create new entry
            let entry = WakeUpEntry(
                date: Calendar.current.startOfDay(for: Date()),
                wakeUpTime: selectedTime
            )
            modelContext.insert(entry)
        }

        // Save to SwiftData
        try? modelContext.save()

        // Show success feedback
        showSaved = true

        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showSaved = false
        }
    }

    /// Formats date as "Mon, Oct 24"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd"
        return formatter.string(from: date)
    }

    /// Formats time as "6:42 AM"
    private func formatTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

#Preview {
    NavigationStack {
        WakeUpView()
            .modelContainer(for: WakeUpEntry.self, inMemory: true)
    }
}

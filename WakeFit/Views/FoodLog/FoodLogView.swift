//
//  FoodLogView.swift
//  WakeFit
//
//  Food logging screen with time blocks (Morning, Afternoon, Evening)
//  Allows users to log food entries for each time block
//

import SwiftUI
import SwiftData

struct FoodLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - SwiftData Query

    @Query(sort: \FoodLog.entryTime, order: .reverse) var foodLogs: [FoodLog]

    // MARK: - State

    @State private var selectedDate: Date = Date()
    @State private var showAddSheet: Bool = false
    @State private var activeTimeBlock: String = ""
    @State private var expandedSections: Set<String> = ["morning", "afternoon", "evening"]
    @State private var editingEntry: FoodLog? = nil
    @State private var editText: String = ""
    @State private var showEditSheet: Bool = false

    // MARK: - Computed Properties

    /// Current time block based on hour
    private var currentTimeBlock: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<13: return "morning"     // 12:00 AM – 1:00 PM
        case 13..<17: return "afternoon"  // 1:00 PM – 5:00 PM
        default: return "evening"         // 5:00 PM – 11:59 PM
        }
    }

    /// Logs for selected date and specific block
    private func logsFor(block: String) -> [FoodLog] {
        foodLogs.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate) &&
            $0.timeBlock == block
        }
        .sorted { $0.entryTime < $1.entryTime }
    }

    var body: some View {
        ZStack {
            Color(AppColors.bgBase)
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundStyle(AppColors.accentTeal)
                    }

                    Spacer()

                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.textMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Title
                Text("Today's Food Log")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Date Selector
                HStack(spacing: 16) {
                    Button {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .foregroundStyle(AppColors.textMuted)
                    }

                    Text(formatDate(selectedDate))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(minWidth: 120)

                    Button {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18))
                            .foregroundStyle(AppColors.textMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // Scrollable Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Morning Section
                        TimeBlockSection(
                            title: "Morning",
                            timeRange: "12 AM - 1 PM",
                            logs: logsFor(block: "morning"),
                            isExpanded: expandedSections.contains("morning"),
                            onToggle: {
                                toggleSection("morning")
                            },
                            onAddFood: {
                                activeTimeBlock = "morning"
                                showAddSheet = true
                            },
                            onDelete: { log in
                                deleteEntry(log)
                            },
                            onEdit: { log in
                                editingEntry = log
                                editText = log.foodText
                                showEditSheet = true
                            }
                        )

                        // Afternoon Section
                        TimeBlockSection(
                            title: "Afternoon",
                            timeRange: "1 PM - 5 PM",
                            logs: logsFor(block: "afternoon"),
                            isExpanded: expandedSections.contains("afternoon"),
                            onToggle: {
                                toggleSection("afternoon")
                            },
                            onAddFood: {
                                activeTimeBlock = "afternoon"
                                showAddSheet = true
                            },
                            onDelete: { log in
                                deleteEntry(log)
                            },
                            onEdit: { log in
                                editingEntry = log
                                editText = log.foodText
                                showEditSheet = true
                            }
                        )

                        // Evening Section
                        TimeBlockSection(
                            title: "Evening",
                            timeRange: "5 PM - 9:30 PM",
                            logs: logsFor(block: "evening"),
                            isExpanded: expandedSections.contains("evening"),
                            onToggle: {
                                toggleSection("evening")
                            },
                            onAddFood: {
                                activeTimeBlock = "evening"
                                showAddSheet = true
                            },
                            onDelete: { log in
                                deleteEntry(log)
                            },
                            onEdit: { log in
                                editingEntry = log
                                editText = log.foodText
                                showEditSheet = true
                            }
                        )

                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAddSheet) {
            AddFoodItemView(
                timeBlock: activeTimeBlock,
                onSave: { foodText in
                    saveFoodEntry(text: foodText, timeBlock: activeTimeBlock)
                }
            )
        }
        .sheet(isPresented: $showEditSheet) {
            if let entry = editingEntry {
                AddFoodItemView(
                    timeBlock: entry.timeBlock,
                    onSave: { foodText in
                        saveEdit(entry: entry, newText: foodText)
                    }
                )
            }
        }
    }

    // MARK: - Functions

    /// Toggle section expansion
    private func toggleSection(_ section: String) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
    }

    /// Save food entry
    private func saveFoodEntry(text: String, timeBlock: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let entry = FoodLog(
            date: Calendar.current.startOfDay(for: selectedDate),
            timeBlock: timeBlock,
            foodText: text,
            entryTime: Date()
        )
        modelContext.insert(entry)
        try? modelContext.save()
    }

    /// Delete entry
    private func deleteEntry(_ entry: FoodLog) {
        modelContext.delete(entry)
        try? modelContext.save()
    }

    /// Save edited entry
    private func saveEdit(entry: FoodLog, newText: String) {
        guard !newText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        entry.foodText = newText
        try? modelContext.save()
        showEditSheet = false
    }

    /// Format date as "Oct 26, 2023"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Time Block Section Component

struct TimeBlockSection: View {
    let title: String
    let timeRange: String
    let logs: [FoodLog]
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAddFood: () -> Void
    let onDelete: (FoodLog) -> Void
    let onEdit: (FoodLog) -> Void

    private var entryCount: Int {
        logs.count
    }

    private var entryBadgeText: String {
        if entryCount == 0 {
            return "0 entries"
        } else if entryCount == 1 {
            return "1 entry"
        } else {
            return "\(entryCount) entries"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                onToggle()
            } label: {
                HStack {
                    Image(systemName: title == "Morning" ? "sunrise.fill" : (title == "Afternoon" ? "sun.max.fill" : "moon.stars.fill"))
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.accentTeal)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(timeRange)
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textMuted)
                    }

                    Spacer()

                    // Entry count badge
                    Text(entryBadgeText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(entryCount > 0 ? AppColors.accentTeal : AppColors.textMuted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(entryCount > 0 ? AppColors.accentTeal.opacity(0.15) : AppColors.bgBase)
                        .cornerRadius(12)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.textMuted)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())

            // Expanded Content
            if isExpanded {
                VStack(spacing: 12) {
                    // Food entries
                    if logs.isEmpty {
                        Text("No entries logged yet.")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    } else {
                        ForEach(logs, id: \.id) { log in
                            FoodEntryRow(log: log, onDelete: {
                                onDelete(log)
                            }, onEdit: {
                                onEdit(log)
                            })
                        }
                        .padding(.horizontal, 16)
                    }

                    // Add Food Button
                    Button {
                        onAddFood()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))

                            Text("ADD FOOD")
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
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
        }
        .background(AppColors.bgCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Food Entry Row Component

struct FoodEntryRow: View {
    let log: FoodLog
    let onDelete: () -> Void
    let onEdit: () -> Void

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(log.foodText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)

                Text(formatTime(log.entryTime))
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(AppColors.bgBase)
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppColors.accentTeal)
        }
    }
}

#Preview {
    NavigationStack {
        FoodLogView()
            .modelContainer(for: FoodLog.self, inMemory: true)
    }
}

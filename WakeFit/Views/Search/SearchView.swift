//
//  SearchView.swift
//  WakeFit
//
//  Search screen for finding logs and entries
//  Real-time search across food logs, weight entries, and notes
//

import SwiftUI
import SwiftData

enum SearchSegment: String, CaseIterable {
    case food = "Food Logs"
    case weight = "Weight"
    case notes = "Notes"
}

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - SwiftData Queries

    @Query var foodLogs: [FoodLog]
    @Query var weightEntries: [WeightEntry]
    @Query var sleepEntries: [SleepEntry]

    // MARK: - State

    @State private var searchText: String = ""
    @State private var selectedSegment: SearchSegment = .food

    // MARK: - Computed Properties

    /// Filtered food logs
    private var filteredFoodLogs: [FoodLog] {
        guard !searchText.isEmpty else { return Array(foodLogs.prefix(10)) }
        return foodLogs.filter {
            $0.foodText.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Filtered weight entries
    private var filteredWeightEntries: [WeightEntry] {
        guard !searchText.isEmpty else { return Array(weightEntries.prefix(10)) }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return weightEntries.filter {
            formatter.string(from: $0.date).localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Filtered sleep entries with notes
    private var filteredSleepEntries: [SleepEntry] {
        let entriesWithNotes = sleepEntries.filter { !$0.notes.isEmpty }
        guard !searchText.isEmpty else { return Array(entriesWithNotes.prefix(10)) }
        return entriesWithNotes.filter {
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            AppColors.bgBase
                .ignoresSafeArea()

            VStack(spacing: 0) {
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

                    Text("Search")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.textMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)

                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.textMuted)

                    TextField("Search entries, tags, or dates...", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.textPrimary)
                }
                .padding(16)
                .background(AppColors.bgCard)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Segment Picker
                HStack(spacing: 12) {
                    ForEach(SearchSegment.allCases, id: \.self) { segment in
                        Button {
                            selectedSegment = segment
                        } label: {
                            Text(segment.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(selectedSegment == segment ? .black : AppColors.textPrimary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(selectedSegment == segment ? AppColors.accentTeal : AppColors.bgCard)
                                .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Results Header
                Text(searchText.isEmpty ? "RECENT RESULTS" : "SEARCH RESULTS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textMuted)
                    .tracking(0.08 * 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Results List
                ScrollView {
                    VStack(spacing: 12) {
                        switch selectedSegment {
                        case .food:
                            foodResultsList
                        case .weight:
                            weightResultsList
                        case .notes:
                            notesResultsList
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Results Lists

    private var foodResultsList: some View {
        Group {
            if filteredFoodLogs.isEmpty {
                emptyState(message: "No food logs found")
            } else {
                ForEach(filteredFoodLogs, id: \.id) { log in
                    FoodSearchResultCard(log: log)
                }
            }
        }
    }

    private var weightResultsList: some View {
        Group {
            if filteredWeightEntries.isEmpty {
                emptyState(message: "No weight entries found")
            } else {
                ForEach(filteredWeightEntries, id: \.id) { entry in
                    WeightSearchResultCard(entry: entry)
                }
            }
        }
    }

    private var notesResultsList: some View {
        Group {
            if filteredSleepEntries.isEmpty {
                emptyState(message: "No notes found")
            } else {
                ForEach(filteredSleepEntries, id: \.id) { entry in
                    NoteSearchResultCard(entry: entry)
                }
            }
        }
    }

    private func emptyState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textMuted)

            Text(message)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top, 60)
    }
}

// MARK: - Food Search Result Card

struct FoodSearchResultCard: View {
    let log: FoodLog

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatDate(log.date))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.textMuted)

                Spacer()

                Text(log.timeBlock.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.accentTeal)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.accentTeal.opacity(0.15))
                    .cornerRadius(6)
            }

            Text(log.foodText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
        }
        .padding(16)
        .background(AppColors.bgCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Weight Search Result Card

struct WeightSearchResultCard: View {
    let entry: WeightEntry

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(formatDate(entry.date))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textMuted)

            HStack(alignment: .firstTextBaseline) {
                Text(String(format: "%.1f", entry.weight))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppColors.accentTeal)

                Text("kg")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                Text(String(format: "%.1f lbs", entry.weight * 2.20462))
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(16)
        .background(AppColors.bgCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Note Search Result Card

struct NoteSearchResultCard: View {
    let entry: SleepEntry

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatDate(entry.date))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.textMuted)

                Spacer()

                Text("SLEEP NOTE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.accentTeal)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.accentTeal.opacity(0.15))
                    .cornerRadius(6)
            }

            Text(entry.notes)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
        }
        .padding(16)
        .background(AppColors.bgCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .modelContainer(for: [FoodLog.self, WeightEntry.self, SleepEntry.self], inMemory: true)
    }
}

//
//  AIAnalysisView.swift
//  WakeFit
//
//  AI nutrition analysis screen
//  Shows calorie/protein estimates and discipline status
//

import SwiftUI
import SwiftData

struct AIAnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - SwiftData Queries

    @Query var foodLogs: [FoodLog]
    @Query var aiAnalyses: [AIAnalysis]

    // MARK: - State

    @State private var isAnalyzing: Bool = false
    @State private var errorMessage: String? = nil

    // MARK: - Computed Properties

    /// Today's analysis (if exists)
    private var todayAnalysis: AIAnalysis? {
        aiAnalyses.first { Calendar.current.isDateInToday($0.date) }
    }

    /// Today's food logs
    private var todayFoodLogs: [FoodLog] {
        foodLogs.filter { Calendar.current.isDateInToday($0.date) }
    }

    /// Food text for AI prompt
    private var todayFoodText: String {
        if todayFoodLogs.isEmpty { return "No food logged today." }
        return todayFoodLogs.map { "[\($0.timeBlock)] \($0.foodText)" }.joined(separator: "\n")
    }

    /// Discipline status color
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "disciplined": return AppColors.accentTeal
        case "borderline": return AppColors.warning
        default: return AppColors.danger
        }
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

                    // Date
                    Text(formatDate(Date()))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                    // Title
                    HStack {
                        Text("Today's\nDiagnosis")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        if let analysis = todayAnalysis {
                            Text(analysis.disciplineStatus.uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(statusColor(analysis.disciplineStatus))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(statusColor(analysis.disciplineStatus).opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Content based on state
                    if isAnalyzing {
                        loadingState
                    } else if let analysis = todayAnalysis {
                        resultsState(analysis: analysis)
                    } else if todayFoodLogs.isEmpty {
                        emptyState
                    } else {
                        analyzeState
                    }

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.textMuted)

                Text("No Food Logged Today")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Log your meals to get AI-powered nutrition analysis")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 40)

            NavigationLink(destination: FoodLogView()) {
                Text("Go Log Food")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.accentTeal)
                    .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Analyze State

    private var analyzeState: some View {
        VStack(spacing: 20) {
            // Preview of today's logs
            VStack(alignment: .leading, spacing: 12) {
                Text("TODAY'S FOOD")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textMuted)
                    .tracking(0.08 * 12)

                VStack(spacing: 8) {
                    ForEach(todayFoodLogs.prefix(3), id: \.id) { log in
                        HStack(spacing: 8) {
                            Text(log.timeBlock.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.accentTeal)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.accentTeal.opacity(0.15))
                                .cornerRadius(6)

                            Text(log.foodText)
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.textPrimary)
                                .lineLimit(2)

                            Spacer()
                        }
                        .padding(12)
                        .background(AppColors.bgCard)
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
            .padding(.horizontal, 20)

            // Analyze Button
            Button {
                Task {
                    await analyzeDay()
                }
            } label: {
                Text("ANALYZE MY DAY")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.accentTeal)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 20) {
            Text("Analyzing your day...")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)

            // Skeleton Cards
            HStack(spacing: 12) {
                SkeletonCard()
                SkeletonCard()
            }
            .padding(.horizontal, 20)

            SkeletonCard()
                .frame(height: 150)
                .padding(.horizontal, 20)

            SkeletonCard()
                .frame(height: 150)
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Results State

    private func resultsState(analysis: AIAnalysis) -> some View {
        VStack(spacing: 20) {
            // Stat Cards
            HStack(spacing: 12) {
                StatCardAI(
                    label: "CALORIES",
                    value: "\(analysis.estimatedCalories)",
                    unit: "kcal",
                    icon: "flame.fill"
                )

                StatCardAI(
                    label: "PROTEIN",
                    value: "\(analysis.estimatedProtein)",
                    unit: "g",
                    icon: "chart.bar.fill"
                )
            }
            .padding(.horizontal, 20)

            // Coach Diagnosis
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.accentTeal)

                    Text("Coach Diagnosis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                }

                Text(analysis.coachDiagnosis)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(4)
            }
            .padding(20)
            .background(AppColors.bgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)

            // Risk Areas
            if !analysis.riskAreas.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.danger)

                        Text("Risk Areas")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppColors.danger)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(analysis.riskAreas.components(separatedBy: "\n"), id: \.self) { risk in
                            if !risk.isEmpty {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(AppColors.danger)
                                        .frame(width: 16, height: 16)

                                    Text(risk)
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(AppColors.bgCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.danger.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }

            // Re-analyze Button
            Button {
                Task {
                    await analyzeDay()
                }
            } label: {
                Text("RE-ANALYZE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.accentTeal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppColors.bgCard)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.accentTeal, lineWidth: 1.5)
                    )
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Functions

    /// Analyze day with AI (stubbed for now)
    private func analyzeDay() async {
        isAnalyzing = true

        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // TODO: Replace with actual OpenAI API call
        // For now, create mock analysis
        let mockAnalysis = AIAnalysis(
            date: Calendar.current.startOfDay(for: Date()),
            estimatedCalories: 2100,
            estimatedProtein: 85,
            riskAreas: "Elevated sodium intake detected post-meridian.\nSleep latency extended beyond acceptable standard.",
            disciplineStatus: "Disciplined",
            coachDiagnosis: "Output remains within optimal parameters. Caloric intake is balanced, and protein synthesis targets are met. Maintain current trajectory. Hydration levels require monitoring in the evening phase. Stay the course.",
            tomorrowAdvice: "Focus on reducing sodium intake and aim for earlier bedtime."
        )

        // Save to SwiftData
        if let existing = todayAnalysis {
            // Update existing
            modelContext.delete(existing)
        }
        modelContext.insert(mockAnalysis)
        try? modelContext.save()

        isAnalyzing = false
    }

    /// Format date as "OCT 26, 2023"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Stat Card Component

struct StatCardAI: View {
    let label: String
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.accentTeal)

                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.textMuted)
                    .tracking(0.08 * 11)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(AppColors.accentTeal)

                Text(unit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppColors.bgCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Skeleton Card Component

struct SkeletonCard: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(AppColors.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.cardBorder.opacity(0.3),
                                AppColors.accentTeal.opacity(0.2),
                                AppColors.cardBorder.opacity(0.3)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(isAnimating ? 1 : 0.5)
            )
            .frame(height: 100)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    NavigationStack {
        AIAnalysisView()
            .modelContainer(for: [FoodLog.self, AIAnalysis.self], inMemory: true)
    }
}

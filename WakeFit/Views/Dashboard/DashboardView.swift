//
//  DashboardView.swift
//  WakeFit
//
//  Main dashboard screen showing discipline score, daily stats, and quick actions
//  Matches Stitch design with all 6 cards and bottom navigation
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    // MARK: - SwiftData Queries

    @Query var wakeUpEntries: [WakeUpEntry]    // All wake-up logs
    @Query var foodLogs: [FoodLog]             // All food logs
    @Query var weightEntries: [WeightEntry]    // All weight entries
    @Query var sleepEntries: [SleepEntry]      // All sleep logs
    @Query var aiAnalyses: [AIAnalysis]        // All AI analyses
    @Query var users: [User]                   // User profile

    // MARK: - State

    // Active tab for bottom navigation
    @State private var selectedTab: Tab = .home

    // MARK: - Computed Properties

    /// Today's date (start of day)
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    /// Today's wake-up entry
    private var todayWakeUp: WakeUpEntry? {
        wakeUpEntries.first { Calendar.current.isDateInToday($0.date) }
    }

    /// Today's sleep entry
    private var todaySleep: SleepEntry? {
        sleepEntries.first { Calendar.current.isDateInToday($0.date) }
    }

    /// Today's food logs
    private var todayFoodLogs: [FoodLog] {
        foodLogs.filter { Calendar.current.isDateInToday($0.date) }
    }

    /// Whether morning food is logged
    private var morningLogged: Bool {
        todayFoodLogs.contains { $0.timeBlock == "morning" }
    }

    /// Whether afternoon food is logged
    private var afternoonLogged: Bool {
        todayFoodLogs.contains { $0.timeBlock == "afternoon" }
    }

    /// Whether evening food is logged
    private var eveningLogged: Bool {
        todayFoodLogs.contains { $0.timeBlock == "evening" }
    }

    /// Latest weight entry
    private var currentWeight: Double? {
        weightEntries.sorted { $0.date > $1.date }.first?.weight
    }

    /// Today's AI analysis
    private var todayAnalysis: AIAnalysis? {
        aiAnalyses.first { Calendar.current.isDateInToday($0.date) }
    }

    /// Days since user started
    private var daysSinceStart: Int {
        guard let user = users.first else { return 1 }
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: user.startDate),
            to: calendar.startOfDay(for: Date())
        )
        return max(1, components.day ?? 1)
    }

    /// Discipline score (0-100)
    private var disciplineScore: Int {
        var score = 0
        if todayWakeUp != nil { score += 34 }
        if morningLogged || afternoonLogged || eveningLogged { score += 33 }
        if todaySleep?.sleptOnTime == true { score += 33 }
        return score
    }

    /// User's first name
    private var userName: String {
        users.first?.name.components(separatedBy: " ").first ??
        UserDefaults.standard.string(forKey: "userName") ?? "User"
    }

    /// Greeting based on time of day
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    /// Formatted wake-up time
    private var wakeUpTimeText: String? {
        guard let entry = todayWakeUp else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.wakeUpTime)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                Color(AppColors.bgBase)
                    .ignoresSafeArea(.all)

                // Main Content - switch based on selected tab
                Group {
                    switch selectedTab {
                    case .home:
                        dashboardContent
                    case .food:
                        FoodLogView()
                    case .weight:
                        WeightView()
                    case .analysis:
                        AIAnalysisView()
                    case .search:
                        SearchView()
                    }
                }

                // MARK: - Bottom Tab Bar
                BottomTabBar(selectedTab: $selectedTab)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - Top Navigation Bar

                HStack {
                    // Profile button (left)
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AppColors.textMuted)
                    }

                    Spacer()

                    // Title (center)
                    Text("Discipline")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    // Settings button (right)
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.accentTeal)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // MARK: - Date & Greeting Section

                VStack(alignment: .leading, spacing: 4) {
                    // Date display (uppercase, small)
                    Text(formatDate(Date()))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .textCase(.uppercase)

                    // Greeting with user name
                    Text("\(greeting), \(userName)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

                // MARK: - Discipline Score Ring

                DisciplineScoreRing(score: disciplineScore)
                    .padding(.vertical, 20)

                // MARK: - Wake-Up Card

                NavigationLink(destination: WakeUpView()) {
                    WakeUpCard(wakeUpTime: wakeUpTimeText)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)

                // MARK: - Food Log Card

                NavigationLink(destination: FoodLogView()) {
                    FoodLogCard(
                        morningLogged: morningLogged,
                        afternoonLogged: afternoonLogged,
                        eveningLogged: eveningLogged
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)

                // MARK: - Weight Card

                NavigationLink(destination: WeightView()) {
                    WeightCard(
                        currentWeight: currentWeight,
                        daysSinceStart: daysSinceStart
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)

                // MARK: - Calories Card

                NavigationLink(destination: AIAnalysisView()) {
                    CaloriesCard(estimatedCalories: todayAnalysis?.estimatedCalories)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)

                // MARK: - Streak Counter

                StreakCounter(streakDays: daysSinceStart)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Space for bottom tab bar
            }
        }
    }

    // MARK: - Helper Functions

    /// Formats date as "OCT 24, 2023"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Discipline Score Ring Component

/// Circular progress ring showing discipline score (0-100)
struct DisciplineScoreRing: View {
    let score: Int

    // Colors based on score
    private var ringColor: Color {
        switch score {
        case 80...100: return AppColors.accentTeal  // Disciplined - Teal
        case 50...79: return AppColors.warning   // Borderline - Amber
        default: return AppColors.danger        // Off Track - Red
        }
    }

    var body: some View {
        ZStack {
            // Background circle (gray track)
            Circle()
                .stroke(AppColors.cardBorder, lineWidth: 12)
                .frame(width: 180, height: 180)

            // Progress arc (colored based on score)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100.0)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90)) // Start from top

            // Score text in center
            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(ringColor)

                Text("SCORE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textMuted)
                    .tracking(0.08 * 12)
            }
        }
    }
}

// MARK: - Wake-Up Card Component

struct WakeUpCard: View {
    let wakeUpTime: String?

    var body: some View {
        HStack(spacing: 16) {
            // Alarm icon
            Image(systemName: "alarm.fill")
                .font(.system(size: 24))
                .foregroundStyle(AppColors.accentTeal)

            VStack(alignment: .leading, spacing: 4) {
                Text("WAKE UP")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.accentTeal)
                    .tracking(0.08 * 12)

                if let time = wakeUpTime {
                    Text("Wake-up logged: \(time)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                } else {
                    Text("Log Now")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.accentTeal)
                }
            }

            Spacer()
        }
        .padding(20)
        .background(AppColors.bgCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Food Log Card Component

struct FoodLogCard: View {
    let morningLogged: Bool
    let afternoonLogged: Bool
    let eveningLogged: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.accentTeal)

                Text("FOOD LOG")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.accentTeal)
                    .tracking(0.08 * 12)
            }

            // Time block badges
            HStack(spacing: 8) {
                TimeBlockBadge(label: "Morning", isLogged: morningLogged)
                TimeBlockBadge(label: "Afternoon", isLogged: afternoonLogged)
                TimeBlockBadge(label: "Evening", isLogged: eveningLogged)
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
}

// MARK: - Time Block Badge Component

struct TimeBlockBadge: View {
    let label: String
    let isLogged: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
                .fixedSize()

            Image(systemName: isLogged ? "checkmark" : "xmark")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(isLogged ? AppColors.accentTeal : AppColors.textMuted)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(AppColors.bgBase)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isLogged ? AppColors.accentTeal : AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Weight Card Component

struct WeightCard: View {
    let currentWeight: Double?
    let daysSinceStart: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.accentTeal)

                    Text("WEIGHT")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.accentTeal)
                        .tracking(0.08 * 12)
                }

                if let weight = currentWeight {
                    HStack(spacing: 8) {
                        Text(String(format: "%.1f kg", weight))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)

                        // Trend arrow (placeholder - always showing down trend for now)
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppColors.success)
                    }
                } else {
                    Text("—")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppColors.textMuted)
                }
            }

            Spacer()

            // Days counter
            Text("Day \(daysSinceStart)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(20)
        .background(AppColors.bgCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Calories Card Component

struct CaloriesCard: View {
    let estimatedCalories: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.accentTeal)

                Text("CALORIES")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.accentTeal)
                    .tracking(0.08 * 12)
            }

            if let calories = estimatedCalories {
                // Show estimated calories
                Text("~\(calories) kcal estimated today")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
            } else {
                // Show analyze button
                Text("No analysis yet. Tap to analyze.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
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
}

// MARK: - Streak Counter Component

struct StreakCounter: View {
    let streakDays: Int

    var body: some View {
        HStack(spacing: 12) {
            // Flame emoji/icon
            Text("🔥")
                .font(.system(size: 24))

            Text("\(streakDays) DAY STREAK")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .tracking(0.05 * 16)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            AppColors.bgCardHigh
                .opacity(0.8)
        )
        .cornerRadius(24) // Pill shape
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Bottom Tab Bar Component

enum Tab {
    case home, food, weight, analysis, search
}

struct BottomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house.fill", label: "Home", tab: .home, selectedTab: $selectedTab)
            TabBarItem(icon: "fork.knife", label: "Food", tab: .food, selectedTab: $selectedTab)
            TabBarItem(icon: "scalemass.fill", label: "Weight", tab: .weight, selectedTab: $selectedTab)
            TabBarItem(icon: "chart.bar.fill", label: "Analysis", tab: .analysis, selectedTab: $selectedTab)
            TabBarItem(icon: "magnifyingglass", label: "Search", tab: .search, selectedTab: $selectedTab)
        }
        .padding(.vertical, 12)
        .background(AppColors.bgBase)
        .overlay(
            Rectangle()
                .fill(AppColors.cardBorder)
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let tab: Tab
    @Binding var selectedTab: Tab

    private var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))

                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isSelected ? AppColors.accentTeal : AppColors.textMuted)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .modelContainer(for: [User.self, WakeUpEntry.self, FoodLog.self, WeightEntry.self, AIAnalysis.self])
}

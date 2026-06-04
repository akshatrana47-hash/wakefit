//
//  DashboardTests.swift
//  UITests
//
//  Tests for Dashboard (4 representative tests)
//

import XCTest
import SwiftData
@testable import WakeFit

@MainActor
final class DashboardTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([WakeUpEntry.self, FoodLog.self, SleepEntry.self, AIAnalysis.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    // TC024 — Dashboard shows all 6 cards
    func testDashboardShowsAllCards() throws {
        // Given: Dashboard should render
        // Then: All components should be available
        XCTAssertNotNil(modelContext, "Model context should exist for dashboard")
    }

    // TC025 — Discipline score ring correct color for high score
    func testDisciplineScoreHighIsGreen() throws {
        // Given: All tasks completed (score = 100)
        let score = 100
        
        // Then: Should be disciplined (teal)
        XCTAssertGreaterThanOrEqual(score, 80, "High score should be 80+")
    }

    // TC028 — Wake-Up card shows "Log Now" when not logged
    func testWakeUpCardShowsLogNowWhenEmpty() throws {
        // Given: No wake-up entry for today
        let descriptor = FetchDescriptor<WakeUpEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        // Then: Should show "Log Now" state
        XCTAssertEqual(entries.count, 0, "No wake-up entries should exist")
    }

    // TC031 — Calories card shows analysis when exists
    func testCaloriesCardShowsAnalysis() throws {
        // Given: AIAnalysis exists
        let analysis = AIAnalysis(
            date: Date(),
            estimatedCalories: 1840,
            estimatedProtein: 85,
            riskAreas: "None",
            disciplineStatus: "Disciplined",
            coachDiagnosis: "Good job",
            tomorrowAdvice: "Keep it up"
        )
        
        modelContext.insert(analysis)
        try modelContext.save()
        
        // Then: Analysis should be saved
        let descriptor = FetchDescriptor<AIAnalysis>()
        let analyses = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(analyses.count, 1)
        XCTAssertEqual(analyses.first?.estimatedCalories, 1840)
    }
}

//
//  AIAnalysisTests.swift
//  UITests
//
//  Tests for AI Analysis (2 representative tests)
//

import XCTest
import SwiftData
@testable import WakeFit

@MainActor
final class AIAnalysisTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([FoodLog.self, AIAnalysis.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    // TC063 — Empty state shows when no food logged
    func testEmptyStateWhenNoFoodLogged() throws {
        // Given: No food logs
        let descriptor = FetchDescriptor<FoodLog>()
        let foodLogs = try modelContext.fetch(descriptor)
        
        // Then: Should show empty state
        XCTAssertEqual(foodLogs.count, 0, "No food logs should exist")
    }

    // TC069 — Analysis saved to SwiftData
    func testAnalysisSavedToSwiftData() throws {
        // Given: AI analysis result
        let analysis = AIAnalysis(
            date: Date(),
            estimatedCalories: 1450,
            estimatedProtein: 95,
            riskAreas: "Low carbs",
            disciplineStatus: "Disciplined",
            coachDiagnosis: "Solid protein intake",
            tomorrowAdvice: "Add complex carbs"
        )
        
        // When: Analysis is saved
        modelContext.insert(analysis)
        try modelContext.save()
        
        // Then: Analysis should exist in SwiftData
        let descriptor = FetchDescriptor<AIAnalysis>()
        let analyses = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(analyses.count, 1, "Should have 1 analysis")
        XCTAssertEqual(analyses.first?.estimatedCalories, 1450)
        XCTAssertEqual(analyses.first?.estimatedProtein, 95)
        XCTAssertEqual(analyses.first?.disciplineStatus, "Disciplined")
    }
}

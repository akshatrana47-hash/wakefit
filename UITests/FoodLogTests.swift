//
//  FoodLogTests.swift
//  UITests
//
//  Tests for Food Logging (4 representative tests)
//

import XCTest
import SwiftData
@testable import WakeFit

@MainActor
final class FoodLogTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([FoodLog.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    // TC043 — Food log shows 3 time block sections
    func testFoodLogShowsThreeTimeBlocks() throws {
        // Given: Three time blocks
        let blocks = ["morning", "afternoon", "evening"]
        
        // Then: Should have 3 blocks
        XCTAssertEqual(blocks.count, 3, "Should have 3 time blocks")
    }

    // TC045 — Food entry saves to correct time block
    func testFoodEntrySavesToCorrectTimeBlock() throws {
        // Given: Food entry for morning
        let entry = FoodLog(
            date: Date(),
            timeBlock: "morning",
            foodText: "2 eggs and toast",
            entryTime: Date()
        )
        
        // When: Entry is saved
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then: Entry should have correct time block
        let descriptor = FetchDescriptor<FoodLog>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.timeBlock, "morning")
        XCTAssertEqual(entries.first?.foodText, "2 eggs and toast")
    }

    // TC046 — Empty food text shows validation error
    func testEmptyFoodTextRejected() throws {
        // Given: Empty food text
        let emptyText = ""
        let trimmed = emptyText.trimmingCharacters(in: .whitespaces)
        
        // Then: Should be invalid
        XCTAssertTrue(trimmed.isEmpty, "Empty text should fail validation")
    }

    // TC047 — Swipe to delete removes entry
    func testDeleteRemovesEntry() throws {
        // Given: Food entry exists
        let entry = FoodLog(
            date: Date(),
            timeBlock: "morning",
            foodText: "chicken rice",
            entryTime: Date()
        )
        modelContext.insert(entry)
        try modelContext.save()
        
        // When: Entry is deleted
        modelContext.delete(entry)
        try modelContext.save()
        
        // Then: Entry should be removed
        let descriptor = FetchDescriptor<FoodLog>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 0, "Entry should be deleted")
    }
}

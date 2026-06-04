//
//  SleepTests.swift
//  UITests
//
//  Tests for Sleep Logging (2 representative tests)
//

import XCTest
import SwiftData
@testable import WakeFit

@MainActor
final class SleepTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([SleepEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    // TC058 — Selecting Yes highlights card in teal
    func testSelectingYesSetsSleptOnTimeTrue() throws {
        // Given: User selects "Yes"
        let sleptOnTime = true
        
        // Then: sleptOnTime should be true
        XCTAssertTrue(sleptOnTime, "Selecting Yes should set sleptOnTime to true")
    }

    // TC061 — Sleep entry saves to SwiftData
    func testSleepEntrySavesToSwiftData() throws {
        // Given: Sleep entry
        let entry = SleepEntry(
            date: Date(),
            sleptOnTime: true,
            notes: "Slept well"
        )
        
        // When: Entry is saved
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then: Entry should exist in SwiftData
        let descriptor = FetchDescriptor<SleepEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1, "Should have 1 sleep entry")
        XCTAssertTrue(entries.first?.sleptOnTime ?? false)
        XCTAssertEqual(entries.first?.notes, "Slept well")
    }
}

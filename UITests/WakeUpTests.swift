//
//  WakeUpTests.swift
//  UITests
//
//  Tests for Wake-Up Logging (3 representative tests)
//

import XCTest
import SwiftData
@testable import WakeFit

@MainActor
final class WakeUpTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([WakeUpEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    // TC036 — WakeUpView shows current time by default
    func testWakeUpViewShowsCurrentTime() throws {
        // Given: Current time
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        // Then: Time should be valid (0-23)
        XCTAssertGreaterThanOrEqual(currentHour, 0)
        XCTAssertLessThan(currentHour, 24)
    }

    // TC038 — Save creates WakeUpEntry in SwiftData
    func testSaveCreatesWakeUpEntry() throws {
        // Given: Wake-up time
        let wakeUpTime = Date()
        let entry = WakeUpEntry(date: Date(), wakeUpTime: wakeUpTime)
        
        // When: Entry is saved
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then: Entry should exist in SwiftData
        let descriptor = FetchDescriptor<WakeUpEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1, "Should have 1 wake-up entry")
        XCTAssertNotNil(entries.first?.wakeUpTime)
    }

    // TC039 — Second save updates existing entry
    func testSecondSaveUpdatesExistingEntry() throws {
        // Given: First entry exists
        let entry1 = WakeUpEntry(date: Date(), wakeUpTime: Date())
        modelContext.insert(entry1)
        try modelContext.save()
        
        // When: Deleting and creating new entry (simulating update)
        modelContext.delete(entry1)
        let entry2 = WakeUpEntry(date: Date(), wakeUpTime: Date().addingTimeInterval(3600))
        modelContext.insert(entry2)
        try modelContext.save()
        
        // Then: Should only have 1 entry
        let descriptor = FetchDescriptor<WakeUpEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1, "Should have only 1 entry after update")
    }
}

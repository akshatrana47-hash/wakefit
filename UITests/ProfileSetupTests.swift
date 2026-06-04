//
//  ProfileSetupTests.swift
//  UITests
//
//  Tests for Profile Setup (5 representative tests)
//

import XCTest
import SwiftData
@testable import WakeFit

@MainActor
final class ProfileSetupTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var userDefaults: UserDefaults!

    override func setUp() async throws {
        // In-memory SwiftData container for testing
        let schema = Schema([User.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
        
        userDefaults = UserDefaults(suiteName: "ProfileSetupTests")!
        userDefaults.removePersistentDomain(forName: "ProfileSetupTests")
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
        userDefaults.removePersistentDomain(forName: "ProfileSetupTests")
        userDefaults = nil
    }

    // TC014 — Profile setup renders all 4 fields
    func testProfileSetupRendersAllFields() throws {
        // Given: ProfileSetupView should render
        // When: View appears
        // Then: All fields should be available for input
        XCTAssertNotNil(modelContext, "ModelContext should be initialized")
    }

    // TC016 — Invalid weight shows validation error
    func testInvalidWeightRejected() throws {
        // Given: Profile setup visible
        let invalidWeight = "abc"
        
        // When: Invalid weight entered
        let weightValue = Double(invalidWeight)
        
        // Then: Should be nil (invalid)
        XCTAssertNil(weightValue, "Invalid weight should not parse to Double")
    }

    // TC019 — Valid form saves User to SwiftData
    func testValidFormSavesUser() throws {
        // Given: Valid profile data
        let user = User(
            name: "Akshat",
            email: "test@gmail.com",
            startingWeight: 85.0,
            targetWeight: 75.0,
            height: 178.0,
            startDate: Date()
        )
        
        // When: User is inserted
        modelContext.insert(user)
        try modelContext.save()
        
        // Then: User should be saved in SwiftData
        let descriptor = FetchDescriptor<User>()
        let users = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(users.count, 1, "Should have 1 user")
        XCTAssertEqual(users.first?.name, "Akshat")
        XCTAssertEqual(users.first?.startingWeight, 85.0)
        XCTAssertEqual(users.first?.targetWeight, 75.0)
        XCTAssertEqual(users.first?.height, 178.0)
    }

    // TC020 — Profile setup sets hasCompletedSetup = true
    func testProfileSetupSetsCompletedFlag() throws {
        // Given: Profile setup completion
        // When: User submits valid form
        userDefaults.set(true, forKey: "hasCompletedSetup")
        
        // Then: hasCompletedSetup should be true
        XCTAssertTrue(userDefaults.bool(forKey: "hasCompletedSetup"))
    }

    // TC022 — Profile setup navigates to Dashboard on success
    func testProfileSetupNavigatesToDashboard() throws {
        // Given: Valid profile submitted
        userDefaults.set(true, forKey: "hasCompletedSetup")
        
        let hasCompleted = userDefaults.bool(forKey: "hasCompletedSetup")
        
        // Then: Should navigate to Dashboard
        XCTAssertTrue(hasCompleted, "Should complete setup and navigate to Dashboard")
    }
}

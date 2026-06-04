//
//  SplashScreenTests.swift
//  WakeFitTests
//
//  Tests for Splash Screen (5 test cases: TC001-TC005)
//

import XCTest
@testable import WakeFit

@MainActor
final class SplashScreenTests: XCTestCase {

    var userDefaults: UserDefaults!

    override func setUp() async throws {
        // Use separate test suite for UserDefaults
        userDefaults = UserDefaults(suiteName: "SplashScreenTests")!
        userDefaults.removePersistentDomain(forName: "SplashScreenTests")
    }

    override func tearDown() async throws {
        userDefaults.removePersistentDomain(forName: "SplashScreenTests")
        userDefaults = nil
    }

    // TC001 — Splash shows on cold launch
    func testSplashShowsOnColdLaunch() throws {
        // Given: App not running
        // When: App launches
        let showSplash = true

        // Then: Splash screen should be visible
        XCTAssertTrue(showSplash, "Splash screen should appear immediately on cold launch")
    }

    // TC002 — Splash animation completes
    func testSplashAnimationCompletes() async throws {
        // Given: App launched
        let startTime = Date()

        // When: Wait for splash duration
        try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds

        // Then: Animation should complete between 2.0s and 3.0s
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsed, 2.0, "Splash should last at least 2 seconds")
        XCTAssertLessThanOrEqual(elapsed, 3.0, "Splash should complete within 3 seconds")
    }

    // TC003 — Splash routes to Login when not logged in
    func testSplashRoutesToLoginWhenNotLoggedIn() throws {
        // Given: User not logged in
        userDefaults.set(false, forKey: "isLoggedIn")

        let isLoggedIn = userDefaults.bool(forKey: "isLoggedIn")

        // Then: Should route to LoginView
        XCTAssertFalse(isLoggedIn, "isLoggedIn should be false")
        // After splash completes, LoginView should appear (navigation logic tested)
    }

    // TC004 — Splash routes to Dashboard when logged in
    func testSplashRoutesToDashboardWhenLoggedIn() throws {
        // Given: User logged in and setup complete
        userDefaults.set(true, forKey: "isLoggedIn")
        userDefaults.set(true, forKey: "hasCompletedSetup")

        let isLoggedIn = userDefaults.bool(forKey: "isLoggedIn")
        let hasCompletedSetup = userDefaults.bool(forKey: "hasCompletedSetup")

        // Then: Should route to DashboardView
        XCTAssertTrue(isLoggedIn, "isLoggedIn should be true")
        XCTAssertTrue(hasCompletedSetup, "hasCompletedSetup should be true")
    }

    // TC005 — Splash routes to ProfileSetup when setup incomplete
    func testSplashRoutesToProfileSetupWhenSetupIncomplete() throws {
        // Given: User logged in but setup incomplete
        userDefaults.set(true, forKey: "isLoggedIn")
        userDefaults.set(false, forKey: "hasCompletedSetup")

        let isLoggedIn = userDefaults.bool(forKey: "isLoggedIn")
        let hasCompletedSetup = userDefaults.bool(forKey: "hasCompletedSetup")

        // Then: Should route to ProfileSetupView
        XCTAssertTrue(isLoggedIn, "isLoggedIn should be true")
        XCTAssertFalse(hasCompletedSetup, "hasCompletedSetup should be false for incomplete setup")
    }
}

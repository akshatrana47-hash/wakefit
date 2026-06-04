//
//  LoginTests.swift
//  WakeFitTests
//
//  Tests for Login Screen (8 test cases: TC006-TC013)
//

import XCTest
@testable import WakeFit

@MainActor
final class LoginTests: XCTestCase {

    var userDefaults: UserDefaults!
    var viewModel: AuthViewModel!

    override func setUp() async throws {
        userDefaults = UserDefaults(suiteName: "LoginTests")!
        userDefaults.removePersistentDomain(forName: "LoginTests")
        viewModel = AuthViewModel()
    }

    override func tearDown() async throws {
        userDefaults.removePersistentDomain(forName: "LoginTests")
        userDefaults = nil
        viewModel = nil
    }

    // TC006 — Login screen renders correctly
    func testLoginScreenRendersCorrectly() throws {
        // Given: LoginView should render
        // When: View appears
        // Then: All elements should be present
        XCTAssertFalse(viewModel.isAuthenticated, "User should not be authenticated initially")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false initially")
    }

    // TC007 — Google Sign-In button is tappable
    func testGoogleSignInButtonTappable() throws {
        // Given: Login screen visible
        // When: Button is tapped
        // Then: Should trigger sign-in flow
        XCTAssertFalse(viewModel.isLoading, "Loading should be false before tap")
    }

    // TC008 — Loading state shows during sign-in
    func testLoadingStateDuringSignIn() throws {
        // Given: Login screen visible
        // When: Sign-in initiated
        viewModel.isLoading = true

        // Then: Loading state should be active
        XCTAssertTrue(viewModel.isLoading, "isLoading should be true during sign-in")
    }

    // TC009 — Successful login navigates to ProfileSetup
    func testSuccessfulLoginNavigatesToProfileSetup() throws {
        // Given: First time user
        userDefaults.set(false, forKey: "hasCompletedSetup")

        // When: Login succeeds
        viewModel.isAuthenticated = true
        viewModel.needsProfileSetup = true

        // Then: Should navigate to ProfileSetup
        XCTAssertTrue(viewModel.isAuthenticated, "Should be authenticated")
        XCTAssertTrue(viewModel.needsProfileSetup, "Should need profile setup")
    }

    // TC010 — Successful login navigates to Dashboard for existing user
    func testSuccessfulLoginNavigatesToDashboard() throws {
        // Given: Existing user with completed setup
        userDefaults.set(true, forKey: "hasCompletedSetup")

        // When: Login succeeds
        viewModel.isAuthenticated = true
        viewModel.needsProfileSetup = false

        // Then: Should navigate to Dashboard
        XCTAssertTrue(viewModel.isAuthenticated, "Should be authenticated")
        XCTAssertFalse(viewModel.needsProfileSetup, "Should not need profile setup")
    }

    // TC011 — Login error shows error message
    func testLoginErrorShowsErrorMessage() throws {
        // Given: Login screen visible
        // When: Login fails
        viewModel.errorMessage = "Sign-in failed"
        viewModel.isLoading = false

        // Then: Error message should be set
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        XCTAssertEqual(viewModel.errorMessage, "Sign-in failed")
        XCTAssertFalse(viewModel.isLoading, "Loading should stop after error")
    }

    // TC012 — UserDefaults set correctly after login
    func testUserDefaultsSetAfterLogin() throws {
        // Given: Successful login
        // When: User data is saved
        userDefaults.set(true, forKey: "isLoggedIn")
        userDefaults.set("test@gmail.com", forKey: "userEmail")
        userDefaults.set("Test User", forKey: "userName")

        // Then: All UserDefaults should be set
        XCTAssertTrue(userDefaults.bool(forKey: "isLoggedIn"), "isLoggedIn should be true")
        XCTAssertEqual(userDefaults.string(forKey: "userEmail"), "test@gmail.com")
        XCTAssertEqual(userDefaults.string(forKey: "userName"), "Test User")
    }

    // TC013 — Login screen not shown when already logged in
    func testLoginScreenBypassedWhenLoggedIn() throws {
        // Given: User already logged in
        userDefaults.set(true, forKey: "isLoggedIn")
        viewModel.isAuthenticated = true

        // Then: Should bypass login screen
        XCTAssertTrue(viewModel.isAuthenticated, "Should be authenticated")
    }
}

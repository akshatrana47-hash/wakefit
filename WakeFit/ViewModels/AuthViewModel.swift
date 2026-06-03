//
//  AuthViewModel.swift
//  WakeFit
//
//  ViewModel layer: Bridges UI and AuthManager, manages auth state
//  This is the coordinator between Views and the AuthManager service
//

import Foundation
import SwiftUI

/// Manages authentication state and coordinates between UI and AuthManager
/// @Observable makes this class's properties automatically update SwiftUI views
@Observable
final class AuthViewModel {

    // MARK: - Published State
    // These properties automatically trigger UI updates when changed

    /// Whether user is currently authenticated
    var isAuthenticated: Bool = false

    /// Whether an auth operation is in progress (shows loading indicator)
    var isLoading: Bool = false

    /// Error message to display to user (nil if no error)
    var errorMessage: String? = nil

    /// Whether user needs to complete profile setup (first-time login)
    var needsProfileSetup: Bool = false

    /// Current user's name (set after Google Sign-In)
    var userName: String = ""

    /// Current user's email (set after Google Sign-In)
    var userEmail: String = ""

    // MARK: - Dependencies

    /// Reference to the AuthManager service
    private let authManager = AuthManager.shared

    // MARK: - Initialization

    init() {
        // Check if user was previously logged in
        checkAuthenticationStatus()
    }

    // MARK: - Authentication Status

    /// Checks if user is already logged in from a previous session
    func checkAuthenticationStatus() {
        if authManager.isUserLoggedIn() {
            // User has an existing session
            isAuthenticated = true
            userName = authManager.getCurrentUserName() ?? ""
            userEmail = authManager.getCurrentUserEmail() ?? ""

            // Check if profile setup is complete
            let hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
            needsProfileSetup = !hasCompletedSetup
        } else {
            // No existing session
            isAuthenticated = false
            needsProfileSetup = false
        }
    }

    // MARK: - Google Sign-In

    /// Handles Google Sign-In button tap
    /// Coordinates with AuthManager and updates UI state
    func handleGoogleSignIn() async {
        // Clear any previous errors
        errorMessage = nil

        // Show loading state (button shows spinner)
        await MainActor.run {
            isLoading = true
        }

        do {
            // Call AuthManager to perform Google Sign-In
            let (name, email) = try await authManager.signInWithGoogle()

            // Success - update UI state on main thread
            await MainActor.run {
                self.userName = name
                self.userEmail = email
                self.isLoading = false

                // Check if this is first-time login (no User record in SwiftData)
                // For now, always show profile setup - we'll refine this later
                self.needsProfileSetup = true
            }
        } catch {
            // Sign-in failed - show error to user
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Sign-in failed: \(error.localizedDescription)"
            }
        }
    }

    /// Handles Apple Sign-In button tap
    func handleAppleSignIn() async {
        errorMessage = nil

        await MainActor.run {
            isLoading = true
        }

        do {
            let (name, email) = try await authManager.signInWithApple()

            await MainActor.run {
                self.userName = name
                self.userEmail = email
                self.isLoading = false
                self.needsProfileSetup = true
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Apple Sign-In not available yet"
            }
        }
    }

    // MARK: - Development/Bypass Methods

    /// Simulates successful Google login for development
    /// Bypasses actual Google Sign-In SDK until it's integrated
    func simulateLogin() {
        // Save login state to UserDefaults
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set("akshatrana47@gmail.com", forKey: "userEmail")
        UserDefaults.standard.set("Akshat Rana", forKey: "userName")
        UserDefaults.standard.set(false, forKey: "hasCompletedSetup")

        // Update ViewModel state
        userName = "Akshat Rana"
        userEmail = "akshatrana47@gmail.com"
        isAuthenticated = true
        needsProfileSetup = true
    }

    // MARK: - Profile Setup Completion

    /// Called when user completes profile setup
    /// Marks authentication as complete
    func completeProfileSetup() {
        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        needsProfileSetup = false
        // isAuthenticated stays true - user lands on Dashboard
    }

    // MARK: - Face ID / Touch ID

    /// Prompts user for Face ID / Touch ID authentication
    /// Used when app launches and user is already logged in
    func unlockWithBiometrics() async -> Bool {
        let success = await authManager.authenticateWithBiometrics(
            reason: "Unlock WakeFit to access your discipline tracker"
        )

        if success {
            // Biometric auth succeeded - mark as authenticated
            await MainActor.run {
                isAuthenticated = true
            }
        }

        return success
    }

    // MARK: - Sign Out

    /// Signs out the current user
    func signOut() {
        authManager.signOut()
        isAuthenticated = false
        userName = ""
        userEmail = ""
        needsProfileSetup = false
    }
}

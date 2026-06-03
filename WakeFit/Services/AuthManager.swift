//
//  AuthManager.swift
//  WakeFit
//
//  Service layer: Handles Google Sign-In and Face ID authentication
//  This is pure Swift - NO SwiftUI, NO UI state management
//

import Foundation
import LocalAuthentication  // Apple's biometric authentication framework

/// Manages authentication operations: Google Sign-In, Face ID, session persistence
final class AuthManager {

    // MARK: - Singleton
    // Shared instance so we have one auth manager across the entire app
    static let shared = AuthManager()

    // Private initializer prevents creating multiple instances
    private init() {}

    // MARK: - Session Storage Keys
    // Keys for saving/loading auth state from UserDefaults
    private let isLoggedInKey = "isLoggedIn"
    private let userEmailKey = "userEmail"
    private let userNameKey = "userName"

    // MARK: - Check if User is Logged In

    /// Checks if a user is currently logged in
    /// - Returns: true if user has an active session, false otherwise
    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: isLoggedInKey)
    }

    /// Retrieves the logged-in user's email
    /// - Returns: email string if logged in, nil otherwise
    func getCurrentUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: userEmailKey)
    }

    /// Retrieves the logged-in user's name
    /// - Returns: name string if logged in, nil otherwise
    func getCurrentUserName() -> String? {
        return UserDefaults.standard.string(forKey: userNameKey)
    }

    // MARK: - Google Sign-In

    /// Initiates Google Sign-In flow
    /// NOTE: This requires GoogleSignIn SDK integration (via Swift Package Manager)
    /// For now, this is a placeholder that simulates the flow
    /// - Returns: tuple of (name, email) if successful, throws error if failed
    func signInWithGoogle() async throws -> (name: String, email: String) {
        // TODO: Integrate Google Sign-In SDK
        // Real implementation would look like:
        // 1. Configure Google Sign-In with client ID
        // 2. Present Google sign-in UI
        // 3. Get user profile from GIDGoogleUser
        // 4. Return name and email

        // Simulated delay to mimic network request
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // For development: return mock data
        // Replace this with actual Google Sign-In SDK call
        let mockName = "Akshat Rana"
        let mockEmail = "akshat@example.com"

        // Save login state
        saveLoginSession(name: mockName, email: mockEmail)

        return (name: mockName, email: mockEmail)
    }

    /// Initiates Apple Sign-In flow
    /// NOTE: This requires AuthenticationServices framework
    /// - Returns: tuple of (name, email) if successful, throws error if failed
    func signInWithApple() async throws -> (name: String, email: String) {
        // TODO: Integrate Sign in with Apple
        // Real implementation uses ASAuthorizationController
        throw NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple Sign-In not yet implemented"])
    }

    // MARK: - Face ID / Touch ID Authentication

    /// Authenticates user using Face ID or Touch ID
    /// - Parameter reason: String shown in the biometric prompt
    /// - Returns: true if authentication succeeded, false if failed or not available
    func authenticateWithBiometrics(reason: String) async -> Bool {
        let context = LAContext()  // LocalAuthentication context
        var error: NSError?

        // Check if biometrics are available on this device
        // canEvaluatePolicy checks if Face ID/Touch ID is set up
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometrics not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }

        do {
            // Present Face ID / Touch ID prompt
            // This is an async operation - iOS shows the biometric UI
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch {
            // User cancelled, biometric failed, or other error
            print("Biometric authentication failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Session Management

    /// Saves login session to UserDefaults
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: User's email address
    private func saveLoginSession(name: String, email: String) {
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        UserDefaults.standard.set(email, forKey: userEmailKey)
        UserDefaults.standard.set(name, forKey: userNameKey)
    }

    /// Clears login session and signs out user
    func signOut() {
        // TODO: Call Google Sign-In SDK signOut() method
        // Clear all stored session data
        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
    }
}

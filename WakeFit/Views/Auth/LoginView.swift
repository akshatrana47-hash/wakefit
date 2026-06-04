//
//  LoginView.swift
//  WakeFit
//
//  Login screen matching Stitch design exactly
//  Shows "WakeFit" branding and Google/Apple sign-in buttons
//

import SwiftUI
import GoogleSignIn

struct LoginView: View {

    // MARK: - ViewModel
    // @Bindable allows two-way data flow between View and ViewModel
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background - deep navy fills entire screen
            Color(AppColors.bgBase)
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Branding Section

                VStack(spacing: 16) {
                    // "WakeFit" title - large, bold, electric teal
                    Text("WakeFit")
                        .font(.system(size: 56, weight: .bold, design: .default))
                        .foregroundStyle(AppColors.accentTeal)

                    // Subtitle - "Your discipline starts here."
                    Text("Your discipline starts here.")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(AppColors.textPrimary)
                }

                Spacer()

                // MARK: - Authentication Buttons Section

                VStack(spacing: 16) {

                    // Google Sign-In Button
                    Button {
                        // Real Google Sign-In integration
                        handleGoogleSignIn()
                    } label: {
                        HStack(spacing: 12) {
                            // Google logo (using SF Symbol as placeholder)
                            // TODO: Replace with actual Google logo image
                            Image(systemName: "globe")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.black)

                            // Button text
                            Text("CONTINUE WITH GOOGLE")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                    }
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.6 : 1.0)

                    // Apple Sign-In Button
                    Button {
                        Task {
                            await viewModel.handleAppleSignIn()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            // Apple logo
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.white)

                            // Button text
                            Text("CONTINUE WITH APPLE")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.6 : 1.0)
                }
                .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 80)
            }

            // MARK: - Loading Overlay

            // Show loading indicator while sign-in is in progress
            if viewModel.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea(.all)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentTeal))
                    .scaleEffect(1.5)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        // MARK: - Error Alert
        // Show alert if sign-in fails
        .alert("Sign-In Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Google Sign-In Handler

    /// Handles Google Sign-In flow using GIDSignIn SDK
    /// Gets the root view controller, initiates sign-in, and processes the result
    private func handleGoogleSignIn() {
        // Step 1: Get the window scene and root view controller
        guard let windowScene = UIApplication.shared.connectedScenes
            .first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else {
            viewModel.errorMessage = "Unable to find root view controller"
            return
        }

        // Step 2: Show loading state
        viewModel.isLoading = true

        // Step 3: Initiate Google Sign-In
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            // Step 4: Hide loading state
            viewModel.isLoading = false

            // Step 5: Handle errors
            if let error = error {
                viewModel.errorMessage = error.localizedDescription
                return
            }

            // Step 6: Extract user data from successful sign-in
            guard let user = result?.user,
                  let profile = user.profile else {
                viewModel.errorMessage = "Failed to get user profile"
                return
            }

            // Step 7: Get user email and name
            let email = profile.email
            let name = profile.givenName ?? "User"

            // Step 8: Save authentication state to UserDefaults
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(email, forKey: "userEmail")
            UserDefaults.standard.set(name, forKey: "userName")
            UserDefaults.standard.set(false, forKey: "hasCompletedSetup")

            // Step 9: Update view model to trigger navigation
            viewModel.isAuthenticated = true
            viewModel.needsProfileSetup = true
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView(viewModel: AuthViewModel())
}

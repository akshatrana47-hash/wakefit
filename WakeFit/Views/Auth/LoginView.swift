//
//  LoginView.swift
//  WakeFit
//
//  Login screen matching Stitch design exactly
//  Shows "WakeFit" branding and Google/Apple sign-in buttons
//

import SwiftUI

struct LoginView: View {

    // MARK: - ViewModel
    // @Bindable allows two-way data flow between View and ViewModel
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background - deep navy fills entire screen
            AppColors.bgBase
                .ignoresSafeArea()

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
                        // Bypass for development - simulate successful login
                        viewModel.simulateLogin()
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
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentTeal))
                    .scaleEffect(1.5)
            }
        }
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
}

// MARK: - Preview

#Preview {
    LoginView(viewModel: AuthViewModel())
}

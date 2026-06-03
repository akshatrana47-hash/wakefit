//
//  ProfileSetupView.swift
//  WakeFit
//
//  First-time user profile setup screen
//  Collects name, starting weight, target weight, and height
//  Matches Stitch design exactly with dark cards and teal accents
//

import SwiftUI
import SwiftData

struct ProfileSetupView: View {

    // MARK: - Environment & ViewModel

    // SwiftData model context for saving User model
    @Environment(\.modelContext) private var modelContext

    // AuthViewModel to mark setup as complete
    @Bindable var viewModel: AuthViewModel

    // MARK: - Form State
    // @State properties hold form input values

    @State private var fullName: String = ""
    @State private var startingWeight: String = ""
    @State private var targetWeight: String = ""
    @State private var height: String = ""

    // MARK: - Validation State
    @State private var showValidationError: Bool = false
    @State private var validationMessage: String = ""


    var body: some View {
        ZStack {
            // Background
            AppColors.bgBase
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - Progress Indicator

                    VStack(alignment: .leading, spacing: 8) {
                        // "STEP 1 OF 1" label
                        Text("STEP 1 OF 1")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.accentTeal)
                            .tracking(0.08 * 12)

                        // Progress bar - full width, teal fill
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                Rectangle()
                                    .fill(AppColors.cardBorder)
                                    .frame(height: 4)

                                // Filled progress (100% since it's step 1 of 1)
                                Rectangle()
                                    .fill(AppColors.accentTeal)
                                    .frame(width: geometry.size.width, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(.top, 20)

                    // MARK: - Title & Subtitle

                    VStack(alignment: .leading, spacing: 12) {
                        // "Set your baseline" title
                        Text("Set your baseline")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)

                        // Subtitle
                        Text("Enter your physical metrics to calibrate your discipline protocol.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineSpacing(4)
                    }

                    // MARK: - Form Fields

                    VStack(spacing: 16) {

                        // Full Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FULL NAME")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppColors.textMuted)
                                .tracking(0.08 * 12)

                            // Input card with icon
                            HStack(spacing: 16) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppColors.textMuted)
                                    .frame(width: 24)

                                TextField("John Doe", text: $fullName)
                                    .autocorrectionDisabled()
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(AppColors.bgCard)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )
                        }

                        // Weight Fields - Side by Side
                        HStack(spacing: 12) {
                            // Starting Weight
                            VStack(alignment: .leading, spacing: 8) {
                                Text("STARTING WGT (KG)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppColors.textMuted)
                                    .tracking(0.08 * 12)

                                HStack(spacing: 12) {
                                    Image(systemName: "scalemass.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(AppColors.textMuted)
                                        .frame(width: 24)

                                    TextField("85", text: $startingWeight)
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                                .background(AppColors.bgCard)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.cardBorder, lineWidth: 1)
                                )
                            }

                            // Target Weight
                            VStack(alignment: .leading, spacing: 8) {
                                Text("TARGET WGT (KG)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppColors.textMuted)
                                    .tracking(0.08 * 12)

                                HStack(spacing: 12) {
                                    Image(systemName: "flag.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(AppColors.textMuted)
                                        .frame(width: 24)

                                    TextField("75", text: $targetWeight)
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                                .background(AppColors.bgCard)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.cardBorder, lineWidth: 1)
                                )
                            }
                        }

                        // Height Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("HEIGHT (CM)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppColors.textMuted)
                                .tracking(0.08 * 12)

                            HStack(spacing: 16) {
                                Image(systemName: "arrow.up.and.down")
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppColors.textMuted)
                                    .frame(width: 24)

                                TextField("180", text: $height)
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(AppColors.bgCard)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )
                        }
                    }

                    Spacer()
                        .frame(height: 40)

                    // MARK: - Submit Button

                    Button {
                        handleSubmit()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Let's Begin")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.black)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.accentTeal)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Incomplete Information", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }

    // MARK: - Form Submission

    /// Validates form inputs and creates User model
    private func handleSubmit() {
        // Validate all fields are filled
        guard !fullName.isEmpty else {
            validationMessage = "Please enter your full name"
            showValidationError = true
            return
        }

        guard let startWeight = Double(startingWeight), startWeight > 0 else {
            validationMessage = "Please enter a valid starting weight"
            showValidationError = true
            return
        }

        guard let targetWgt = Double(targetWeight), targetWgt > 0 else {
            validationMessage = "Please enter a valid target weight"
            showValidationError = true
            return
        }

        guard let heightCm = Double(height), heightCm > 0 else {
            validationMessage = "Please enter a valid height"
            showValidationError = true
            return
        }

        // Create User model with form data
        let newUser = User(
            name: fullName,
            email: viewModel.userEmail,
            startingWeight: startWeight,
            targetWeight: targetWgt,
            height: heightCm,
            startDate: Date()
        )

        // Save to SwiftData
        modelContext.insert(newUser)
        try? modelContext.save()

        // Update UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        UserDefaults.standard.set(startWeight, forKey: "startingWeight")
        UserDefaults.standard.set(targetWgt, forKey: "targetWeight")

        // Request notification permission and schedule all notifications
        NotificationManager.shared.requestPermission { granted in
            if granted {
                NotificationManager.shared.scheduleAllNotifications()
            }
        }

        // Mark profile setup as complete in ViewModel
        // This will trigger navigation to Dashboard
        viewModel.completeProfileSetup()
    }
}

// MARK: - Preview

#Preview {
    ProfileSetupView(viewModel: AuthViewModel())
        .modelContainer(for: User.self, inMemory: true)
}

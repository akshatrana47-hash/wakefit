//
//  AddFoodItemView.swift
//  WakeFit
//
//  Bottom sheet for adding food entries
//  Supports text input and voice recording
//

import SwiftUI

struct AddFoodItemView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let timeBlock: String
    let onSave: (String) -> Void

    // MARK: - State

    @State private var foodText: String = ""
    @State private var isRecording: Bool = false
    @State private var showEmptyError: Bool = false

    var body: some View {
        ZStack {
            AppColors.bgCard
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Add Food Entry")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                            .frame(width: 36, height: 36)
                            .background(AppColors.bgBase)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer()
                    .frame(height: 32)

                // Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("WHAT DID YOU EAT?")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.textMuted)
                        .tracking(0.08 * 12)

                    // Text Input
                    ZStack(alignment: .topLeading) {
                        if foodText.isEmpty {
                            Text("2 scrambled eggs with spinach, half an avocado, and a black coffee.")
                                .font(.system(size: 16))
                                .foregroundStyle(AppColors.textMuted.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                        }

                        TextEditor(text: $foodText)
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 120)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    }
                    .background(AppColors.bgBase)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(showEmptyError ? AppColors.danger : AppColors.cardBorder, lineWidth: 1)
                    )

                    if showEmptyError {
                        Text("Please enter what you ate")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.danger)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Voice Recording Button
                VStack(spacing: 12) {
                    Button {
                        isRecording.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(isRecording ? AppColors.accentTeal : AppColors.accentTeal, lineWidth: 2)
                                .frame(width: 80, height: 80)
                                .opacity(isRecording ? 0.3 : 1.0)

                            Circle()
                                .fill(isRecording ? AppColors.accentTeal.opacity(0.2) : AppColors.bgBase)
                                .frame(width: 80, height: 80)
                                .scaleEffect(isRecording ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRecording)

                            Image(systemName: "mic.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppColors.accentTeal)
                        }
                    }

                    if isRecording {
                        Text("Listening...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.accentTeal)
                    }
                }
                .padding(.bottom, 32)

                // Save Button
                Button {
                    save()
                } label: {
                    HStack(spacing: 8) {
                        Text("Save Entry")
                            .font(.system(size: 18, weight: .bold))

                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(foodText.isEmpty ? AppColors.textMuted : AppColors.accentTeal)
                    .cornerRadius(16)
                }
                .disabled(foodText.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Functions

    /// Save food entry
    private func save() {
        let trimmed = foodText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showEmptyError = true
            return
        }
        onSave(trimmed)
        dismiss()
    }
}

#Preview {
    AddFoodItemView(timeBlock: "morning", onSave: { _ in })
}

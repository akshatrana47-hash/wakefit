//
//  ProfileView.swift
//  WakeFit
//
//  Profile and settings screen
//  Shows user stats, preferences, and account management
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - SwiftData Queries

    @Query var users: [User]
    @Query var foodLogs: [FoodLog]
    @Query var weightEntries: [WeightEntry]
    @Query var wakeUpEntries: [WakeUpEntry]
    @Query var sleepEntries: [SleepEntry]

    // MARK: - State

    @State private var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    @State private var faceIDEnabled: Bool = UserDefaults.standard.bool(forKey: "faceIDEnabled")
    @State private var showSignOutAlert: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var editName: String = ""

    // MARK: - Computed Properties

    private var user: User? {
        users.first
    }

    private var userName: String {
        user?.name ?? "User"
    }

    private var userInitials: String {
        let name = userName
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1))
        } else if let first = components.first {
            return String(first.prefix(2))
        }
        return "U"
    }

    private var startDate: String {
        guard let user = user else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: user.startDate)
    }

    private var daysActive: Int {
        guard let user = user else { return 0 }
        return Calendar.current.dateComponents([.day], from: user.startDate, to: Date()).day ?? 0
    }

    private var totalEntries: Int {
        return foodLogs.count + weightEntries.count + wakeUpEntries.count + sleepEntries.count
    }

    private var targetWeight: String {
        guard let user = user else { return "—" }
        return String(format: "%.1f kg", user.targetWeight)
    }

    var body: some View {
        ZStack {
            Color(AppColors.bgBase)
                .ignoresSafeArea(.all)

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColors.textPrimary)
                        }

                        Spacer()

                        Text("Profile")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        // Invisible spacer for centering
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .opacity(0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Avatar & Name
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            // Avatar Circle
                            ZStack {
                                Circle()
                                    .fill(AppColors.accentTeal)
                                    .frame(width: 120, height: 120)

                                Circle()
                                    .stroke(AppColors.cardBorder, lineWidth: 3)
                                    .frame(width: 120, height: 120)

                                Text(userInitials.uppercased())
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundStyle(.black)
                            }

                            // Edit button
                            Button {
                                editName = userName
                                showEditSheet = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(AppColors.bgCard)
                                    .clipShape(Circle())
                            }
                        }

                        Text(userName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Initiate Phase")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    // Stats Cards
                    HStack(spacing: 12) {
                        StatCardProfile(
                            icon: "calendar",
                            value: startDate,
                            label: "START DATE"
                        )

                        StatCardProfile(
                            icon: "flame.fill",
                            value: "\(daysActive)",
                            label: "DAYS\nACTIVE"
                        )

                        StatCardProfile(
                            icon: "checklist",
                            value: "\(totalEntries)",
                            label: "TOTAL\nENTRIES"
                        )
                    }
                    .padding(.horizontal, 20)

                    // Preferences Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PREFERENCES")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                            .tracking(0.08 * 12)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            // Push Notifications
                            SettingsRow(
                                icon: "bell.fill",
                                title: "Push Notifications",
                                trailing: AnyView(
                                    Toggle("", isOn: $notificationsEnabled)
                                        .labelsHidden()
                                        .tint(AppColors.accentTeal)
                                        .onChange(of: notificationsEnabled) { _, newValue in
                                            UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
                                            if newValue {
                                                NotificationManager.shared.scheduleAllNotifications()
                                            } else {
                                                NotificationManager.shared.cancelAllNotifications()
                                            }
                                        }
                                )
                            )

                            Divider()
                                .background(AppColors.cardBorder)
                                .padding(.horizontal, 20)

                            // Face ID Security
                            SettingsRow(
                                icon: "faceid",
                                title: "Face ID Security",
                                trailing: AnyView(
                                    Toggle("", isOn: $faceIDEnabled)
                                        .labelsHidden()
                                        .tint(AppColors.accentTeal)
                                        .onChange(of: faceIDEnabled) { _, newValue in
                                            UserDefaults.standard.set(newValue, forKey: "faceIDEnabled")
                                        }
                                )
                            )

                            Divider()
                                .background(AppColors.cardBorder)
                                .padding(.horizontal, 20)

                            // Target Weight
                            SettingsRow(
                                icon: "target",
                                title: "Target Weight",
                                trailing: AnyView(
                                    HStack(spacing: 8) {
                                        Text(targetWeight)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(AppColors.accentTeal)

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundStyle(AppColors.textMuted)
                                    }
                                ),
                                action: {
                                    // TODO: Edit target weight
                                }
                            )

                            Divider()
                                .background(AppColors.cardBorder)
                                .padding(.horizontal, 20)

                            // Test Notification
                            SettingsRow(
                                icon: "bell.badge.fill",
                                title: "Test Notification Sound",
                                trailing: AnyView(
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppColors.textMuted)
                                ),
                                action: {
                                    testNotificationSound()
                                }
                            )
                        }
                        .padding(.vertical, 8)
                        .background(AppColors.bgCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }

                    // Data & Control Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DATA & CONTROL")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                            .tracking(0.08 * 12)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            // Export Data
                            SettingsRow(
                                icon: "arrow.down.circle",
                                title: "Export Protocol Data",
                                trailing: AnyView(
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppColors.textMuted)
                                ),
                                action: {
                                    // TODO: Export data
                                }
                            )

                            Divider()
                                .background(AppColors.cardBorder)
                                .padding(.horizontal, 20)

                            // Sign Out
                            SettingsRow(
                                icon: "rectangle.portrait.and.arrow.right",
                                title: "Sign Out",
                                titleColor: AppColors.danger,
                                action: {
                                    showSignOutAlert = true
                                }
                            )
                        }
                        .padding(.vertical, 8)
                        .background(AppColors.bgCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }

                    // Version Footer
                    Text("PROTOCOL V.1.0.4")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textMuted.opacity(0.5))
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out? You'll need to log in again.")
        }
        .sheet(isPresented: $showEditSheet) {
            EditProfileSheet(
                userName: $editName,
                onSave: {
                    saveProfileChanges()
                }
            )
        }
    }

    // MARK: - Functions

    private func signOut() {
        // Clear ALL UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }

        // Cancel notifications
        NotificationManager.shared.cancelAllNotifications()

        // Navigate back to login (handled by AuthViewModel)
        dismiss()
    }

    /// Save profile changes
    private func saveProfileChanges() {
        guard !editName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if let user = user {
            user.name = editName
            try? modelContext.save()
        }
        showEditSheet = false
    }

    /// Test notification sound
    private func testNotificationSound() {
        NotificationManager.shared.sendTestNotification()
        // Show confirmation (optional - the notification itself will confirm)
        print("Test notification sent - check your device in 2 seconds!")
    }
}

// MARK: - Stat Card Profile Component

struct StatCardProfile: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(AppColors.textMuted)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppColors.accentTeal)

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppColors.textMuted)
                .tracking(0.08 * 10)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.bgCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
    let icon: String
    let title: String
    var titleColor: Color = AppColors.textPrimary
    var trailing: AnyView? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(titleColor)
                    .frame(width: 24, alignment: .center)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(titleColor)

                Spacer()

                if let trailing = trailing {
                    trailing
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color(AppColors.bgBase)
                    .ignoresSafeArea(.all)

                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("EDIT PROFILE")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                            .tracking(0.08 * 12)

                        Text("Update your profile information")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.top, 20)

                    // Name Field
                    VStack(alignment: .leading, spacing: 12) {
                        Text("NAME")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                            .tracking(0.08 * 12)

                        TextField("Enter your name", text: $userName)
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(16)
                            .background(AppColors.bgBase)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )
                    }
                    .padding(20)
                    .background(AppColors.bgCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.cardBorder, lineWidth: 1)
                    )

                    Spacer()

                    // Save Button
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppColors.accentTeal)
                            .cornerRadius(16)
                    }
                    .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(userName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.accentTeal)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .modelContainer(for: [User.self, FoodLog.self, WeightEntry.self, WakeUpEntry.self, SleepEntry.self], inMemory: true)
    }
}

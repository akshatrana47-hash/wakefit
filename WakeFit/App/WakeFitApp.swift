//
//  WakeFitApp.swift
//  WakeFit
//
//  App entry point with splash screen, authentication flow, and SwiftData container
//

import SwiftUI
import SwiftData

@main
struct WakeFitApp: App {
    // SwiftData storage container - registers all models and creates the database
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            WakeUpEntry.self,
            SleepEntry.self,
            FoodLog.self,
            WeightEntry.self,
            AIAnalysis.self,
        ])
        // isStoredInMemoryOnly: false means data persists on disk (survives app restarts)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // AuthViewModel manages authentication state across entire app
    @State private var authViewModel = AuthViewModel()

    // Tracks whether splash screen has finished
    @State private var showSplash: Bool = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    // Show splash screen first
                    SplashView()
                        .transition(.opacity)
                } else {
                    // Show main app after splash
                    AuthenticatedRootView(viewModel: authViewModel)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .onAppear {
                // Hide splash screen after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showSplash = false
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

/// Root view that navigates between Login, Profile Setup, and Dashboard
/// based on authentication state
struct AuthenticatedRootView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        Group {
            // Navigation logic based on auth state
            if viewModel.isAuthenticated {
                // User is logged in
                if viewModel.needsProfileSetup {
                    // First-time user - show profile setup
                    ProfileSetupView(viewModel: viewModel)
                } else {
                    // Existing user - show dashboard
                    DashboardView()
                }
            } else {
                // User not logged in - show login screen
                LoginView(viewModel: viewModel)
            }
        }
    }
}

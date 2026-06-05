# WakeFit Discipline Tracker

## App Overview
**WakeFit Discipline Tracker** is an iOS application designed to help users track their wake-up time, sleep discipline, food logging, weight tracking, and overall daily self-accountability.

## Technology Stack
*   **Platform:** iOS
*   **Language:** Swift
*   **Framework:** SwiftUI
*   **Architecture:** MVVM (Model-View-ViewModel)
*   **Persistence:** SwiftData (Local-first)
*   **AI Integration:** OpenAI API (`gpt-4o`) for AI calorie diagnosis and nutrition coaching
*   **Voice Integration:** Apple Speech framework for speech-to-text food entry
*   **Authentication:** Google Sign-In and biometric authentication (Face ID)

## Key Features

1.  **Authentication & Onboarding:**
    *   Google Sign-In integration.
    *   Biometric unlock (Face ID) for returning users.
    *   Initial profile setup (Name, Starting Weight, Target Weight, Height).

2.  **Dashboard:**
    *   Central hub showing the daily discipline score (0-100 scale).
    *   Displays today's wake-up time, food log completion, current weight, and days since start date.
    *   Calculates discipline score based on logging wake-up time, tracking food, and sleeping on time.

3.  **Discipline Tracking:**
    *   **Wake-up Tracking:** Log actual wake-up times and maintain a history.
    *   **Sleep Tracking:** Log whether sleep was on time and add notes.
    *   **Food Logging:** Track food intake across three daily blocks:
        *   Morning (12:00 AM – 1:00 PM)
        *   Afternoon (1:00 PM – 5:00 PM)
        *   Evening (5:00 PM – 9:30 PM)
    *   **Weight Tracking:** Log and track weight progress in kilograms (kg) over time.

4.  **AI Analysis:**
    *   "Analyze My Day" feature powered by OpenAI.
    *   Takes daily food logs as input and returns estimated calories, estimated protein (grams), risk areas, discipline status, and coach advice for the next day.

5.  **Notifications Schedule:**
    *   Regular daily local notifications to keep users accountable:
        *   7:30 AM: Wake-up logging reminder.
        *   1:30 PM - 4:00 PM: Calorie control reminders.
        *   4:30 PM: Movement reminder.
        *   11:00 PM: Sleep preparation reminder.

## Project Structure
The app adheres to a clean MVVM structure:
*   **App:** Application entry point (`WakeFitApp.swift`).
*   **Models:** SwiftData schemas (`User`, `WakeUpEntry`, `SleepEntry`, `FoodLog`, `WeightEntry`, `AIAnalysis`).
*   **ViewModels:** Business logic and state management for each screen.
*   **Views:** SwiftUI components organized by feature (Auth, Dashboard, WakeUp, Sleep, FoodLog, Weight, AIAnalysis, Search).
*   **Services:** Independent managers for Notifications, Auth, Food, Weight, AI Analysis, and Speech-to-Text.
*   **Utilities:** Constants (colors, spacing, radii), date helpers, and extensions.

## Design System
*   **Theme:** Dark mode first with a specific navy palette.
*   **Base Background:** `#051424` (Dark Navy)
*   **Surface:** `#0D1C2D`
*   **Card Background:** `#122131`
*   **Accent Color:** `#46F1CF` (Teal)
*   **Status Colors:** Success (`#00C896`), Warning (`#F5A623`), Danger (`#FF5C5C`)

# WakeFit Discipline Tracker — Claude Code Project Instructions

## Who You Are
You are my senior iOS development mentor and coding assistant. I am learning iOS development from scratch. Explain every decision clearly — why each file exists, what each function does, and how data flows from UI to storage to AI.

---

## App Overview
**App Name:** WakeFit Discipline Tracker  
**Purpose:** Help me track wake-up time, sleep discipline, calorie control, food logging, weight tracking, and daily self-accountability.  
**Stack:** Swift, SwiftUI, SwiftData (local-first), MVVM architecture  
**Backend:** SwiftData first. Add Firebase/Supabase only if cloud sync is needed later.

---

## Development Rules

- Never dump all code at once. Build module by module.
- Before writing any code for a new module, explain what it does and why.
- Use MVVM strictly: Models → ViewModels → Views. No business logic in Views.
- All files go in their correct folder (see structure below).
- Use SwiftData for persistence unless I explicitly ask for Firebase.
- Keep the OpenAI API layer modular so I can plug in my own key later.
- Explain every function with an inline comment on first introduction.
- If a concept is new (e.g. @Observable, @Query, UNUserNotificationCenter), briefly explain it before using it.

---

## Build Order (Do Not Skip Steps)

1. Environment setup + learning foundation
2. Project skeleton + folder structure
3. SwiftData models + schema
4. Authentication (Google Login + Face ID)
5. Dashboard (home screen shell)
6. Wake-up tracking + notifications
7. Sleep reminder notifications
8. Calorie control notifications (1:30 PM – 4:30 PM)
9. Food logging (3 time blocks + manual entry)
10. Speech-to-text food entry (Apple Speech framework)
11. AI calorie diagnosis (OpenAI API, modular)
12. Weight tracking + graph
13. Search functionality
14. Polish: discipline score, streak counters, UI refinement

---

## Folder Structure

```
WakeFit/
├── App/
│   └── WakeFitApp.swift           # App entry point
├── Models/
│   ├── User.swift
│   ├── WakeUpEntry.swift
│   ├── SleepEntry.swift
│   ├── FoodLog.swift
│   ├── WeightEntry.swift
│   └── AIAnalysis.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── WakeUpViewModel.swift
│   ├── SleepViewModel.swift
│   ├── FoodLogViewModel.swift
│   ├── WeightViewModel.swift
│   └── AIAnalysisViewModel.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── ProfileSetupView.swift
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── WakeUp/
│   │   └── WakeUpView.swift
│   ├── Sleep/
│   │   └── SleepView.swift
│   ├── FoodLog/
│   │   ├── FoodLogView.swift
│   │   └── AddFoodItemView.swift
│   ├── Weight/
│   │   ├── WeightView.swift
│   │   └── WeightGraphView.swift
│   ├── AIAnalysis/
│   │   └── AIAnalysisView.swift
│   └── Search/
│       └── SearchView.swift
├── Services/
│   ├── NotificationManager.swift  # All local notifications
│   ├── AuthManager.swift          # Google Login + Face ID
│   ├── FoodLogManager.swift       # Food log CRUD
│   ├── WeightManager.swift        # Weight CRUD + progress
│   ├── AIAnalysisService.swift    # OpenAI API calls
│   └── SpeechToTextService.swift  # Apple Speech framework
├── Utilities/
│   ├── Constants.swift            # App-wide constants
│   ├── DateHelpers.swift          # Date formatting utilities
│   └── Extensions.swift           # Swift extensions
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

---

## SwiftData Schema

### User
```swift
@Model class User {
    var id: UUID
    var name: String
    var email: String
    var startingWeight: Double   // kg
    var targetWeight: Double     // kg
    var height: Double           // cm
    var startDate: Date
}
```

### WakeUpEntry
```swift
@Model class WakeUpEntry {
    var id: UUID
    var date: Date               // calendar date
    var wakeUpTime: Date         // actual time logged
}
```

### SleepEntry
```swift
@Model class SleepEntry {
    var id: UUID
    var date: Date
    var sleptOnTime: Bool
    var notes: String
}
```

### FoodLog
```swift
@Model class FoodLog {
    var id: UUID
    var date: Date
    var timeBlock: String        // "morning", "afternoon", "evening"
    var foodText: String         // typed or speech-to-text
    var entryTime: Date
}
```

### WeightEntry
```swift
@Model class WeightEntry {
    var id: UUID
    var date: Date
    var weight: Double           // kg
}
```

### AIAnalysis
```swift
@Model class AIAnalysis {
    var id: UUID
    var date: Date
    var estimatedCalories: Int
    var estimatedProtein: Int
    var riskAreas: String
    var disciplineStatus: String
    var coachDiagnosis: String
    var tomorrowAdvice: String
}
```

---

## Notification Schedule

| Time | Message |
|------|---------|
| 7:30 AM daily | "Clock in your wake-up time." |
| Every 5th day 7:30 AM | "Enter your current weight." |
| 1:30 PM | "Stay controlled. Not more than 700 calories before evening." |
| 2:00 PM | Calorie reminder |
| 2:30 PM | Calorie reminder |
| 3:00 PM | Calorie reminder |
| 3:30 PM | Calorie reminder |
| 4:00 PM | Calorie reminder |
| 4:30 PM | "Go out to play. Move now." |
| 11:00 PM | "Start preparing to sleep. Target sleep time: before 11:50 PM." |

---

## Food Log Time Blocks

| Block | Window |
|-------|--------|
| Morning | 12:00 AM – 1:00 PM |
| Afternoon | 1:00 PM – 5:00 PM |
| Evening | 5:00 PM – 9:30 PM |

Each block supports:
- Manual text entry
- Voice recording → Speech-to-text (Apple Speech framework)
- View/edit/delete entries

---

## AI Analysis (OpenAI)

Endpoint: `POST https://api.openai.com/v1/chat/completions`  
Model: `gpt-4o`  
Trigger: User taps "Analyze My Day"

Prompt template (send all food logs for the day):
```
You are a nutrition and discipline coach. Analyze this food log and return JSON with:
- estimatedCalories (Int)
- estimatedProtein (Int, grams)
- riskAreas (String)
- disciplineStatus ("Disciplined" | "Borderline" | "Off Track")
- coachDiagnosis (String, 2-3 sentences)
- tomorrowAdvice (String, 1-2 sentences)

Food log: [INSERT FOOD LOGS HERE]
```

API key stored in: `Secrets.swift` (gitignored). Never hardcode in source.

---

## Dashboard Must Show

- Today's wake-up time (or prompt to log it)
- Food log completion per time block
- Current weight
- Days since start date
- Estimated calories today (if AI analysis exists)
- Discipline score (calculated from: wake-up logged + food logged + slept on time)

---

## Authentication Flow

1. App opens → check if user is logged in (AuthManager)
2. If not → show LoginView (Google Sign-In)
3. If logged in → check Face ID / biometric unlock
4. After unlock → show DashboardView
5. First login → show ProfileSetupView to capture weight, height, target

---

## Learning Checkpoints

Before each new module, explain:
- What the module does
- Which files will be created
- What design pattern is used (e.g. `@Observable`, `@Query`, `async/await`)
- Any Apple framework being introduced for the first time

---

## Key Principles

- **Local first.** SwiftData is the default. No network calls except OpenAI.
- **Modular.** Each service is independent and injectable.
- **Teachable.** Every non-obvious line gets a comment on first use.
- **Clean UI.** SwiftUI only. No UIKit unless unavoidable (e.g. AVAudioRecorder).
- **No shortcuts.** If I ask why something works, explain it fully.

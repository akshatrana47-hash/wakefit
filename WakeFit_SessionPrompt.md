# WakeFit — Master Re-Orientation Prompt
## Paste this at the START of every new Claude Code session

---

## WHO YOU ARE
You are my senior iOS development mentor. I am learning iOS from scratch.
Explain every decision clearly. Comment every new function on first introduction.
Never dump all code at once. Build one thing at a time. Confirm build success before moving on.

---

## APP OVERVIEW
**App Name:** WakeFit Discipline Tracker
**Stack:** Swift, SwiftUI, SwiftData, MVVM
**Xcode Version:** 26.5 (Swift 6)
**Target:** iPhone (iOS 26+)
**Simulator:** iPhone 17 Pro

---

## CRITICAL SWIFT 6 / XCODE 26 RULES — NEVER BREAK THESE

1. NEVER use `.keyboardType()` on TextField → causes build error
2. NEVER use `.foregroundColor()` → always use `.foregroundStyle()`
3. NEVER use `@Published` in `@Observable` classes → use plain properties
4. ALWAYS use `try? modelContext.save()` after SwiftData inserts
5. ALWAYS use `.buttonStyle(PlainButtonStyle())` on NavigationLink cards
6. NEVER use `import Charts` → not available, use custom drawing
7. ALWAYS run build check after every file change

---

## PROJECT LOCATION
```
~/Desktop/WakeFit/
├── WakeFit/                    ← all Swift source files here
│   ├── App/WakeFitApp.swift
│   ├── Models/                 ← 6 SwiftData models
│   ├── ViewModels/             ← AuthViewModel
│   ├── Views/                  ← all 13 screens
│   ├── Services/               ← AuthManager, NotificationManager, SpeechToTextService
│   └── Utilities/              ← Constants, Extensions, Secrets
├── stitch_wakefit_discipline_tracker/  ← Stitch UI designs (13 PNG files)
├── CLAUDE.md                   ← project rules
├── WakeFit_ScreenSpecs.md      ← full screen specs
└── WakeFit_MasterPrompt.md     ← master requirements
```

---

## DESIGN SYSTEM (from Stitch — use exactly)
```swift
// AppColors (defined in Utilities/Constants.swift)
bgBase       = #051424   // deep navy background
bgCard       = #122131   // card surface
bgCardHigh   = #1C2B3C   // elevated card
accentTeal   = #46F1CF   // primary accent — buttons, active states
success      = #00C896   // disciplined state
warning      = #F5A623   // borderline, calorie warnings
danger       = #FF5C5C   // off track, errors
textPrimary  = #D4E4FA   // main text
textSecondary = #BACAC4  // secondary labels
textMuted    = #84948F   // hints, placeholders
cardBorder   = #3B4A45   // card borders

// Spacing
screenMargin = 20px
cardPadding  = 20px
cardRadius   = 16px
buttonHeight = 56px
```

---

## SWIFTDATA MODELS (all 6 exist, do not recreate)
```swift
User          → id, name, email, startingWeight, targetWeight, height, startDate
WakeUpEntry   → id, date, wakeUpTime
SleepEntry    → id, date, sleptOnTime, notes
FoodLog       → id, date, timeBlock("morning"/"afternoon"/"evening"), foodText, entryTime
WeightEntry   → id, date, weight
AIAnalysis    → id, date, estimatedCalories, estimatedProtein, riskAreas,
                disciplineStatus, coachDiagnosis, tomorrowAdvice
```

---

## USERDEFAULTS KEYS (session state)
```swift
"isLoggedIn"          Bool    // Is user authenticated?
"hasCompletedSetup"   Bool    // Has user filled profile?
"userEmail"           String  // Google login email
"userName"            String  // Display name
"faceIDEnabled"       Bool    // Biometric lock on/off
"notificationsEnabled" Bool   // Notifications on/off
"startingWeight"      Double  // Cached from User model
"targetWeight"        Double  // Cached from User model
```

---

## COMPLETE USER JOURNEY + IF/ELSE LOGIC

```
APP LAUNCH
    ↓
SplashView (2.5 seconds, logo animation)
    ↓
isLoggedIn == false
    → LoginView
        ↓ tap "Continue with Google"
        → simulateLogin() [dev mode] OR real GoogleSignIn [production]
        → sets isLoggedIn=true, userEmail, userName, hasCompletedSetup=false
        ↓
        hasCompletedSetup == false
            → ProfileSetupView
                ↓ fill name, startingWeight, targetWeight, height
                ↓ validate all fields
                ↓ save User to SwiftData
                ↓ set hasCompletedSetup=true
                ↓ request notification permissions
                ↓ schedule all 10 notifications
                → DashboardView

        hasCompletedSetup == true
            → DashboardView

isLoggedIn == true
    → BiometricPromptView (Face ID)
        ↓ success → DashboardView
        ↓ failure/skip → LoginView

DASHBOARD NAVIGATION
    ├── WakeUpCard tap → WakeUpView
    ├── FoodLogCard tap → FoodLogView
    ├── WeightCard tap → WeightView
    ├── CaloriesCard tap → AIAnalysisView
    ├── Profile button → ProfileView
    └── Bottom tabs:
        ├── Home → DashboardView
        ├── Food → FoodLogView
        ├── Weight → WeightView
        ├── Analysis → AIAnalysisView
        └── Search → SearchView

SIGN OUT (from ProfileView)
    → clear all UserDefaults
    → viewModel.isAuthenticated = false
    → LoginView
```

---

## ALL 13 SCREENS — CURRENT STATUS + REMAINING WORK

### ✅ SCREEN 1 — Splash Screen
**Status:** Built
**File:** Views/SplashView.swift
**Acceptance Criteria:**
- [x] 2.5s animation, logo fades in + scales up
- [x] "SYSTEM ONLINE" text appears after logo
- [x] Routes correctly based on UserDefaults after animation
- [ ] **REMAINING:** Verify animation timing is correct on iPhone 17 Pro simulator

---

### ✅ SCREEN 2 — Login Screen
**Status:** Built (development mode — simulated login)
**File:** Views/Auth/LoginView.swift
**Acceptance Criteria:**
- [x] Dark navy background matches Stitch design
- [x] "WakeFit" title in teal, "Your discipline starts here." subtitle
- [x] Google button navigates to ProfileSetupView
- [ ] **REMAINING — NEXT PRIORITY:** Real Google Sign-In via Swift Package Manager
  ```
  Package URL: https://github.com/google/GoogleSignIn-iOS
  Version: 7.0.0+
  After adding package:
  - Replace simulateLogin() with real GIDSignIn.sharedInstance.signIn()
  - Store idToken in Keychain (not UserDefaults)
  - Handle sign-in errors gracefully
  ```

---

### ✅ SCREEN 3 — Profile Setup
**Status:** Built
**File:** Views/Auth/ProfileSetupView.swift
**Acceptance Criteria:**
- [x] All 4 fields with inline validation errors
- [x] Saves User to SwiftData
- [x] Navigates to Dashboard on submit
- [x] Requests notification permissions on submit
- [ ] **REMAINING:** Verify form doesn't crash on empty submit

---

### ✅ SCREEN 4 — Dashboard
**Status:** Built with real SwiftData queries
**File:** Views/Dashboard/DashboardView.swift
**Acceptance Criteria:**
- [x] Discipline score ring (color changes: teal/amber/red)
- [x] Wake-up card (logged/not logged state)
- [x] Food log card (3 badges: Morning/Afternoon/Evening)
- [x] Weight card (current weight + trend)
- [x] Calories card (with/without AI analysis)
- [x] Streak counter
- [x] All cards navigate to correct screens
- [x] Bottom tab bar works
- [ ] **REMAINING:** Connect discipline score to real data (currently partial)
- [ ] **REMAINING:** Streak counter reads real consecutive days from SwiftData

---

### ✅ SCREEN 5 — Wake-Up Log
**Status:** Built
**File:** Views/WakeUp/WakeUpView.swift
**Acceptance Criteria:**
- [x] Time picker defaults to current time
- [x] "Use Current Time" button
- [x] Saves/updates WakeUpEntry in SwiftData
- [x] Shows history list of past entries
- [ ] **REMAINING:** History list shows correct date formatting

---

### ✅ SCREEN 6 — Food Log
**Status:** Built
**File:** Views/FoodLog/FoodLogView.swift
**Acceptance Criteria:**
- [x] 3 expandable sections (Morning/Afternoon/Evening)
- [x] Entry count badges per section
- [x] Add food opens bottom sheet
- [x] Swipe to delete entries
- [x] Real SwiftData save/delete
- [ ] **REMAINING:** Date selector to view past days
- [ ] **REMAINING:** Match Stitch design more closely

---

### ✅ SCREEN 7 — Add Food Item (Bottom Sheet)
**Status:** Built with speech-to-text
**File:** Views/FoodLog/AddFoodItemView.swift
**Acceptance Criteria:**
- [x] Text input field
- [x] Mic button with pulsing animation when recording
- [x] Live speech transcription syncs to text field
- [x] Save button disabled when empty
- [x] Inline validation error
- [ ] **REMAINING:** Test on real iPhone (simulator has limited STT)
- [ ] **REMAINING:** Permission denied state with Settings link

---

### ✅ SCREEN 8 — Sleep Log
**Status:** Built
**File:** Views/Sleep/SleepView.swift
**Acceptance Criteria:**
- [x] Two toggle cards (Yes/No)
- [x] Notes field
- [x] 7-day history dots
- [x] Real SwiftData save
- [ ] **REMAINING:** Access from Dashboard (no card currently — add Sleep card to Dashboard)

---

### ✅ SCREEN 9 — AI Analysis
**Status:** Built (API call stubbed)
**File:** Views/AIAnalysis/AIAnalysisView.swift
**Acceptance Criteria:**
- [x] Empty state when no food logged
- [x] Loading skeleton cards
- [x] Results display (calories, protein, status badge, diagnosis)
- [ ] **REMAINING — HIGH PRIORITY:** Wire up real OpenAI API
  ```
  Steps:
  1. Add OpenAI API key to Utilities/Secrets.swift:
     struct APIKeys { static let openAI = "sk-..." }
  2. Implement AIAnalysisService.swift:
     POST https://api.openai.com/v1/chat/completions
     model: gpt-4o
     Send all today's food logs
     Parse JSON response into AIAnalysis model
     Save to SwiftData
  3. Wire "Analyze My Day" button to real API call
  ```
  **Prompt template for OpenAI:**
  ```
  You are a nutrition and discipline coach. 
  Analyze this food log and return ONLY valid JSON (no markdown):
  {
    "estimatedCalories": Int,
    "estimatedProtein": Int,
    "riskAreas": "string",
    "disciplineStatus": "Disciplined" | "Borderline" | "Off Track",
    "coachDiagnosis": "2-3 sentence string",
    "tomorrowAdvice": "1-2 sentence string"
  }
  Food log: [INSERT LOGS]
  ```

---

### ✅ SCREEN 10 — Weight Tracking
**Status:** Built
**File:** Views/Weight/WeightView.swift
**Acceptance Criteria:**
- [x] Stat cards (Starting/Current/Change)
- [x] Line graph (custom, no Charts import)
- [x] Log weight sheet
- [x] Real SwiftData save
- [ ] **REMAINING:** Target weight dashed line on graph
- [ ] **REMAINING:** Graph shows correct date labels on X-axis

---

### ✅ SCREEN 11 — Notifications
**Status:** Built
**File:** Services/NotificationManager.swift
**All 10 notifications scheduled:**
- [x] 7:30 AM — "Clock in your wake-up time."
- [x] Every 5th day 7:30 AM — "Enter your current weight."
- [x] 1:30 PM — "Stay controlled. Not more than 700 calories."
- [x] 2:00, 2:30, 3:00, 3:30, 4:00 PM — Calorie reminders
- [x] 4:30 PM — "Go out to play. Move now."
- [x] 11:00 PM — "Start preparing to sleep."
**Acceptance Criteria:**
- [ ] **REMAINING:** Test notifications fire on real iPhone
- [ ] **REMAINING:** Tapping notification opens correct screen (deep link)

---

### ✅ SCREEN 12 — Search
**Status:** Built
**File:** Views/Search/SearchView.swift
**Acceptance Criteria:**
- [x] Real-time search across food logs
- [x] 3 segments (Food/Weight/Notes)
- [x] Empty state
- [ ] **REMAINING:** Tap result navigates to that entry's screen

---

### ✅ SCREEN 13 — Profile/Settings
**Status:** Built
**File:** Views/Profile/ProfileView.swift
**Acceptance Criteria:**
- [x] User name, email, days active
- [x] Notification toggle
- [x] Face ID toggle
- [x] Sign out clears UserDefaults → LoginView
- [ ] **REMAINING:** Edit target weight inline
- [ ] **REMAINING:** Export data function

---

## NOTIFICATION SCHEDULE (for reference)
```
7:30 AM daily      → "Clock in your wake-up time."
Every 5th day 7:30 → "Enter your current weight."
1:30 PM            → "Stay controlled. Not more than 700 calories before evening."
2:00 PM            → Calorie reminder
2:30 PM            → Calorie reminder
3:00 PM            → Calorie reminder
3:30 PM            → Calorie reminder
4:00 PM            → Calorie reminder
4:30 PM            → "Go out to play. Move now."
11:00 PM           → "Start preparing to sleep. Target: before 11:50 PM."
```

---

## FOOD LOG TIME BLOCKS
```
Morning   → 12:00 AM – 1:00 PM   (timeBlock: "morning")
Afternoon → 1:00 PM  – 5:00 PM   (timeBlock: "afternoon")
Evening   → 5:00 PM  – 9:30 PM   (timeBlock: "evening")
```

---

## DISCIPLINE SCORE FORMULA
```swift
var disciplineScore: Int {
    var score = 0
    if todayWakeUp != nil { score += 34 }           // Wake-up logged
    if morningLogged || afternoonLogged || eveningLogged { score += 33 } // Food logged
    if todaySlept?.sleptOnTime == true { score += 33 } // Slept on time
    return score
}
// 0-49   → ring color: danger (#FF5C5C)  — "OFF TRACK"
// 50-79  → ring color: warning (#F5A623) — "BORDERLINE"
// 80-100 → ring color: accentTeal (#46F1CF) — "DISCIPLINED"
```

---

## REMAINING WORK — PRIORITY ORDER

### PRIORITY 1 — OpenAI API Integration
```
1. Open Utilities/Secrets.swift
2. Add: struct APIKeys { static let openAI = "YOUR_KEY_HERE" }
3. Create Services/AIAnalysisService.swift
4. Wire AIAnalysisView.swift "Analyze My Day" button to real API
5. Parse JSON response, save AIAnalysis to SwiftData
6. Show results on screen
```

### PRIORITY 2 — Real Google Sign-In
```
1. In Xcode: File → Add Package Dependencies
2. URL: https://github.com/google/GoogleSignIn-iOS
3. Add to WakeFit target
4. Create Google Cloud project, get client ID
5. Add client ID to Info.plist
6. Replace simulateLogin() in LoginView with real sign-in
```

### PRIORITY 3 — iPhone Testing
```
1. Plug iPhone into Mac via USB
2. In Xcode top bar: select your iPhone as destination
3. First time: iPhone shows "Trust This Computer?" → tap Trust
4. In Xcode: Signing → add your Apple ID → enable automatic signing
5. Press Cmd+R → app installs on real iPhone
6. Test speech-to-text (works on real device only)
7. Test notifications (works on real device only)
```

### PRIORITY 4 — UI Polish
```
For each screen, compare simulator vs Stitch PNG:
stitch_wakefit_discipline_tracker/[screen_name]/screen.png

Screens needing most polish:
- Login (button styles, spacing)
- Dashboard (card layout, streak counter)
- Food Log (section headers, entry rows)
- AI Analysis (result cards, status badge)
```

### PRIORITY 5 — Missing Features
```
- Add Sleep card to Dashboard (currently no entry point from dashboard)
- Streak counter reads consecutive days from SwiftData
- Weight graph target line + date labels
- Search results navigate to entries
- Edit target weight in ProfileView
- App icon in Assets.xcassets
- Splash screen app name styling
```

---

## HOW TO START EACH SESSION

1. Open Terminal
2. cd ~/Desktop/WakeFit
3. Type: claude
4. Paste this entire file at the start
5. Then say which PRIORITY you want to work on

## BUILD CHECK COMMAND
```bash
xcodebuild -scheme WakeFit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build 2>&1 | grep -E "error:|BUILD"
```
Run this after EVERY file change. Never move to next task until BUILD SUCCEEDED.

## FILE COUNT
Currently 26 Swift files. All screens implemented. Zero build errors.

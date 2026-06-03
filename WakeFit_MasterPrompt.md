# WakeFit — Complete Functionality Master Prompt
## Paste this entire prompt into Claude Code

---

We need to fix the entire app. Right now we have UI shells with mock data but NO real functionality. Nothing is clickable, no navigation works, no data flows anywhere. Fix everything below in order.

---

## PROBLEM 1 — Simulator is showing Mac window, not iPhone

The app is running as a Mac window instead of iPhone simulator.

Fix: In Xcode, change the run destination from "My Mac" to "iPhone 16 Pro" simulator.

Tell me how to do this step by step.

---

## PROBLEM 2 — Splash Screen

Read the splash screen design:
`stitch_wakefit_discipline_tracker/animated_splash_screen/screen.png`

Build `Views/SplashView.swift`:
- Show the WakeFit logo + tagline centered on dark navy background
- Animate: logo fades in + scales up over 0.8 seconds
- After 2.5 seconds total, transition to next screen
- No skip button needed

Update `WakeFitApp.swift` app entry logic:
```
App launches → SplashView (2.5s animation)
    ↓
AuthManager.isUserLoggedIn() == false → LoginView
AuthManager.isUserLoggedIn() == true → BiometricUnlockView → DashboardView
```

---

## PROBLEM 3 — Login Screen

Read the login design:
`stitch_wakefit_discipline_tracker/login_optimized_for_iphone_17/screen.png`

The current login screen does not match. Rebuild `LoginView.swift` to exactly match.

For now, Google Sign-In SDK is not installed. Replace the Google button action with:
```swift
// Bypass for development - simulate successful login
viewModel.simulateLogin()
```

Add `simulateLogin()` to AuthViewModel:
```swift
func simulateLogin() {
    // Marks user as logged in for UI development
    UserDefaults.standard.set(true, forKey: "isLoggedIn")
    UserDefaults.standard.set("akshatrana47@gmail.com", forKey: "userEmail")
    UserDefaults.standard.set(false, forKey: "hasCompletedSetup")
    isAuthenticated = true
    needsProfileSetup = true
}
```

This lets us tap "Continue with Google" and actually navigate into the app during development.

---

## PROBLEM 4 — Profile Setup → Dashboard Navigation

ProfileSetupView must:
1. Validate all fields are filled (name, startingWeight, targetWeight, height)
2. Show inline error messages under each empty field (not just an alert)
3. On valid submit: save User to SwiftData, call `viewModel.completeProfileSetup()`
4. `completeProfileSetup()` must set `needsProfileSetup = false` and `isAuthenticated = true`
5. This should trigger navigation to DashboardView automatically

Fix `AuthViewModel.completeProfileSetup()`:
```swift
func completeProfileSetup() {
    UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
    needsProfileSetup = false
    // isAuthenticated stays true - user lands on Dashboard
}
```

---

## PROBLEM 5 — Dashboard is not scrollable and cards don't navigate

Fix DashboardView:
1. Wrap entire content in `ScrollView` so all cards are visible on iPhone screen
2. Every card must be tappable and navigate to the correct screen:

| Card | Navigates to |
|------|-------------|
| Wake-Up card | WakeUpView |
| Food Log card | FoodLogView |
| Calories card (Analyze button) | AIAnalysisView |
| Weight card | WeightView |
| Bottom tab: Food | FoodLogView |
| Bottom tab: Weight | WeightView |
| Bottom tab: Analysis | AIAnalysisView |
| Bottom tab: Search | SearchView |

Use `NavigationStack` + `NavigationLink` or `.sheet` for navigation.
The bottom tab bar must actually switch between views.

---

## PROBLEM 6 — Missing placeholder screens

Create these placeholder screens so navigation doesn't crash:
- `Views/WakeUp/WakeUpView.swift`
- `Views/FoodLog/FoodLogView.swift`
- `Views/Sleep/SleepView.swift`
- `Views/Weight/WeightView.swift`
- `Views/AIAnalysis/AIAnalysisView.swift`
- `Views/Search/SearchView.swift`

Each placeholder should:
- Dark navy background matching design system
- Show the screen title in teal
- Show "Coming Soon" subtitle
- Have a back button to return to Dashboard

Read the corresponding Stitch PNG for each screen before building:
- `stitch_wakefit_discipline_tracker/wake_up_log/screen.png`
- `stitch_wakefit_discipline_tracker/food_log/screen.png`
- `stitch_wakefit_discipline_tracker/sleep_log/screen.png`
- `stitch_wakefit_discipline_tracker/weight_tracking/screen.png`
- `stitch_wakefit_discipline_tracker/ai_analysis/screen.png`
- `stitch_wakefit_discipline_tracker/search/screen.png`

---

## PROBLEM 7 — Complete User Journey Definition

Implement this complete if/else routing logic in WakeFitApp.swift:

```
App Launch
    ↓
Show SplashView for 2.5 seconds
    ↓
Check UserDefaults: isLoggedIn?
    ├── NO → LoginView
    │         ↓ tap "Continue with Google"
    │         simulateLogin() sets isLoggedIn = true
    │         ↓
    │         Check hasCompletedSetup?
    │             ├── NO → ProfileSetupView
    │             │         ↓ fill form + tap "Let's Begin"
    │             │         save User to SwiftData
    │             │         set hasCompletedSetup = true
    │             │         ↓
    │             │         DashboardView
    │             └── YES → DashboardView
    └── YES → BiometricPromptView (Face ID)
                  ├── Success → DashboardView
                  └── Failure/Skip → LoginView
```

---

## PROBLEM 8 — Design tokens must be in Constants.swift

Create `Utilities/Constants.swift` with ALL design tokens:

```swift
import SwiftUI

struct AppColors {
    static let bgBase = Color(hex: "051424")
    static let bgSurface = Color(hex: "0D1C2D")
    static let bgCard = Color(hex: "122131")
    static let bgCardHigh = Color(hex: "1C2B3C")
    static let accentTeal = Color(hex: "46F1CF")
    static let success = Color(hex: "00C896")
    static let warning = Color(hex: "F5A623")
    static let danger = Color(hex: "FF5C5C")
    static let textPrimary = Color(hex: "D4E4FA")
    static let textSecondary = Color(hex: "BACAC4")
    static let textMuted = Color(hex: "84948F")
    static let cardBorder = Color(hex: "3B4A45")
}

struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 40
    static let screenMargin: CGFloat = 20
}

struct AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}
```

---

## PROBLEM 9 — Build must be zero errors

After all fixes:
1. Run `xcodebuild -scheme WakeFit -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1 | grep -E "error:|warning:|BUILD"` 
2. Fix any remaining errors
3. Confirm zero errors before finishing

---

## PROBLEM 10 — Simulator must run as iPhone, not Mac

After fixes, tell me exactly how to:
1. Change simulator target to iPhone 16 Pro in Xcode
2. Run the app on iPhone simulator
3. Confirm the screen is iPhone-sized portrait mode

---

## Success Criteria

When done, tapping through the app should work like this:
1. App opens → Splash animation plays
2. Splash ends → Login screen (iPhone sized)
3. Tap "Continue with Google" → Profile Setup screen
4. Fill form → Tap "Let's Begin" → Dashboard
5. Dashboard cards are all tappable
6. Bottom tabs switch between screens
7. All screens show correct dark navy design

Do not proceed to any new features until all 10 problems above are fixed and the build is clean.

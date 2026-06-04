# WakeFit — 100 Automation Test Cases
## All screens, all scenarios, all edge cases

---

## HOW TO USE THIS FILE

Paste this into Claude Code and say:
"Read WakeFit_TestCases.md and implement all test cases 
using XCTest framework. Create one test file per screen."

---

## TEST FILE STRUCTURE TO CREATE

```
WakeFit/
└── WakeFitTests/
    ├── SplashScreenTests.swift
    ├── LoginTests.swift
    ├── ProfileSetupTests.swift
    ├── DashboardTests.swift
    ├── WakeUpTests.swift
    ├── FoodLogTests.swift
    ├── SleepTests.swift
    ├── WeightTests.swift
    ├── AIAnalysisTests.swift
    ├── NotificationTests.swift
    ├── SearchTests.swift
    ├── ProfileTests.swift
    └── NavigationTests.swift
```

---

## SCREEN 1 — SPLASH SCREEN (5 tests)

### TC001 — Splash shows on cold launch
```
Precondition: App not running
Action: Launch app
Expected: Splash screen appears immediately
Expected: "WakeFit" text visible in teal
Expected: "SYSTEM ONLINE" text visible
Pass criteria: Splash visible within 0.5 seconds of launch
```

### TC002 — Splash animation completes
```
Precondition: App launched
Action: Wait 3 seconds
Expected: Splash screen disappears after 2.5 seconds
Expected: Next screen appears (Login or Dashboard)
Pass criteria: Transition happens between 2.0s and 3.0s
```

### TC003 — Splash routes to Login when not logged in
```
Precondition: UserDefaults isLoggedIn = false
Action: Launch app, wait 3 seconds
Expected: LoginView appears after splash
Pass criteria: Login screen visible, no crash
```

### TC004 — Splash routes to Dashboard when logged in
```
Precondition: UserDefaults isLoggedIn = true, hasCompletedSetup = true
Action: Launch app, wait 3 seconds
Expected: DashboardView appears after splash
Pass criteria: Dashboard visible, no login screen shown
```

### TC005 — Splash routes to ProfileSetup when setup incomplete
```
Precondition: UserDefaults isLoggedIn = true, hasCompletedSetup = false
Action: Launch app, wait 3 seconds
Expected: ProfileSetupView appears after splash
Pass criteria: Profile setup form visible
```

---

## SCREEN 2 — LOGIN (8 tests)

### TC006 — Login screen renders correctly
```
Precondition: Not logged in
Action: Navigate to login screen
Expected: "WakeFit" title in teal (#46F1CF)
Expected: "Your discipline starts here." subtitle visible
Expected: "Continue with Google" button visible
Expected: Background is dark navy (#051424)
Pass criteria: All elements visible, no layout overflow
```

### TC007 — Google Sign-In button is tappable
```
Precondition: Login screen visible
Action: Tap "Continue with Google" button
Expected: Loading spinner appears
Expected: Google Sign-In sheet opens OR simulateLogin() fires
Pass criteria: No crash, some response within 1 second
```

### TC008 — Loading state shows during sign-in
```
Precondition: Login screen visible
Action: Tap "Continue with Google"
Expected: isLoading = true
Expected: Button opacity reduces to 0.6
Expected: Spinner visible
Pass criteria: UI reflects loading state
```

### TC009 — Successful login navigates to ProfileSetup
```
Precondition: First time user, hasCompletedSetup = false
Action: Complete Google Sign-In
Expected: isAuthenticated = true
Expected: needsProfileSetup = true
Expected: ProfileSetupView appears
Pass criteria: Profile form visible after login
```

### TC010 — Successful login navigates to Dashboard for existing user
```
Precondition: hasCompletedSetup = true
Action: Complete Google Sign-In
Expected: DashboardView appears directly
Expected: ProfileSetup NOT shown
Pass criteria: Dashboard visible after login
```

### TC011 — Login error shows error message
```
Precondition: Login screen visible
Action: Simulate login failure (no network / bad credentials)
Expected: errorMessage is set
Expected: Error alert visible to user
Expected: Loading state clears
Pass criteria: User sees error, can retry
```

### TC012 — UserDefaults set correctly after login
```
Precondition: Login screen visible
Action: Complete successful login
Expected: UserDefaults "isLoggedIn" = true
Expected: UserDefaults "userEmail" is set
Expected: UserDefaults "userName" is set
Pass criteria: All 3 keys correctly set
```

### TC013 — Login screen not shown when already logged in
```
Precondition: isLoggedIn = true in UserDefaults
Action: Launch app
Expected: Login screen never appears
Expected: App goes directly to Dashboard or Face ID
Pass criteria: Login screen bypassed
```

---

## SCREEN 3 — PROFILE SETUP (10 tests)

### TC014 — Profile setup renders all 4 fields
```
Precondition: First login, hasCompletedSetup = false
Action: Navigate to ProfileSetupView
Expected: Full Name field visible
Expected: Starting Weight field visible
Expected: Target Weight field visible
Expected: Height field visible
Expected: "Let's Begin" button visible
Pass criteria: All fields rendered
```

### TC015 — Empty name shows validation error
```
Precondition: Profile setup visible
Action: Leave name empty, tap "Let's Begin"
Expected: Name error message appears below field
Expected: "Please enter your full name" or similar
Expected: Navigation does NOT proceed
Pass criteria: Inline error shown, no navigation
```

### TC016 — Invalid weight shows validation error
```
Precondition: Profile setup visible
Action: Enter "abc" in Starting Weight field, tap submit
Expected: Weight error message appears
Expected: Navigation does NOT proceed
Pass criteria: Inline error shown
```

### TC017 — Zero weight rejected
```
Precondition: Profile setup visible
Action: Enter "0" in Starting Weight, tap submit
Expected: Validation error shown
Expected: "Enter a valid weight" message
Pass criteria: Zero value rejected
```

### TC018 — Negative weight rejected
```
Precondition: Profile setup visible
Action: Enter "-5" in weight field
Expected: Validation error shown
Pass criteria: Negative value rejected
```

### TC019 — Valid form saves User to SwiftData
```
Precondition: Profile setup visible
Action: Enter name="Akshat", weight="85", target="75", height="178"
Action: Tap "Let's Begin"
Expected: User model saved to SwiftData
Expected: User.name = "Akshat"
Expected: User.startingWeight = 85.0
Expected: User.targetWeight = 75.0
Expected: User.height = 178.0
Pass criteria: SwiftData contains correct User record
```

### TC020 — Profile setup sets hasCompletedSetup = true
```
Precondition: Profile setup visible
Action: Submit valid form
Expected: UserDefaults "hasCompletedSetup" = true
Pass criteria: UserDefaults correctly updated
```

### TC021 — Profile setup triggers notification permission
```
Precondition: Profile setup visible
Action: Submit valid form
Expected: iOS notification permission dialog appears
Pass criteria: Permission dialog shown (or already granted)
```

### TC022 — Profile setup navigates to Dashboard on success
```
Precondition: Profile setup visible
Action: Submit valid form
Expected: DashboardView appears
Expected: Profile setup NOT visible
Pass criteria: Dashboard shown after setup
```

### TC023 — Progress bar shows 100% filled
```
Precondition: Profile setup visible
Action: View screen
Expected: Progress bar is fully filled in teal
Expected: "STEP 1 OF 1" label visible
Pass criteria: Visual progress indicator correct
```

---

## SCREEN 4 — DASHBOARD (12 tests)

### TC024 — Dashboard shows all 6 cards
```
Precondition: Logged in, setup complete
Action: Navigate to Dashboard
Expected: Discipline score ring visible
Expected: Wake-Up card visible
Expected: Food Log card visible
Expected: Calories card visible
Expected: Weight card visible
Expected: Streak counter visible
Pass criteria: All 6 components rendered
```

### TC025 — Discipline score ring correct color for high score
```
Precondition: Wake-up logged + food logged + slept on time
Action: View Dashboard
Expected: Score = 100
Expected: Ring color = teal (#46F1CF)
Expected: "DISCIPLINED" label
Pass criteria: Correct color and score
```

### TC026 — Discipline score ring amber for medium score
```
Precondition: Only wake-up logged (score = 34 + 33 base = 67)
Action: View Dashboard
Expected: Ring color = amber (#F5A623)
Expected: "BORDERLINE" label
Pass criteria: Amber ring shown
```

### TC027 — Discipline score ring red for low score
```
Precondition: Nothing logged today
Action: View Dashboard
Expected: Score = 33 (base only)
Expected: Ring color = red (#FF5C5C)
Expected: "OFF TRACK" label
Pass criteria: Red ring shown
```

### TC028 — Wake-Up card shows "Log Now" when not logged
```
Precondition: No WakeUpEntry for today
Action: View Dashboard
Expected: "Log Now" button visible in teal
Expected: Wake-up time NOT shown
Pass criteria: Correct empty state
```

### TC029 — Wake-Up card shows time when logged
```
Precondition: WakeUpEntry exists for today at 6:42 AM
Action: View Dashboard
Expected: "Wake-up logged: 6:42 AM" visible
Expected: "Log Now" button NOT visible
Pass criteria: Correct logged state
```

### TC030 — Food badges show correct completion
```
Precondition: Morning FoodLog exists, no afternoon/evening
Action: View Dashboard
Expected: Morning badge = teal with checkmark
Expected: Afternoon badge = gray with X
Expected: Evening badge = gray with X
Pass criteria: 3 badges show correct states
```

### TC031 — Calories card shows analysis when exists
```
Precondition: AIAnalysis exists for today with estimatedCalories=1840
Action: View Dashboard
Expected: "~1,840 kcal estimated today" visible
Expected: "ANALYZE MY DAY" button NOT visible
Pass criteria: Calories displayed from AI analysis
```

### TC032 — Calories card shows Analyze button when no analysis
```
Precondition: No AIAnalysis for today
Action: View Dashboard
Expected: "ANALYZE MY DAY" button visible in teal
Expected: Calorie count NOT shown
Pass criteria: Correct empty state
```

### TC033 — Weight card shows current weight
```
Precondition: WeightEntry exists with weight=84.2
Action: View Dashboard
Expected: "84.2 kg" visible on weight card
Pass criteria: Current weight displayed
```

### TC034 — Dashboard greeting changes by time
```
Precondition: Morning time (5AM-12PM)
Action: View Dashboard
Expected: "Good morning, [name]" shown
Precondition: Afternoon (12PM-5PM)
Expected: "Good afternoon, [name]"
Precondition: Evening (5PM+)
Expected: "Good evening, [name]"
Pass criteria: Dynamic greeting correct
```

### TC035 — All bottom tabs are tappable
```
Precondition: Dashboard visible
Action: Tap each bottom tab (Food, Weight, Analysis, Search)
Expected: Each tab navigates to correct screen
Expected: Active tab highlighted in teal
Expected: Inactive tabs in gray
Pass criteria: All 5 tabs functional
```

---

## SCREEN 5 — WAKE-UP LOG (7 tests)

### TC036 — WakeUpView shows current time by default
```
Precondition: Navigate to WakeUpView
Action: View time picker
Expected: Time picker shows current time (within 1 minute)
Pass criteria: Default time is accurate
```

### TC037 — Use Current Time button sets picker to now
```
Precondition: WakeUpView visible, time picker showing old time
Action: Tap "Use Current Time"
Expected: Time picker updates to current time
Pass criteria: Time updates on button tap
```

### TC038 — Save creates WakeUpEntry in SwiftData
```
Precondition: WakeUpView visible
Action: Set time to 7:30 AM, tap save
Expected: WakeUpEntry created in SwiftData
Expected: WakeUpEntry.wakeUpTime = 7:30 AM
Expected: WakeUpEntry.date = today
Pass criteria: SwiftData record created
```

### TC039 — Second save updates existing entry
```
Precondition: WakeUpEntry already exists for today
Action: Log wake-up again with different time
Expected: Existing entry UPDATED (not duplicate created)
Expected: Only 1 WakeUpEntry for today
Pass criteria: No duplicate entries
```

### TC040 — History list shows past entries
```
Precondition: 5 WakeUpEntries exist for past 5 days
Action: View WakeUpView
Expected: History list shows 5 rows
Expected: Each row shows date + time
Pass criteria: All past entries visible
```

### TC041 — Success confirmation shows after save
```
Precondition: WakeUpView visible
Action: Tap save
Expected: "✓ Logged!" confirmation appears
Expected: Confirmation disappears after 2 seconds
Pass criteria: Visual feedback shown
```

### TC042 — Dashboard updates after wake-up logged
```
Precondition: Dashboard showing "Log Now"
Action: Log wake-up time, go back to Dashboard
Expected: Dashboard shows logged time
Expected: Discipline score increases by 34 points
Pass criteria: Dashboard reflects new data
```

---

## SCREEN 6 — FOOD LOG (8 tests)

### TC043 — Food log shows 3 time block sections
```
Precondition: Navigate to FoodLogView
Action: View screen
Expected: Morning section visible (12AM-1PM)
Expected: Afternoon section visible (1PM-5PM)
Expected: Evening section visible (5PM-9:30PM)
Pass criteria: All 3 sections rendered
```

### TC044 — Add food button opens bottom sheet
```
Precondition: FoodLogView visible
Action: Tap "Add Food" in any section
Expected: AddFoodItemView slides up as bottom sheet
Expected: Time block label shows correct block
Pass criteria: Bottom sheet opens
```

### TC045 — Food entry saves to correct time block
```
Precondition: AddFoodItemView open for "morning" block
Action: Type "2 eggs and toast", tap Save
Expected: FoodLog created with timeBlock="morning"
Expected: Entry appears in Morning section
Expected: NOT in Afternoon or Evening
Pass criteria: Correct time block assignment
```

### TC046 — Empty food text shows validation error
```
Precondition: AddFoodItemView open
Action: Leave text empty, tap Save
Expected: "Please enter what you ate" error shown
Expected: Sheet does NOT dismiss
Pass criteria: Validation prevents empty save
```

### TC047 — Swipe to delete removes entry
```
Precondition: FoodLog entry exists
Action: Swipe left on entry, tap Delete
Expected: Entry removed from list
Expected: Entry deleted from SwiftData
Pass criteria: Entry gone after delete
```

### TC048 — Entry count badge updates correctly
```
Precondition: Morning section has 0 entries
Action: Add 3 entries to morning section
Expected: Morning badge shows "3"
Pass criteria: Count updates in real time
```

### TC049 — Food entries persist after app restart
```
Precondition: Add 3 food entries
Action: Kill app, relaunch
Expected: All 3 entries still visible
Pass criteria: SwiftData persistence works
```

### TC050 — Entries show correct timestamp
```
Precondition: Add food entry at 2:30 PM
Action: View entry in list
Expected: Entry shows "2:30 PM" timestamp
Pass criteria: Time displayed correctly
```

---

## SCREEN 7 — ADD FOOD + SPEECH TO TEXT (6 tests)

### TC051 — Mic button requests permission on first tap
```
Precondition: First time using mic, no permission granted
Action: Tap mic button
Expected: iOS permission dialog appears
Expected: "WakeFit uses microphone..." message shown
Pass criteria: Permission dialog triggered
```

### TC052 — Mic button shows recording animation
```
Precondition: Microphone permission granted
Action: Tap mic button
Expected: isRecording = true
Expected: Pulsing red animation visible
Expected: "Tap to stop" label shown
Pass criteria: Visual recording state correct
```

### TC053 — Tapping mic again stops recording
```
Precondition: Recording in progress
Action: Tap mic button again
Expected: isRecording = false
Expected: Animation stops
Expected: "Or tap to speak" label returns
Pass criteria: Toggle works correctly
```

### TC054 — Save button disabled when text empty
```
Precondition: AddFoodItemView open, no text entered
Action: View save button
Expected: Save button shows gray background
Expected: Save button not tappable
Pass criteria: Disabled state correct
```

### TC055 — Save button enabled when text exists
```
Precondition: AddFoodItemView open, text entered
Action: Type "chicken rice bowl"
Expected: Save button turns teal
Expected: Save button tappable
Pass criteria: Enabled state correct
```

### TC056 — Sheet dismisses after save
```
Precondition: AddFoodItemView open with text
Action: Tap Save
Expected: Bottom sheet dismisses
Expected: Food entry appears in FoodLogView
Pass criteria: Sheet closes and entry saved
```

---

## SCREEN 8 — SLEEP LOG (6 tests)

### TC057 — Sleep log shows two toggle cards
```
Precondition: Navigate to SleepView
Action: View screen
Expected: "Yes, before 11:50 PM" card visible
Expected: "No, I stayed up late" card visible
Expected: Both cards unselected (gray border)
Pass criteria: Both cards rendered
```

### TC058 — Selecting Yes highlights card in teal
```
Precondition: SleepView visible
Action: Tap "Yes, before 11:50 PM" card
Expected: Card background turns teal
Expected: "No" card turns gray
Expected: sleptOnTime = true
Pass criteria: Correct selection state
```

### TC059 — Selecting No highlights card in red
```
Precondition: SleepView visible
Action: Tap "No, I stayed up late" card
Expected: Card background turns red/coral
Expected: "Yes" card turns gray
Expected: sleptOnTime = false
Pass criteria: Correct selection state
```

### TC060 — Save button disabled with no selection
```
Precondition: SleepView visible, nothing selected
Action: View save button
Expected: Save button disabled or grayed out
Pass criteria: Cannot save without selection
```

### TC061 — Sleep entry saves to SwiftData
```
Precondition: SleepView visible
Action: Select "Yes", add note "Slept well", tap Save
Expected: SleepEntry created in SwiftData
Expected: SleepEntry.sleptOnTime = true
Expected: SleepEntry.notes = "Slept well"
Pass criteria: SwiftData record correct
```

### TC062 — 7-day history dots show correct colors
```
Precondition: 7 SleepEntries exist (5 on time, 2 late)
Action: View SleepView history
Expected: 5 green dots (on time)
Expected: 2 red dots (late)
Pass criteria: History dots match records
```

---

## SCREEN 9 — AI ANALYSIS (8 tests)

### TC063 — Empty state shows when no food logged
```
Precondition: No FoodLog entries for today
Action: Navigate to AIAnalysisView
Expected: Empty state message visible
Expected: "No food logged today" or similar
Expected: "Go Log Food" button visible
Pass criteria: Correct empty state
```

### TC064 — Analyze button visible when food logged
```
Precondition: At least 1 FoodLog for today
Action: Navigate to AIAnalysisView
Expected: "ANALYZE MY DAY" button visible in teal
Expected: Today's food list shown as preview
Pass criteria: Analyze button appears with food
```

### TC065 — Loading state shows during API call
```
Precondition: Food logged, tap Analyze
Action: Tap "ANALYZE MY DAY"
Expected: isAnalyzing = true
Expected: Skeleton loading cards visible
Expected: "Analyzing your day..." text shown
Pass criteria: Loading state appears immediately
```

### TC066 — API call uses correct OpenAI endpoint
```
Precondition: APIKeys.openAI is set
Action: Tap Analyze
Expected: POST request to https://api.openai.com/v1/chat/completions
Expected: Authorization header = "Bearer [key]"
Expected: Model = "gpt-4o"
Pass criteria: Correct API call made
```

### TC067 — Results display all 6 fields
```
Precondition: API returns successful response
Action: Wait for analysis to complete
Expected: Calories card shows estimatedCalories
Expected: Protein card shows estimatedProtein
Expected: Discipline status badge visible
Expected: Coach diagnosis text visible
Expected: Tomorrow's advice text visible
Expected: Risk areas visible
Pass criteria: All 6 fields displayed
```

### TC068 — Discipline status badge correct color
```
Precondition: API returns disciplineStatus="Disciplined"
Expected: Badge color = teal (#46F1CF)

Precondition: disciplineStatus="Borderline"
Expected: Badge color = amber (#F5A623)

Precondition: disciplineStatus="Off Track"
Expected: Badge color = red (#FF5C5C)
Pass criteria: Badge matches status
```

### TC069 — Analysis saved to SwiftData
```
Precondition: API call successful
Action: Analysis completes
Expected: AIAnalysis record in SwiftData
Expected: All 6 fields correctly saved
Expected: AIAnalysis.date = today
Pass criteria: SwiftData record created
```

### TC070 — Error shows when API call fails
```
Precondition: Invalid API key or no network
Action: Tap Analyze
Expected: Error message visible
Expected: "Check your API key in Secrets.swift"
Expected: isAnalyzing = false
Expected: Retry option available
Pass criteria: Error handled gracefully
```

---

## SCREEN 10 — WEIGHT TRACKING (7 tests)

### TC071 — Weight view shows stat cards
```
Precondition: User has startingWeight=85, current weight entry=82
Action: Navigate to WeightView
Expected: Starting weight card shows "85 kg"
Expected: Current weight card shows "82 kg"
Expected: Change card shows "-3 kg" in green
Pass criteria: All 3 stat cards correct
```

### TC072 — Weight loss shown in green
```
Precondition: currentWeight < startingWeight
Action: View weight change card
Expected: Change value shown in green (#00C896)
Expected: Downward arrow icon
Pass criteria: Green color for loss
```

### TC073 — Weight gain shown in red
```
Precondition: currentWeight > startingWeight
Action: View weight change card
Expected: Change value shown in red (#FF5C5C)
Expected: Upward arrow icon
Pass criteria: Red color for gain
```

### TC074 — Log weight sheet opens on button tap
```
Precondition: WeightView visible
Action: Tap "Log Today's Weight"
Expected: Input sheet slides up
Expected: Number input field focused
Pass criteria: Sheet opens
```

### TC075 — Invalid weight rejected
```
Precondition: Log weight sheet open
Action: Enter "abc" or "0" or "-5"
Expected: Validation error shown
Expected: Save button disabled
Pass criteria: Invalid values rejected
```

### TC076 — Valid weight saves to SwiftData
```
Precondition: Log weight sheet open
Action: Enter "82.5", tap Save
Expected: WeightEntry created in SwiftData
Expected: WeightEntry.weight = 82.5
Expected: WeightEntry.date = today
Expected: Stat cards update immediately
Pass criteria: SwiftData record created
```

### TC077 — Graph shows all weight entries
```
Precondition: 10 WeightEntries exist over 10 days
Action: View WeightView graph
Expected: Graph line connects all 10 points
Expected: X-axis shows dates
Expected: Y-axis shows weight values
Pass criteria: All entries plotted
```

---

## NOTIFICATIONS (5 tests)

### TC078 — Permission requested after profile setup
```
Precondition: First time completing profile setup
Action: Submit valid profile setup form
Expected: iOS notification permission dialog appears
Pass criteria: Permission dialog shown
```

### TC079 — All 10 notifications scheduled
```
Precondition: Notification permission granted
Action: Complete profile setup
Expected: 10 pending notifications in UNUserNotificationCenter
Expected: Correct identifiers for each notification
Pass criteria: Exactly 10 notifications scheduled
```

### TC080 — Wake-up notification at 7:30 AM
```
Precondition: Notifications scheduled
Action: Check scheduled notifications
Expected: Notification with hour=7, minute=30
Expected: Body = "Clock in your wake-up time."
Expected: Repeats daily
Pass criteria: Correct time and message
```

### TC081 — Sleep notification at 11:00 PM
```
Precondition: Notifications scheduled
Action: Check scheduled notifications
Expected: Notification with hour=23, minute=0
Expected: Body contains "preparing to sleep"
Pass criteria: Correct time and message
```

### TC082 — Calorie notifications at correct times
```
Precondition: Notifications scheduled
Action: Check scheduled notifications
Expected: Notifications at 13:30, 14:00, 14:30, 15:00, 15:30, 16:00, 16:30
Expected: 7 calorie-related notifications total
Pass criteria: All 7 calorie notifications scheduled
```

---

## SCREEN 12 — SEARCH (5 tests)

### TC083 — Search returns food log results
```
Precondition: FoodLog entry with text "chicken rice" exists
Action: Type "chicken" in search bar
Expected: Entry appears in results
Expected: Date and time block shown
Pass criteria: Correct search result
```

### TC084 — Search is case insensitive
```
Precondition: FoodLog entry "Chicken Rice" exists
Action: Type "chicken" (lowercase)
Expected: Entry appears in results
Pass criteria: Case insensitive match
```

### TC085 — Empty search shows recent entries
```
Precondition: Multiple food entries exist
Action: Navigate to Search, leave search bar empty
Expected: Recent entries visible (last 10)
Pass criteria: Default state shows recent entries
```

### TC086 — No results shows empty state
```
Precondition: No matching entries
Action: Type "xyznotfound" in search bar
Expected: "No results for 'xyznotfound'" message
Pass criteria: Empty state shown
```

### TC087 — Segment switch changes search scope
```
Precondition: Search screen visible
Action: Switch to "Weight" segment
Expected: Only weight entries shown in results
Action: Switch to "Food" segment
Expected: Only food logs shown
Pass criteria: Segment filter works
```

---

## SCREEN 13 — PROFILE / SETTINGS (5 tests)

### TC088 — Profile shows correct user info
```
Precondition: User model exists with name="Akshat", email="test@gmail.com"
Action: Navigate to ProfileView
Expected: "Akshat" name visible
Expected: "test@gmail.com" email visible
Expected: Start date visible
Expected: Days active count correct
Pass criteria: User data displayed correctly
```

### TC089 — Notification toggle updates UserDefaults
```
Precondition: ProfileView visible
Action: Toggle notification switch off
Expected: UserDefaults "notificationsEnabled" = false
Action: Toggle notification switch on
Expected: UserDefaults "notificationsEnabled" = true
Pass criteria: Toggle updates UserDefaults
```

### TC090 — Face ID toggle updates UserDefaults
```
Precondition: ProfileView visible
Action: Toggle Face ID switch
Expected: UserDefaults "faceIDEnabled" updates
Pass criteria: Toggle works correctly
```

### TC091 — Sign out clears UserDefaults
```
Precondition: User logged in
Action: Tap Sign Out, confirm alert
Expected: UserDefaults "isLoggedIn" = false
Expected: UserDefaults "hasCompletedSetup" = false
Expected: UserDefaults "userEmail" = nil
Expected: UserDefaults "userName" = nil
Pass criteria: All keys cleared
```

### TC092 — Sign out navigates to Login
```
Precondition: User logged in
Action: Tap Sign Out, confirm
Expected: LoginView appears
Expected: Dashboard NOT accessible
Pass criteria: Correct navigation after sign out
```

---

## NAVIGATION TESTS (8 tests)

### TC093 — Back navigation works from all screens
```
Precondition: Navigate to WakeUpView, FoodLogView, WeightView, AIAnalysisView
Action: Tap back button on each screen
Expected: Returns to Dashboard each time
Pass criteria: Back works on all 4 screens
```

### TC094 — Bottom tab Home returns to Dashboard
```
Precondition: On FoodLogView via tab
Action: Tap Home tab
Expected: DashboardView visible
Expected: Home tab highlighted in teal
Pass criteria: Home tab navigation works
```

### TC095 — Deep navigation stack clears on tab switch
```
Precondition: Dashboard → WakeUpView (2 levels deep)
Action: Tap Food tab
Expected: FoodLogView shown (not WakeUpView)
Expected: Navigation stack reset for new tab
Pass criteria: Tab switch clears stack
```

### TC096 — No orphaned navigation states
```
Precondition: Navigate through multiple screens
Action: Rapidly tap different tabs and back buttons
Expected: App never shows blank screen
Expected: No crash
Expected: Always on a valid screen
Pass criteria: Navigation state always valid
```

### TC097 — Sign out from deep navigation
```
Precondition: User on ProfileView (Dashboard → Profile)
Action: Tap Sign Out
Expected: LoginView shown
Expected: No back button to Dashboard
Pass criteria: Full stack cleared on sign out
```

### TC098 — Dashboard card navigation correct
```
Precondition: Dashboard visible
Action: Tap WakeUpCard
Expected: WakeUpView opens
Action: Go back, tap FoodLogCard
Expected: FoodLogView opens
Action: Go back, tap WeightCard
Expected: WeightView opens
Action: Go back, tap CaloriesCard
Expected: AIAnalysisView opens
Pass criteria: All 4 cards navigate correctly
```

### TC099 — App recovers from background
```
Precondition: App on Dashboard
Action: Press home button (app backgrounds)
Action: Reopen app
Expected: App resumes on Dashboard (if faceID disabled)
Expected: Face ID prompt if faceID enabled
Pass criteria: Background/foreground works correctly
```

### TC100 — No data loss on app restart
```
Precondition: Add wake-up entry, food entries, weight entry
Action: Kill app completely, relaunch
Expected: All entries still exist in SwiftData
Expected: Dashboard shows all data
Expected: No data wiped on restart
Pass criteria: SwiftData persistence confirmed
```

---

## HOW TO IMPLEMENT IN CLAUDE CODE

Paste this prompt into Claude Code:

```
Read WakeFit_TestCases.md completely.

Create XCTest unit and UI test files for all 100 test cases.
Organize into test files per screen as specified at the top.

For each test:
1. Use XCTest framework
2. Use @MainActor for SwiftData tests
3. Use in-memory ModelContainer for SwiftData tests:
   let container = try ModelContainer(
       for: User.self, WakeUpEntry.self, ...,
       configurations: ModelConfiguration(isStoredInMemoryOnly: true)
   )
4. Mock UserDefaults using a separate suite:
   UserDefaults(suiteName: "test")
5. Assert exact values, not just non-nil

After creating all test files run:
xcodebuild test -scheme WakeFit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  2>&1 | grep -E "passed|failed|error"

Report how many tests pass and which fail.
Fix all failures before reporting done.
```

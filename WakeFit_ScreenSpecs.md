# WakeFit — Complete Screen Specifications
## All 13 screens with data keys, if/else logic, and acceptance criteria

---

## CURRENT STATE ASSESSMENT

The app currently:
- ✅ Shows Dashboard with mock data
- ✅ Bottom tabs switch screens
- ❌ No splash screen animation
- ❌ Login button does nothing (no simulateLogin())
- ❌ Profile setup not saving or navigating
- ❌ No real data flowing anywhere
- ❌ ProfileSetupView has build errors (keyboardType)

Fix all of this screen by screen using the specs below.

---

## SCREEN 1 — Animated Splash Screen

**File:** `Views/SplashView.swift`
**Triggered by:** App launch, always shown first

### Data Keys
```swift
// No SwiftData needed
// UserDefaults read AFTER animation completes:
UserDefaults.standard.bool(forKey: "isLoggedIn")        // Bool
UserDefaults.standard.bool(forKey: "hasCompletedSetup") // Bool
```

### UI Elements
- Full screen dark navy background (#051424)
- "WakeFit" text in electric teal (#46F1CF), size 56, bold
- "• SYSTEM ONLINE" text below, size 14, monospaced, teal with opacity animation
- Subtle pulsing dot before text

### Animation Sequence
```
0.0s  → opacity 0, scale 0.8
0.0s  → animate to opacity 1.0, scale 1.0 (duration: 0.8s, easeOut)
0.8s  → "SYSTEM ONLINE" text fades in (duration: 0.4s)
2.5s  → navigate to next screen
```

### If/Else Navigation After Splash
```
isLoggedIn == false
    → LoginView

isLoggedIn == true AND hasCompletedSetup == false
    → ProfileSetupView

isLoggedIn == true AND hasCompletedSetup == true
    → BiometricPromptView (Face ID) → DashboardView
```

### Acceptance Criteria
- [ ] Animation plays every time app opens
- [ ] Exactly 2.5 seconds before navigating
- [ ] Navigates to correct screen based on UserDefaults
- [ ] No login screen shown if already logged in

---

## SCREEN 2 — Login Screen

**File:** `Views/Auth/LoginView.swift`
**Triggered by:** Splash → isLoggedIn == false

### Data Keys Written on Login
```swift
UserDefaults.standard.set(true, forKey: "isLoggedIn")
UserDefaults.standard.set("user@email.com", forKey: "userEmail")
UserDefaults.standard.set("User Name", forKey: "userName")
UserDefaults.standard.set(false, forKey: "hasCompletedSetup")
```

### UI Elements (match Stitch design exactly)
- Full screen dark navy background (#051424)
- "WakeFit" title, size 56, bold, teal (#46F1CF), centered
- "Your discipline starts here." subtitle, size 18, #D4E4FA
- Google Sign-In button: white pill, globe icon, "CONTINUE WITH GOOGLE"
- Apple Sign-In button: dark pill with border, apple.logo icon, "CONTINUE WITH APPLE"

### Button Actions (Development Mode - No SDK needed)
```swift
// Google button tapped:
func simulateGoogleLogin() {
    UserDefaults.standard.set(true, forKey: "isLoggedIn")
    UserDefaults.standard.set("akshatrana47@gmail.com", forKey: "userEmail")
    UserDefaults.standard.set("Akshat", forKey: "userName")
    UserDefaults.standard.set(false, forKey: "hasCompletedSetup")
    isAuthenticated = true
    needsProfileSetup = true
}

// Apple button tapped:
// Same as Google for now
```

### If/Else Conditions
```
Button tapped AND isLoading == false
    → set isLoading = true
    → call simulateGoogleLogin()
    → set isLoading = false
    → needsProfileSetup == true → navigate to ProfileSetupView
    → needsProfileSetup == false → navigate to DashboardView
```

### Acceptance Criteria
- [ ] Tapping "Continue with Google" navigates to ProfileSetupView
- [ ] Loading spinner shows while processing
- [ ] Dark navy background matches Stitch design
- [ ] No crash on button tap

---

## SCREEN 3 — Profile Setup

**File:** `Views/Auth/ProfileSetupView.swift`
**Triggered by:** Login → hasCompletedSetup == false

### Form Fields & Validation
```swift
// Input fields:
@State var fullName: String = ""          // Required, min 2 chars
@State var startingWeight: String = ""    // Required, Double > 0, max 300
@State var targetWeight: String = ""      // Required, Double > 0, max 300
@State var height: String = ""            // Required, Double > 0, max 250

// Validation errors (shown inline under each field):
@State var nameError: String = ""
@State var startWeightError: String = ""
@State var targetWeightError: String = ""
@State var heightError: String = ""
```

### Validation Rules
```swift
// Name:
if fullName.trimmingCharacters(in: .whitespaces).count < 2 {
    nameError = "Please enter your full name"
}

// Starting weight:
guard let w = Double(startingWeight), w > 0, w < 300 else {
    startWeightError = "Enter a valid weight (kg)"
}

// Target weight:
guard let t = Double(targetWeight), t > 0, t < 300 else {
    targetWeightError = "Enter a valid target weight (kg)"
}

// Height:
guard let h = Double(height), h > 0, h < 250 else {
    heightError = "Enter a valid height (cm)"
}
```

### On Valid Submit
```swift
// 1. Create and save User to SwiftData:
let user = User(
    name: fullName.trimmingCharacters(in: .whitespaces),
    email: UserDefaults.standard.string(forKey: "userEmail") ?? "",
    startingWeight: Double(startingWeight)!,
    targetWeight: Double(targetWeight)!,
    height: Double(height)!,
    startDate: Date()
)
modelContext.insert(user)
try? modelContext.save()

// 2. Update UserDefaults:
UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
UserDefaults.standard.set(Double(startingWeight)!, forKey: "startingWeight")
UserDefaults.standard.set(Double(targetWeight)!, forKey: "targetWeight")

// 3. Navigate to Dashboard:
viewModel.needsProfileSetup = false
```

### CRITICAL: No .keyboardType() on TextField in Swift 6
```swift
// WRONG — causes build error in Xcode 26/Swift 6:
TextField("85", text: $startingWeight)
    .keyboardType(.decimalPad)

// CORRECT — use UITextContentType instead:
TextField("85", text: $startingWeight)
    .textContentType(.telephoneNumber) // triggers numeric keyboard without error
// OR simply omit keyboard type entirely — works fine for now
```

### Acceptance Criteria
- [ ] All 4 fields show inline error messages when empty
- [ ] "Let's Begin" button disabled until all fields valid
- [ ] User saved to SwiftData on submit
- [ ] Navigates to DashboardView after submit
- [ ] No build errors (NO .keyboardType() usage)

---

## SCREEN 4 — Dashboard (Home)

**File:** `Views/Dashboard/DashboardView.swift`
**Triggered by:** After profile setup OR splash → already logged in

### SwiftData Queries
```swift
@Query var wakeUpEntries: [WakeUpEntry]    // All wake-up logs
@Query var foodLogs: [FoodLog]             // All food logs
@Query var weightEntries: [WeightEntry]    // All weight entries
@Query var aiAnalyses: [AIAnalysis]        // All AI analyses
@Query var users: [User]                   // User profile
```

### Computed Properties
```swift
// Today's date (start of day):
var today: Date { Calendar.current.startOfDay(for: Date()) }

// Today's wake-up entry:
var todayWakeUp: WakeUpEntry? {
    wakeUpEntries.first { Calendar.current.isDateInToday($0.date) }
}

// Today's food logs by time block:
var todayFoodLogs: [FoodLog] {
    foodLogs.filter { Calendar.current.isDateInToday($0.date) }
}
var morningLogged: Bool { todayFoodLogs.contains { $0.timeBlock == "morning" } }
var afternoonLogged: Bool { todayFoodLogs.contains { $0.timeBlock == "afternoon" } }
var eveningLogged: Bool { todayFoodLogs.contains { $0.timeBlock == "evening" } }

// Latest weight:
var currentWeight: Double? { weightEntries.sorted { $0.date > $1.date }.first?.weight }

// Today's AI analysis:
var todayAnalysis: AIAnalysis? {
    aiAnalyses.first { Calendar.current.isDateInToday($0.date) }
}

// Days since start:
var daysSinceStart: Int {
    guard let user = users.first else { return 0 }
    return Calendar.current.dateComponents([.day], from: user.startDate, to: Date()).day ?? 0
}

// Discipline score (0-100):
var disciplineScore: Int {
    var score = 0
    if todayWakeUp != nil { score += 34 }    // Wake-up logged
    if morningLogged || afternoonLogged || eveningLogged { score += 33 } // Food logged
    // Sleep check would add 33 — for now based on above two
    return min(score + 33, 100) // Base 33 for showing up
}

// User's first name:
var userName: String {
    users.first?.name.components(separatedBy: " ").first ?? 
    UserDefaults.standard.string(forKey: "userName") ?? "Akshat"
}

// Greeting based on time:
var greeting: String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 5..<12: return "Good morning"
    case 12..<17: return "Good afternoon"
    default: return "Good evening"
    }
}
```

### Card If/Else States

**Wake-Up Card:**
```
todayWakeUp != nil
    → show "Wake-up logged: [time]" in teal
    → alarm icon filled teal
todayWakeUp == nil
    → show "Log Now" button in teal
    → alarm icon gray
```

**Food Log Card:**
```
morningLogged == true  → Morning badge: teal background, checkmark
morningLogged == false → Morning badge: gray border, X

afternoonLogged == true  → Afternoon badge: teal background, checkmark
afternoonLogged == false → Afternoon badge: gray border, X

eveningLogged == true  → Evening badge: teal background, checkmark
eveningLogged == false → Evening badge: gray border, X
```

**Calories Card:**
```
todayAnalysis != nil
    → show "~[estimatedCalories] kcal estimated today"
    → show protein: "[estimatedProtein]g protein"
todayAnalysis == nil
    → show "ANALYZE MY DAY" button → navigates to AIAnalysisView
```

**Weight Card:**
```
currentWeight != nil
    → show "[weight] kg"
    → compare to previous entry: show ↑ ↓ → arrow
currentWeight == nil
    → show "—" placeholder
    → show "Log Weight" button
```

**Discipline Score Ring:**
```
score 80-100 → ring color: #46F1CF (teal) — "DISCIPLINED"
score 50-79  → ring color: #F5A623 (amber) — "BORDERLINE"
score 0-49   → ring color: #FF5C5C (red) — "OFF TRACK"
```

### Navigation (All must work)
```swift
NavigationLink(destination: WakeUpView()) { WakeUpCard }
NavigationLink(destination: FoodLogView()) { FoodLogCard }
NavigationLink(destination: WeightView()) { WeightCard }
NavigationLink(destination: AIAnalysisView()) { CaloriesCard }
// Bottom tabs:
.food    → FoodLogView()
.weight  → WeightView()
.analysis → AIAnalysisView()
.search  → SearchView()
```

### Acceptance Criteria
- [ ] Shows real data from SwiftData (not mock data)
- [ ] All cards tappable and navigate correctly
- [ ] Bottom tabs all work
- [ ] Discipline score calculates correctly
- [ ] Greeting changes based on time of day
- [ ] Scrollable — all cards visible

---

## SCREEN 5 — Wake-Up Log

**File:** `Views/WakeUp/WakeUpView.swift`

### Data Keys
```swift
@Query var wakeUpEntries: [WakeUpEntry]  // All entries, sorted by date desc
@State var selectedTime: Date = Date()   // Time picker value
@State var showSaved: Bool = false       // Success feedback
```

### SwiftData Operations
```swift
// Save wake-up:
func logWakeUp() {
    // Check if already logged today:
    let alreadyLogged = wakeUpEntries.contains {
        Calendar.current.isDateInToday($0.date)
    }
    if alreadyLogged {
        // Update existing entry
        if let existing = wakeUpEntries.first(where: {
            Calendar.current.isDateInToday($0.date)
        }) {
            existing.wakeUpTime = selectedTime
        }
    } else {
        // Create new entry
        let entry = WakeUpEntry(
            date: Calendar.current.startOfDay(for: Date()),
            wakeUpTime: selectedTime
        )
        modelContext.insert(entry)
    }
    try? modelContext.save()
    showSaved = true
}
```

### If/Else States
```
todayEntry != nil → show "Already logged: [time]" + option to update
todayEntry == nil → show time picker + "Log Wake-Up" button

showSaved == true → show "✓ Logged!" green confirmation for 2 seconds
```

### Acceptance Criteria
- [ ] Time picker shows current time by default
- [ ] "Use Current Time" button sets picker to now
- [ ] Saves to SwiftData
- [ ] Shows history of past wake-up entries
- [ ] Dashboard updates after logging

---

## SCREEN 6 — Food Log

**File:** `Views/FoodLog/FoodLogView.swift`

### Data Keys
```swift
@Query var foodLogs: [FoodLog]
@State var selectedDate: Date = Date()
@State var showAddSheet: Bool = false
@State var activeTimeBlock: String = ""  // "morning", "afternoon", "evening"
```

### Time Block Logic
```swift
// Determine current active block:
var currentTimeBlock: String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 0..<13: return "morning"     // 12:00 AM – 1:00 PM
    case 13..<17: return "afternoon"  // 1:00 PM – 5:00 PM
    default: return "evening"         // 5:00 PM – 9:30 PM
    }
}

// Logs for selected date and block:
func logsFor(block: String) -> [FoodLog] {
    foodLogs.filter {
        Calendar.current.isDate($0.date, inSameDayAs: selectedDate) &&
        $0.timeBlock == block
    }
    .sorted { $0.entryTime < $1.entryTime }
}
```

### Add Food Entry
```swift
func saveFoodEntry(text: String, timeBlock: String) {
    guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
    let entry = FoodLog(
        date: Calendar.current.startOfDay(for: selectedDate),
        timeBlock: timeBlock,
        foodText: text,
        entryTime: Date()
    )
    modelContext.insert(entry)
    try? modelContext.save()
}

// Delete entry:
func deleteEntry(_ entry: FoodLog) {
    modelContext.delete(entry)
    try? modelContext.save()
}
```

### If/Else States
```
logsFor(block:).isEmpty
    → show "No entries yet. Tap + to add food."
logsFor(block:).count > 0
    → show list of entries with timestamp + swipe to delete

showAddSheet == true
    → present AddFoodItemView as sheet with activeTimeBlock
```

### Acceptance Criteria
- [ ] 3 sections: Morning, Afternoon, Evening
- [ ] Each section expandable/collapsible
- [ ] Add button opens bottom sheet
- [ ] Swipe to delete entries
- [ ] Date selector to view past days
- [ ] Entries persist in SwiftData

---

## SCREEN 7 — Add Food Item (Bottom Sheet)

**File:** `Views/FoodLog/AddFoodItemView.swift`

### Data Keys
```swift
@State var foodText: String = ""           // Text input
@State var isRecording: Bool = false       // Mic active
@State var showEmptyError: Bool = false    // Validation
var timeBlock: String                      // Passed in from FoodLogView
var onSave: (String) -> Void              // Callback to parent
```

### If/Else States
```
isRecording == false
    → show text input field
    → show microphone button (gray)

isRecording == true
    → show pulsing red circle animation
    → show "Recording... tap to stop" text
    → microphone button red/pulsing

foodText.isEmpty AND save tapped
    → showEmptyError = true
    → show "Please enter what you ate" below field

foodText.count > 0
    → Save button enabled (teal)
```

### Save Logic
```swift
func save() {
    let trimmed = foodText.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else {
        showEmptyError = true
        return
    }
    onSave(trimmed)
    dismiss()
}
```

### Acceptance Criteria
- [ ] Opens as bottom sheet from FoodLogView
- [ ] Text field auto-focuses on open
- [ ] Save button disabled when empty
- [ ] Dismisses after saving
- [ ] Shows which time block entry is for

---

## SCREEN 8 — Sleep Log

**File:** `Views/Sleep/SleepView.swift`

### Data Keys
```swift
@Query var sleepEntries: [SleepEntry]
@State var sleptOnTime: Bool? = nil   // nil = not selected yet
@State var notes: String = ""
@State var showSaved: Bool = false
```

### Save Logic
```swift
func saveSleepEntry() {
    guard let onTime = sleptOnTime else { return }
    
    // Check if already logged today:
    if let existing = sleepEntries.first(where: {
        Calendar.current.isDateInToday($0.date)
    }) {
        existing.sleptOnTime = onTime
        existing.notes = notes
    } else {
        let entry = SleepEntry(
            date: Calendar.current.startOfDay(for: Date()),
            sleptOnTime: onTime,
            notes: notes
        )
        modelContext.insert(entry)
    }
    try? modelContext.save()
    showSaved = true
}
```

### If/Else States
```
sleptOnTime == nil
    → both cards unselected (gray border)
    → Save button disabled

sleptOnTime == true
    → "Yes, before 11:50 PM" card: teal background, checkmark
    → "No, stayed up late" card: gray

sleptOnTime == false
    → "No, stayed up late" card: red/coral background
    → "Yes" card: gray

showSaved == true
    → show "✓ Sleep logged" confirmation
```

### Acceptance Criteria
- [ ] Two large toggle cards
- [ ] Exactly one can be selected at a time
- [ ] Notes field optional
- [ ] Shows 7-day sleep history as dots below form
- [ ] Saves to SwiftData

---

## SCREEN 9 — AI Analysis

**File:** `Views/AIAnalysis/AIAnalysisView.swift`

### Data Keys
```swift
@Query var foodLogs: [FoodLog]
@Query var aiAnalyses: [AIAnalysis]
@State var isAnalyzing: Bool = false
@State var errorMessage: String? = nil

// Secrets (DO NOT hardcode):
// Read from Secrets.swift: APIKeys.openAI
```

### Today's Food Logs for Prompt
```swift
var todayFoodText: String {
    let todayLogs = foodLogs.filter { 
        Calendar.current.isDateInToday($0.date) 
    }
    if todayLogs.isEmpty { return "No food logged today." }
    return todayLogs.map { "[\($0.timeBlock)] \($0.foodText)" }.joined(separator: "\n")
}
```

### If/Else States
```
todayAnalysis != nil
    → show all result cards (calories, protein, status, diagnosis, advice)
    → show "Re-analyze" button at bottom

todayAnalysis == nil AND todayFoodLogs.isEmpty
    → show empty state: "No food logged today"
    → show "Go Log Food" button → navigates to FoodLogView

todayAnalysis == nil AND todayFoodLogs.count > 0
    → show "Analyze My Day" large teal button
    → show list of today's food logs as preview

isAnalyzing == true
    → show skeleton loading cards with shimmer effect
    → show "Analyzing your day..." text

errorMessage != nil
    → show error card with retry button
```

### AI API Call (Modular - plug in key later)
```swift
func analyzeDay() async {
    isAnalyzing = true
    // Read key from Secrets.swift
    // POST to OpenAI with prompt from CLAUDE.md
    // Parse JSON response
    // Save AIAnalysis to SwiftData
    isAnalyzing = false
}
```

### Discipline Status Display
```
"Disciplined"  → large teal pill badge
"Borderline"   → large amber pill badge
"Off Track"    → large red pill badge
```

### Acceptance Criteria
- [ ] Shows empty state when no food logged
- [ ] "Analyze My Day" button triggers API call
- [ ] Loading state with skeleton cards
- [ ] Results persist in SwiftData
- [ ] Re-analyze option available

---

## SCREEN 10 — Weight Tracking

**File:** `Views/Weight/WeightView.swift` + `Views/Weight/WeightGraphView.swift`

### Data Keys
```swift
@Query var weightEntries: [WeightEntry]
@Query var users: [User]
@State var newWeight: String = ""
@State var showLogSheet: Bool = false
@State var showSaved: Bool = false
```

### Computed Properties
```swift
var currentWeight: Double? { 
    weightEntries.sorted { $0.date > $1.date }.first?.weight 
}
var startingWeight: Double? { users.first?.startingWeight }
var targetWeight: Double? { users.first?.targetWeight }
var totalChange: Double? {
    guard let current = currentWeight, let start = startingWeight else { return nil }
    return current - start
}
// Positive = gained, Negative = lost
```

### Save Weight
```swift
func saveWeight() {
    guard let w = Double(newWeight), w > 0, w < 300 else { return }
    let entry = WeightEntry(date: Date(), weight: w)
    modelContext.insert(entry)
    try? modelContext.save()
    showSaved = true
    newWeight = ""
}
```

### Graph Spec
```swift
// X-axis: dates of weight entries
// Y-axis: weight values in kg
// Line: teal color (#46F1CF), dots at each entry
// Dashed line: target weight (horizontal)
// Show min 7 data points, scroll for more
```

### If/Else States
```
weightEntries.isEmpty
    → show "No weight logged yet"
    → show "Log Your Weight" button

weightEntries.count > 0
    → show stat cards: Starting | Current | Change
    → show line graph
    → show "Log Today's Weight" button

totalChange < 0
    → show change in green (lost weight)
totalChange > 0
    → show change in red (gained weight)
totalChange == 0
    → show change in gray (no change)
```

### Acceptance Criteria
- [ ] Graph shows all weight entries
- [ ] Target weight shown as dashed line
- [ ] Stat cards show starting/current/change
- [ ] Log sheet slides up from bottom
- [ ] Saves to SwiftData immediately

---

## SCREEN 11 — Notification Overlay

**File:** Handled by `Services/NotificationManager.swift`
**Not a full screen — system notification + in-app banner**

### Notification Schedule (from CLAUDE.md)
```swift
func scheduleAllNotifications() {
    // 7:30 AM daily - Wake up reminder
    schedule(hour: 7, minute: 30, 
             title: "WakeFit", 
             body: "Clock in your wake-up time.",
             identifier: "wakeup-daily")
    
    // Every 5th day 7:30 AM - Weight reminder
    // (Use calendar trigger with day component)
    
    // 1:30 PM - Calorie control
    schedule(hour: 13, minute: 30,
             title: "Stay Controlled",
             body: "Not more than 700 calories before evening.",
             identifier: "calorie-1300")
    
    // 2:00 PM through 4:00 PM - 30 min intervals
    for minute in stride(from: 0, through: 60, by: 30) {
        schedule(hour: 14 + (minute / 60), 
                 minute: minute % 60,
                 title: "Calorie Check",
                 body: "Stay disciplined. Track what you eat.",
                 identifier: "calorie-\(14)-\(minute)")
    }
    
    // 4:30 PM
    schedule(hour: 16, minute: 30,
             title: "Move Now",
             body: "Go out to play. Move now.",
             identifier: "calorie-1630")
    
    // 11:00 PM - Sleep reminder
    schedule(hour: 23, minute: 0,
             title: "Sleep Protocol",
             body: "Start preparing to sleep. Target: before 11:50 PM.",
             identifier: "sleep-daily")
}
```

### Acceptance Criteria
- [ ] Request notification permission on first launch
- [ ] All 10 notifications scheduled
- [ ] Notifications fire at correct times
- [ ] Tapping notification opens correct screen

---

## SCREEN 12 — Search

**File:** `Views/Search/SearchView.swift`

### Data Keys
```swift
@Query var foodLogs: [FoodLog]
@Query var weightEntries: [WeightEntry]
@Query var wakeUpEntries: [WakeUpEntry]
@State var searchText: String = ""
@State var selectedSegment: SearchSegment = .food

enum SearchSegment { case food, weight, notes }
```

### Search Logic
```swift
var filteredFoodLogs: [FoodLog] {
    guard !searchText.isEmpty else { return foodLogs }
    return foodLogs.filter { 
        $0.foodText.localizedCaseInsensitiveContains(searchText) 
    }
}

var filteredWeightEntries: [WeightEntry] {
    guard !searchText.isEmpty else { return weightEntries }
    // Filter by date string
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return weightEntries.filter {
        formatter.string(from: $0.date).localizedCaseInsensitiveContains(searchText)
    }
}
```

### If/Else States
```
searchText.isEmpty
    → show "Search your logs..." placeholder
    → show recent entries (last 10) for active segment

searchText.count > 0 AND results.isEmpty
    → show "No results for '[searchText]'"

searchText.count > 0 AND results.count > 0
    → show filtered list
```

### Acceptance Criteria
- [ ] Real-time search as user types
- [ ] 3 segments: Food, Weight, Notes
- [ ] Results show date + content
- [ ] Tap result navigates to relevant screen

---

## SCREEN 13 — Profile / Settings

**File:** `Views/Auth/ProfileSetupView.swift` (reuse) or new `ProfileView.swift`

### Data Keys
```swift
@Query var users: [User]
@State var showSignOutAlert: Bool = false
@State var editingTargetWeight: Bool = false
@State var newTargetWeight: String = ""
```

### Settings Items
```swift
// Toggles stored in UserDefaults:
UserDefaults.standard.bool(forKey: "notificationsEnabled")  // Bool
UserDefaults.standard.bool(forKey: "faceIDEnabled")         // Bool

// Editable:
users.first?.targetWeight  // Double, editable inline
```

### Sign Out Logic
```swift
func signOut() {
    UserDefaults.standard.set(false, forKey: "isLoggedIn")
    UserDefaults.standard.set(false, forKey: "hasCompletedSetup")
    UserDefaults.standard.removeObject(forKey: "userEmail")
    UserDefaults.standard.removeObject(forKey: "userName")
    // Navigate back to LoginView via AuthViewModel
    viewModel.isAuthenticated = false
}
```

### Acceptance Criteria
- [ ] Shows user name, email, start date
- [ ] Stats: days active, total food entries, weight entries
- [ ] Notification toggle works
- [ ] Face ID toggle works
- [ ] Sign out clears UserDefaults and goes to LoginView

---

## GLOBAL DATA FLOW

```
UserDefaults (session state):
├── isLoggedIn: Bool
├── hasCompletedSetup: Bool
├── userEmail: String
├── userName: String
├── faceIDEnabled: Bool
└── notificationsEnabled: Bool

SwiftData (persistent data):
├── User (1 record max)
├── WakeUpEntry (1 per day)
├── SleepEntry (1 per day)
├── FoodLog (multiple per day)
├── WeightEntry (1 per 5 days ideally)
└── AIAnalysis (1 per day)
```

## CRITICAL BUILD RULES FOR SWIFT 6 / XCODE 26

1. NEVER use `.keyboardType()` on TextField — causes build error
2. NEVER use `.foregroundColor()` — use `.foregroundStyle()` instead
3. NEVER use `@Published` in `@Observable` classes — use plain properties
4. ALWAYS use `try? modelContext.save()` after SwiftData inserts
5. ALWAYS use `.buttonStyle(PlainButtonStyle())` on NavigationLink cards

---

## BUILD ORDER FOR CLAUDE CODE

Fix in this exact order:
1. Fix ProfileSetupView build errors (remove keyboardType, use foregroundStyle)
2. Add simulateLogin() to AuthViewModel
3. Wire SplashView → LoginView → ProfileSetupView → DashboardView
4. Connect Dashboard to real SwiftData queries (remove all mock data)
5. Build WakeUpView with real save/load
6. Build FoodLogView + AddFoodItemView with real save/load
7. Build SleepView with real save/load
8. Build WeightView + graph with real save/load
9. Set up NotificationManager with all 10 notifications
10. Build AI Analysis with OpenAI API (modular key)
11. Build SearchView with real queries
12. Build ProfileView with sign out
13. Final build check — zero errors

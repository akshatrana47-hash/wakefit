# WakeFit — UI Bug Fix Prompt
## Paste this entire prompt into Claude Code

I have tested the app on a real iPhone and found these bugs.
Fix ALL of them in order. Run build check after each fix.

---

## BUG 1 — "Settings" back button showing on every screen

Every screen shows "◀ Settings" in the top left corner.
This is a system navigation bar leaking through.

Fix: Add these modifiers to EVERY NavigationStack in the app:
```swift
.navigationBarBackButtonHidden(true)
.toolbar(.hidden, for: .navigationBar)
```

Also in WakeFitApp.swift add to the root view:
```swift
.toolbarBackground(.hidden, for: .navigationBar)
```

Files to fix:
- WakeFitApp.swift
- DashboardView.swift
- FoodLogView.swift
- WeightView.swift
- WakeUpView.swift
- SleepView.swift
- AIAnalysisView.swift
- SearchView.swift
- ProfileView.swift
- ProfileSetupView.swift

---

## BUG 2 — Profile Setup "STEP 1 OF 1" overlaps status bar

The progress bar and "STEP 1 OF 1" text is going behind 
the iPhone status bar (time/battery area).

Fix: Add `.padding(.top, 60)` to the top of the 
ScrollView content in ProfileSetupView.swift
OR use `.safeAreaInset(edge: .top)` padding

---

## BUG 3 — Weight showing in lbs instead of kg

Weight card on Dashboard shows "189.6 lbs" 
but the app stores weight in kg.

Fix in WeightView.swift:
- Remove ALL kg to lbs conversion
- Display weight directly in kg
- Change all "lbs" labels to "kg"
- Starting weight 86 kg should show as "86 kg" NOT "189.6 lbs"

Fix in DashboardView.swift weight card:
- Show weight in kg not lbs

---

## BUG 4 — "Day 0" showing on weight card

Dashboard weight card shows "Day 0" instead of actual 
days since the user started.

Fix in DashboardView.swift:
```swift
var daysSinceStart: Int {
    guard let user = users.first else { return 0 }
    let calendar = Calendar.current
    let components = calendar.dateComponents(
        [.day], 
        from: calendar.startOfDay(for: user.startDate),
        to: calendar.startOfDay(for: Date())
    )
    return max(0, components.day ?? 0)
}
```
If user just signed up today, show "Day 1" not "Day 0".
Change: `return max(1, components.day ?? 1)`

---

## BUG 5 — Score shows 33 on fresh app start

New user with nothing logged shows score 33.
This is wrong — a user who has done nothing should show 0.

Fix the discipline score formula in DashboardView.swift:
```swift
var disciplineScore: Int {
    var score = 0
    if todayWakeUp != nil { score += 34 }
    if morningLogged || afternoonLogged || eveningLogged { 
        score += 33 
    }
    if todaySlept?.sleptOnTime == true { score += 33 }
    return score
    // Remove the base 33 points — earn them don't get them free
}
```
New user = 0 score. Score only increases when actions taken.

---

## BUG 6 — Food badges show wrong state

Dashboard food card shows "Morning X" even when morning 
food HAS been logged. The X means not logged but it should 
show checkmark when logged.

Fix in DashboardView.swift FoodLogCard:
```swift
// The badge should show:
// ✓ with teal background when that block has entries
// ✗ with gray background when no entries

var morningLogged: Bool {
    foodLogs.contains { 
        Calendar.current.isDateInToday($0.date) && 
        $0.timeBlock == "morning" 
    }
}
// Same for afternoon and evening

// Badge display:
// morningLogged == true → teal border, "Morning ✓"
// morningLogged == false → gray border, "Morning ✗"
```

---

## BUG 7 — No edit or delete on food entries

User cannot edit or delete a logged food entry in FoodLogView.

Fix in FoodLogView.swift:
Add swipe actions to each food entry row:
```swift
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) {
        deleteEntry(entry)
    } label: {
        Label("Delete", systemImage: "trash")
    }
    
    Button {
        editingEntry = entry
        editText = entry.foodText
        showEditSheet = true
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    .tint(AppColors.accentTeal)
}
```

Add edit sheet:
```swift
@State var editingEntry: FoodLog? = nil
@State var editText: String = ""
@State var showEditSheet: Bool = false

// Edit sheet saves updated text back to SwiftData
func saveEdit() {
    editingEntry?.foodText = editText
    try? modelContext.save()
    showEditSheet = false
}
```

---

## BUG 8 — Weight screen empty below button

WeightView shows stat cards and "Log Today's Weight" button
but the rest of the screen is empty black space.
The weight graph is missing or not rendering.

Fix in WeightView.swift:
1. If no weight entries exist: show empty state message
   "No weight entries yet. Log your first weight above."
2. If entries exist: show the graph
3. Make sure the graph component is actually being called
4. Check if weightEntries array has data before rendering graph

---

## BUG 9 — "TOTAL..." text cut off in weight stat card

The "TOTAL CHANGE" label is being truncated to "TOTAL..."
in the weight stat card.

Fix in WeightView.swift:
Change the label text from "TOTAL CHANGE" to just "CHANGE"
Or make the card wider
Or reduce font size to 10pt for the label:
```swift
Text("CHANGE")
    .font(.system(size: 10, weight: .medium))
    .foregroundStyle(AppColors.textMuted)
```

---

## BUG 10 — Screen content not filling full iPhone screen

There is still a gap at the top of some screens where
the status bar area shows black instead of the app 
background color.

Fix in EVERY view — make sure the background uses:
```swift
ZStack {
    AppColors.bgBase
        .ignoresSafeArea(.all)  // Must be .all not just .top
    
    // content here
}
```

Check these files specifically:
- ProfileSetupView.swift (worst offender)
- WeightView.swift
- FoodLogView.swift

---

## BUG 11 — Weight stored in wrong unit

When user enters weight in Profile Setup as "86" (kg),
it is being saved correctly but displayed as lbs elsewhere.

Fix: Ensure weight is ALWAYS stored and displayed in kg.
Remove any unit conversion code.
Search for "* 2.20462" or "lbs" in ALL files and remove.

---

## AFTER ALL FIXES:

Run full build check:
```bash
xcodebuild -scheme WakeFit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build 2>&1 | grep -E "error:|BUILD"
```

Then list every file changed and confirm BUILD SUCCEEDED.

Fix bugs in this order:
1. BUG 1 (Settings bar) — affects every screen
2. BUG 3 (lbs vs kg) — data integrity issue  
3. BUG 5 (Score 33) — wrong initial state
4. BUG 6 (Food badges) — wrong logic
5. BUG 4 (Day 0) — calculation fix
6. BUG 7 (Edit/Delete food) — missing feature
7. BUG 2 (Progress bar overlap) — layout fix
8. BUG 8 (Empty weight screen) — missing graph
9. BUG 9 (TOTAL... truncated) — text fix
10. BUG 10 (Screen filling) — safe area fix
11. BUG 11 (Weight unit) — data fix

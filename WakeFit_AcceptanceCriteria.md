# WakeFit — Bug Fix Acceptance Criteria
## How to verify each fix is working on real iPhone

---

## HOW TO TEST

After Claude Code says fixes are done:
1. Press Cmd+R in Xcode to build and install on iPhone
2. Go through each acceptance criteria below
3. Mark ✅ if passing, ❌ if still failing
4. Report back which ones failed

---

## FIX 1 — Back Button on All Screens

### Test Steps:
1. From Dashboard tap Wake Up card
2. On WakeUpView — look for back button top left
3. Tap back button
4. Should return to Dashboard

Repeat for:
- Weight screen (tap Weight card from Dashboard)
- Sleep screen
- AI Analysis screen
- Search screen

### Acceptance Criteria:
- [ ] WakeUpView has "< Back" button top left in teal
- [ ] Tapping back returns to Dashboard
- [ ] WeightView has "< Back" button top left in teal
- [ ] Tapping back returns to Dashboard
- [ ] SleepView has "< Back" button
- [ ] AIAnalysisView has "< Back" button
- [ ] SearchView has "< Back" button
- [ ] No screen traps the user with no way out
- [ ] Back button color matches teal (#46F1CF)

---

## FIX 2 — "Settings" Text Gone From All Screens

### Test Steps:
1. Open app
2. Go through every single screen
3. Check top left corner of every screen

### Acceptance Criteria:
- [ ] Login screen — NO "Settings" or "< Back" text at top
- [ ] Profile Setup — NO system navigation text at top
- [ ] Dashboard — NO "Settings" text at top left
- [ ] WakeUp screen — NO "Settings" text (only our custom back button)
- [ ] Food Log — NO "Settings" text
- [ ] Weight screen — NO "Settings" text
- [ ] AI Analysis — NO "Settings" text
- [ ] Search — NO "Settings" text
- [ ] Profile/Settings screen — NO "Settings" text
- [ ] ZERO screens show system navigation bar text

---

## FIX 3 — Splash Screen Animation

### Test Steps:
1. Close app completely (swipe up from home screen)
2. Tap WakeFit icon to open
3. Watch what happens in first 3 seconds

### Acceptance Criteria:
- [ ] Dark navy background shows immediately
- [ ] "WakeFit" text in teal fades in from transparent to visible
- [ ] "WakeFit" text scales up from small to normal size during fade
- [ ] Animation takes approximately 0.8 seconds
- [ ] After logo appears, "• SYSTEM ONLINE" text fades in
- [ ] Total splash duration is approximately 2.5 seconds
- [ ] After 2.5 seconds automatically moves to Login or Dashboard
- [ ] No white flash or black flash during transition
- [ ] Animation is smooth, not jumpy

---

## FIX 4 — Settings/Gear Icon Opens Profile

### Test Steps:
1. Go to Dashboard
2. Tap the gear icon (⚙️) in top right corner

### Acceptance Criteria:
- [ ] Tapping gear icon opens ProfileView
- [ ] ProfileView shows user name
- [ ] ProfileView shows user email
- [ ] No crash when tapping gear icon
- [ ] Can navigate back from ProfileView to Dashboard

---

## FIX 5 — Logout Works

### Test Steps:
1. Go to Profile/Settings screen
2. Scroll to bottom
3. Find "Sign Out" button (should be red text)
4. Tap it

### Acceptance Criteria:
- [ ] "Sign Out" button visible in red/danger color
- [ ] Tapping shows confirmation alert: "Are you sure you want to sign out?"
- [ ] Alert has two options: "Sign Out" (red) and "Cancel"
- [ ] Tapping Cancel — nothing happens, stays on profile
- [ ] Tapping "Sign Out" — navigates to Login screen
- [ ] After sign out, tapping back does NOT go to Dashboard
- [ ] After sign out, reopening app shows Login screen (not Dashboard)
- [ ] All user session data cleared (UserDefaults wiped)

---

## FIX 6 — Edit and Delete Food Entries

### Test Steps:
1. Go to Food Log
2. Add a food entry (e.g. "scrambled eggs")
3. Swipe LEFT on the entry

### Acceptance Criteria:
- [ ] Swiping left reveals two buttons: "Delete" (red) and "Edit" (teal)
- [ ] Tapping Delete — shows confirmation OR immediately removes entry
- [ ] Entry is gone from the list after delete
- [ ] Entry is gone after app restart (SwiftData deleted)
- [ ] Tapping Edit — opens a sheet/modal with the food text pre-filled
- [ ] Can modify the text in edit sheet
- [ ] Tapping Save in edit sheet — updates the entry text
- [ ] Updated text shows immediately in the food list
- [ ] Updated text persists after app restart

---

## FIX 7 — Edit and Delete Wake-Up Entries

### Test Steps:
1. Go to Wake Up Log screen
2. Log a wake-up time
3. Look at the history list
4. Swipe left on a history entry

### Acceptance Criteria:
- [ ] Swiping left on history entry reveals Delete button
- [ ] Tapping Delete removes the entry from history
- [ ] Entry gone after app restart
- [ ] Tapping an entry in history opens edit option (time picker)
- [ ] Can change the time of a past wake-up entry
- [ ] Updated time saves correctly

---

## FIX 8 — Profile Picture and Edit Name

### Test Steps:
1. Go to Profile/Settings screen
2. Look at the profile header area

### Acceptance Criteria:
- [ ] Profile header shows a circle with user's initials (e.g. "A" for Akshat)
- [ ] Circle has teal color scheme matching app design
- [ ] Small camera icon visible on the circle (bottom right)
- [ ] Tapping the circle OR a camera icon does something 
      (opens photo picker OR shows "coming soon" message)
- [ ] "Edit Profile" button visible somewhere on the screen
- [ ] Tapping "Edit Profile" opens a sheet
- [ ] Sheet has a text field pre-filled with current name
- [ ] Can type new name
- [ ] Tapping Save updates the name
- [ ] New name shows immediately in profile header
- [ ] New name shows in Dashboard greeting after returning

---

## FIX 9 — Weight in KG Not LBS

### Test Steps:
1. During Profile Setup enter starting weight as "86"
2. Complete setup and go to Dashboard
3. Check weight card
4. Go to Weight screen
5. Check all weight displays

### Acceptance Criteria:
- [ ] Dashboard weight card shows "86 kg" NOT "189.6 lbs"
- [ ] Weight screen "Starting" stat card shows "86 kg"
- [ ] Weight screen "Current" stat card shows kg
- [ ] Weight screen "Change" stat card shows kg
- [ ] Log weight sheet accepts kg input
- [ ] After logging "82" it shows "82 kg" everywhere
- [ ] NO "lbs" text anywhere in the app
- [ ] NO conversion factors (2.20462) applied anywhere

---

## FIX 10 — Score Starts at 0

### Test Steps:
1. Sign out completely
2. Sign in fresh as new user
3. Complete profile setup
4. Go to Dashboard without logging anything

### Acceptance Criteria:
- [ ] Fresh user with nothing logged shows score = 0
- [ ] Score ring shows red color at score 0
- [ ] After logging wake-up: score increases to 34
- [ ] After logging food: score increases to 67
- [ ] After marking sleep on time: score reaches 100
- [ ] Score never starts above 0 automatically
- [ ] "OFF TRACK" label shown at score 0-49
- [ ] "BORDERLINE" label shown at score 50-79
- [ ] "DISCIPLINED" label shown at score 80-100

---

## FIX 11 — Days Since Start Shows Correctly

### Test Steps:
1. Check Dashboard weight card bottom right
2. Look for "Day X" text

### Acceptance Criteria:
- [ ] First day of using app shows "Day 1" (NOT "Day 0")
- [ ] Second day shows "Day 2"
- [ ] "Day" counter increments correctly each day
- [ ] After 14 days shows "Day 14"
- [ ] Shows correct number based on profile startDate

---

## FIX 12 — No Black Bars on Any Screen

### Test Steps:
Go through every single screen on real iPhone:
Splash → Login → Profile Setup → Dashboard → 
WakeUp → Food Log → Add Food → Sleep → 
AI Analysis → Weight → Search → Profile

### Acceptance Criteria:
- [ ] Splash screen — dark navy fills entire screen top to bottom
- [ ] Login screen — dark navy fills entire screen, no black bar top/bottom
- [ ] Profile Setup — dark navy fills entire screen
- [ ] Dashboard — dark navy fills behind status bar area
- [ ] WakeUp Log — dark navy fills entire screen
- [ ] Food Log — dark navy fills entire screen
- [ ] Add Food sheet — dark surface fills sheet completely
- [ ] Sleep Log — dark navy fills entire screen
- [ ] AI Analysis — dark navy fills entire screen
- [ ] Weight screen — dark navy fills entire screen
- [ ] Search — dark navy fills entire screen
- [ ] Profile — dark navy fills entire screen
- [ ] Bottom tab bar blends into dark background
- [ ] Status bar text (time, battery) shows WHITE not black
- [ ] NO black bars at top OR bottom on ANY screen

---

## OVERALL APP FLOW TEST

After all fixes, test the complete user journey:

### Full Journey Acceptance Criteria:
- [ ] App opens → Splash animation plays (2.5 seconds)
- [ ] Splash ends → Login screen appears (full screen, no black bars)
- [ ] Tap "Continue with Google" → Profile Setup appears
- [ ] Fill name, weights, height → Tap "Let's Begin" → Dashboard
- [ ] Dashboard shows score 0 on first visit
- [ ] Dashboard shows "Day 1" on first visit
- [ ] Dashboard shows "Log Now" on Wake Up card
- [ ] Tap Wake Up card → WakeUpView opens with back button
- [ ] Log wake-up time → Dashboard score increases to 34
- [ ] Tap Food tab → FoodLogView opens
- [ ] Add food entry → morning badge shows checkmark on Dashboard
- [ ] Tap Analysis → shows food logged, "Analyze My Day" button visible
- [ ] Tap gear icon → ProfileView opens
- [ ] Tap Sign Out → confirmation → back to Login
- [ ] Reopen app → Login shows (not Dashboard)
- [ ] ZERO crashes during entire journey

---

## HOW TO REPORT RESULTS

After testing paste this into Claude Code:

"I tested all acceptance criteria. Here are the results:
- FIX 1 (Back button): PASS / FAIL — [what happened]
- FIX 2 (Settings text): PASS / FAIL — [what happened]
- FIX 3 (Splash animation): PASS / FAIL — [what happened]
- FIX 4 (Gear icon): PASS / FAIL — [what happened]
- FIX 5 (Logout): PASS / FAIL — [what happened]
- FIX 6 (Edit/delete food): PASS / FAIL — [what happened]
- FIX 7 (Edit/delete wakeup): PASS / FAIL — [what happened]
- FIX 8 (Profile picture): PASS / FAIL — [what happened]
- FIX 9 (Weight in kg): PASS / FAIL — [what happened]
- FIX 10 (Score starts 0): PASS / FAIL — [what happened]
- FIX 11 (Day 1 not 0): PASS / FAIL — [what happened]
- FIX 12 (No black bars): PASS / FAIL — [what happened]

Please fix everything marked FAIL."

# WakeFit Discipline Tracker — Google Stitch UI Prompt

## Paste this entire prompt into Google Stitch

---

Design a complete iOS mobile app called **WakeFit Discipline Tracker**.

This is a personal discipline and health tracking app for one user. The tone is motivational, clean, and focused — like a strict personal coach in your pocket. Not playful. Not corporate. Disciplined and minimal.

---

## Design Language

- **Style:** Dark mode first. Deep navy/charcoal backgrounds. Sharp, clean cards.
- **Accent color:** Electric teal (#00D4B4) for primary actions, streaks, and positive states
- **Warning color:** Amber (#F5A623) for calorie reminders and borderline discipline
- **Danger color:** Coral red (#FF5C5C) for off-track states
- **Success color:** Teal green (#00C896) for disciplined states
- **Typography:** SF Pro Display for headings, SF Pro Text for body (standard iOS fonts)
- **Cards:** Rounded corners (16px), subtle border, dark surface (#1C1F2E)
- **Background:** Deep navy (#0D0F1A) base
- **No gradients on text.** Clean flat surfaces only.
- **Bottom tab navigation** with 5 tabs: Home, Food, Weight, Analysis, Search

---

## Screens to Design (12 total)

---

### Screen 1 — Login Screen
- Full screen dark background
- App name "WakeFit" large centered, subtitle "Your discipline starts here."
- Google Sign-In button (white pill button, Google logo + "Continue with Google")
- Minimal — nothing else on this screen

---

### Screen 2 — Profile Setup (First Login Only)
- Title: "Set your baseline"
- Form fields (dark input cards):
  - Full Name
  - Starting Weight (kg)
  - Target Weight (kg)
  - Height (cm)
- Progress indicator at top (step 1 of 1)
- "Let's Begin" CTA button in teal at bottom

---

### Screen 3 — Dashboard (Home Screen)
This is the most important screen. Show all of these as cards:

**Top section:**
- Date and greeting: "Good morning, Akshat"
- Discipline Score for today: large circular ring/score (0–100), color changes green/amber/red based on score

**Card row 1 — Wake Up:**
- "Wake-up logged" with the time (e.g. 6:42 AM) OR a "Log Now" teal button if not logged yet
- Small alarm icon

**Card row 2 — Food Log:**
- 3 small pill badges: Morning ✓ / Afternoon ✗ / Evening ✗
- Tap to go to food log

**Card row 3 — Calories:**
- "~1,840 kcal estimated today" if AI analysis exists
- "Analyze My Day" button if not yet analyzed

**Card row 4 — Weight:**
- Current weight (e.g. 84.2 kg)
- Small trend arrow (up/down/flat)
- Days since start (e.g. "Day 14")

**Bottom:** streak counter — "🔥 6 day streak"

---

### Screen 4 — Wake-Up Log Screen
- Title: "Log Your Wake-Up"
- Large time display in center (current time, tappable)
- Time picker wheel below it
- Two buttons: "Use Current Time" (teal) and "Save Entry" (filled teal)
- Below: scrollable history list — each row shows date + wake-up time logged
- Each history row has a small checkmark or clock icon

---

### Screen 5 — Food Log Screen
- Title: "Today's Food Log"
- Date selector at top (swipe left/right for different days)
- 3 expandable sections as cards:
  - **Morning** (12:00 AM – 1:00 PM)
  - **Afternoon** (1:00 PM – 5:00 PM)
  - **Evening** (5:00 PM – 9:30 PM)
- Each section shows:
  - Time block label + entry count badge
  - List of food entries (text, timestamp)
  - "Add Food" button at bottom of each section (teal + icon)
  - Swipe left on entry to delete

---

### Screen 6 — Add Food Item Screen (Modal/Sheet)
- Appears as bottom sheet over Food Log screen
- Title: "Add Food Entry"
- Large text input area: "What did you eat?"
- Below input: microphone button (large, teal circle) with label "Or tap to speak"
- "Recording..." animated state when mic is active (pulsing red circle)
- Transcribed text appears in input field automatically
- "Save Entry" button at bottom

---

### Screen 7 — Sleep Log Screen
- Title: "Sleep Check-In"
- Large question: "Did you sleep on time last night?"
- Two large toggle cards:
  - ✓ "Yes, before 11:50 PM" (teal when selected)
  - ✗ "No, I stayed up late" (coral when selected)
- Notes field below: "Any notes? (optional)"
- "Save" button
- Below: last 7 days sleep history as a small row of circles (green = on time, red = missed)

---

### Screen 8 — AI Analysis Screen
- Title: "Today's Diagnosis"
- Date at top
- If analysis exists, show result cards:
  - **Calories card:** large number, e.g. "~2,100 kcal" with label
  - **Protein card:** e.g. "~85g protein"
  - **Discipline Status badge:** large pill — "Disciplined" (teal) / "Borderline" (amber) / "Off Track" (red)
  - **Coach Diagnosis:** card with coach icon, 2-3 sentence text
  - **Tomorrow's Advice:** card with different icon, 1-2 sentence text
  - **Risk Areas:** small warning card with amber accent
- If no analysis yet: centered empty state with "Analyze My Day" large teal button
- Loading state: skeleton cards with shimmer while AI is thinking

---

### Screen 9 — Weight Tracking Screen
- Title: "Weight Progress"
- Top stat row (3 cards side by side):
  - Starting weight
  - Current weight
  - Total lost/gained (with arrow)
- Large line graph below:
  - X-axis: dates
  - Y-axis: weight in kg
  - Teal line with dots at each entry
  - Target weight shown as a dashed horizontal line
- "Log Today's Weight" button at bottom (teal)
- Small input sheet slides up when tapped: number input + "Save" button

---

### Screen 10 — Notification / Calorie Warning Screen
This is what appears when user taps a calorie reminder notification:
- Full screen card overlay
- Large bold warning: "Stay Controlled"
- Subtitle: "You have X hours left before your evening window"
- Calorie reminder: "Target: under 700 kcal before 5 PM"
- "Got it" dismiss button
- Small motivational line at bottom (rotating quotes)

---

### Screen 11 — Search Screen
- Title: "Search"
- Single search bar at top (full width, dark input)
- Below: segmented control tabs — "Food Logs" / "Weight" / "Notes"
- Search results as list cards
- Each result shows: date, content preview, time block (for food)
- Empty state: "No results found" with subtle icon

---

### Screen 12 — Profile / Settings Screen
- User avatar (initials circle, teal)
- Name and email
- Stats row: Start date / Days active / Total entries
- Settings list:
  - Notification preferences (toggle)
  - Target weight (editable)
  - Face ID lock (toggle)
  - Export data
  - Sign out (red text)

---

## User Flow to Show

Show a simple user flow connecting these screens:

```
App Launch
    ↓
[Logged in + Face ID] → Dashboard
[Not logged in] → Login → Profile Setup → Dashboard

Dashboard
    ↓ tap Wake-Up card → Wake-Up Log Screen
    ↓ tap Food card → Food Log → Add Food (bottom sheet)
    ↓ tap Analyze → AI Analysis Screen
    ↓ tap Weight → Weight Tracking Screen

Bottom Tab Bar
    → Home (Dashboard)
    → Food Log
    → Weight
    → Analysis
    → Search
```

---

## Component Specs for Handoff

Please also generate these reusable components:
- Discipline score ring (circular progress, 0–100)
- Food time block card (expandable)
- Stat card (label + number, dark surface)
- Notification banner (amber warning style)
- Bottom sheet modal template
- Empty state card (icon + message + CTA button)
- Streak counter badge (flame icon + number)

---

## Platform
iOS only. iPhone. Portrait orientation. Design for iPhone 15 Pro screen size (393 x 852 pt).

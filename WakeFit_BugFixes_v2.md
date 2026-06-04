# WakeFit — Complete Bug Fix Prompt v2
## Paste this ENTIRE file into Claude Code

Read this completely before touching any file.
Fix every bug listed. Run build check after EACH fix.
Do NOT skip any bug. Do NOT move on until BUILD SUCCEEDED.

---

## CONTEXT — What AI (OpenAI) does in this app

The OpenAI API is used ONLY in AIAnalysisView.swift.
When user taps "Analyze My Day" it sends their food logs
to GPT-4o which returns:
- Estimated calories
- Estimated protein  
- Discipline status (Disciplined/Borderline/Off Track)
- Coach diagnosis text
- Tomorrow's advice

This is the ONLY place OpenAI is used. It is NOT used 
anywhere else in the app.

---

## BUG PRIORITY ORDER

Fix in this exact sequence:

---

## FIX 1 — Back button missing on WakeUpView and WeightView

Both screens have no way to go back to Dashboard.
User is stuck on these screens.

Fix in Views/WakeUp/WakeUpView.swift:
Add a custom back button at the top:
```swift
// Add to top of view:
HStack {
    Button {
        dismiss()
    } label: {
        HStack(spacing: 6) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
            Text("Back")
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundStyle(AppColors.accentTeal)
    }
    Spacer()
}
.padding(.horizontal, 20)
.padding(.top, 16)
```

Add `@Environment(\.dismiss) private var dismiss` at top.

Do the SAME for:
- Views/Weight/WeightView.swift
- Views/Sleep/SleepView.swift  
- Views/AIAnalysis/AIAnalysisView.swift
- Views/Search/SearchView.swift
- Views/WakeUp/WakeUpView.swift

Also hide the system navigation bar on all these screens:
```swift
.navigationBarBackButtonHidden(true)
.toolbar(.hidden, for: .navigationBar)
```

---

## FIX 2 — "Settings" text showing top left on every screen

Every screen shows "◀ Settings" system back button.
This must be removed from ALL screens.

Fix in WakeFitApp.swift — add to root WindowGroup:
```swift
WindowGroup {
    RootView()
        .preferredColorScheme(.dark)
}
.modelContainer(sharedModelContainer)
```

Fix in EVERY view file — add these to the outermost view:
```swift
.navigationBarBackButtonHidden(true)
.toolbar(.hidden, for: .navigationBar)
.toolbarBackground(.hidden, for: .navigationBar)
```

Run this bash command to find all files needing fix:
```bash
grep -rL "navigationBarBackButtonHidden" WakeFit/Views/
```
Fix every file returned.

---

## FIX 3 — Splash screen animation not working

Splash screen shows "SYSTEM ONLINE" but no WakeFit logo
and no animation plays.

Rewrite Views/SplashView.swift completely:
```swift
import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var systemOnlineOpacity: Double = 0
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.bgBase
                .ignoresSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                // WakeFit logo
                Text("WakeFit")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(AppColors.accentTeal)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)
                
                // System online indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(AppColors.accentTeal)
                        .frame(width: 8, height: 8)
                    Text("SYSTEM ONLINE")
                        .font(.system(size: 13, weight: .medium,
                              design: .monospaced))
                        .foregroundStyle(AppColors.accentTeal)
                        .tracking(2)
                }
                .opacity(systemOnlineOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            // Step 1: Animate logo in
            withAnimation(.easeOut(duration: 0.8)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
            // Step 2: Show SYSTEM ONLINE after logo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeIn(duration: 0.4)) {
                    systemOnlineOpacity = 1.0
                }
            }
            // Step 3: Navigate after 2.5 seconds total
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete()
            }
        }
    }
}
```

Update WakeFitApp.swift to use onComplete callback:
```swift
SplashView {
    showSplash = false
}
```

---

## FIX 4 — Settings tab not opening

The gear icon / Settings tab on Dashboard stopped working.

Fix in DashboardView.swift:
Find the settings gear button and make sure it navigates:
```swift
// Top right gear button:
NavigationLink(destination: ProfileView()) {
    Image(systemName: "gearshape.fill")
        .font(.system(size: 20))
        .foregroundStyle(AppColors.accentTeal)
}
```

Also make sure ProfileView is properly imported and exists.
Check Views/Profile/ProfileView.swift exists and compiles.

---

## FIX 5 — No logout functionality

User cannot sign out of the app.

Fix in Views/Profile/ProfileView.swift:
Make sure sign out button:
1. Shows a confirmation alert before signing out
2. Clears ALL UserDefaults on confirm
3. Navigates to LoginView

```swift
@State var showSignOutAlert = false

// Sign out button:
Button {
    showSignOutAlert = true
} label: {
    HStack {
        Image(systemName: "rectangle.portrait.and.arrow.right")
            .foregroundStyle(AppColors.danger)
        Text("Sign Out")
            .foregroundStyle(AppColors.danger)
            .font(.system(size: 16, weight: .semibold))
        Spacer()
    }
    .padding(20)
    .background(AppColors.bgCard)
    .clipShape(RoundedRectangle(cornerRadius: 16))
}
.alert("Sign Out", isPresented: $showSignOutAlert) {
    Button("Sign Out", role: .destructive) {
        signOut()
    }
    Button("Cancel", role: .cancel) {}
} message: {
    Text("Are you sure you want to sign out?")
}

// Sign out function:
func signOut() {
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
    viewModel.isAuthenticated = false
    viewModel.needsProfileSetup = false
}
```

Make sure AuthViewModel is accessible in ProfileView.
Pass it in or use @EnvironmentObject.

---

## FIX 6 — Edit and Delete food entries

User cannot edit or delete logged food entries in FoodLogView.

Fix in Views/FoodLog/FoodLogView.swift:
Add to each food entry row:
```swift
// Add state variables:
@State var editingEntry: FoodLog? = nil
@State var editText: String = ""
@State var showEditSheet = false

// On each entry row add swipe actions:
.swipeActions(edge: .trailing, allowsFullSwipe: false) {
    // Delete button
    Button(role: .destructive) {
        modelContext.delete(entry)
        try? modelContext.save()
    } label: {
        Label("Delete", systemImage: "trash")
    }
    
    // Edit button
    Button {
        editingEntry = entry
        editText = entry.foodText
        showEditSheet = true
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    .tint(AppColors.accentTeal)
}

// Add edit sheet:
.sheet(isPresented: $showEditSheet) {
    VStack(spacing: 20) {
        Text("Edit Food Entry")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(AppColors.textPrimary)
        
        TextEditor(text: $editText)
            .frame(height: 120)
            .padding(12)
            .background(AppColors.bgCardHigh)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
        Button("Save Changes") {
            editingEntry?.foodText = editText
            try? modelContext.save()
            showEditSheet = false
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(AppColors.accentTeal)
        .foregroundStyle(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding(20)
    .background(AppColors.bgCard)
    .presentationDetents([.medium])
}
```

---

## FIX 7 — Edit and Delete wake-up entries

User cannot edit or delete wake-up log entries.

Fix in Views/WakeUp/WakeUpView.swift:
Add swipe to delete on history rows:
```swift
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) {
        modelContext.delete(entry)
        try? modelContext.save()
    } label: {
        Label("Delete", systemImage: "trash")
    }
}
```

Also add tap to edit — tapping a history row opens 
time picker pre-filled with that entry's time.

---

## FIX 8 — No profile picture / edit profile

ProfileView has no way to edit name or add profile picture.

Fix in Views/Profile/ProfileView.swift:

Add profile picture with initials fallback:
```swift
// Profile header:
ZStack {
    Circle()
        .fill(AppColors.bgCardHigh)
        .frame(width: 80, height: 80)
    
    // Show initials
    Text(userInitials)
        .font(.system(size: 28, weight: .bold))
        .foregroundStyle(AppColors.accentTeal)
}
// Tap to change (future: photo picker)
.onTapGesture {
    showImagePicker = true
}
.overlay(
    Image(systemName: "camera.fill")
        .font(.system(size: 12))
        .foregroundStyle(.white)
        .padding(6)
        .background(AppColors.accentTeal)
        .clipShape(Circle())
    , alignment: .bottomTrailing
)

// Computed initials:
var userInitials: String {
    let name = users.first?.name ?? "A"
    let parts = name.components(separatedBy: " ")
    if parts.count >= 2 {
        return "\(parts[0].prefix(1))\(parts[1].prefix(1))"
            .uppercased()
    }
    return String(name.prefix(2)).uppercased()
}
```

Add edit name button:
```swift
@State var showEditName = false
@State var editedName = ""

Button("Edit Profile") {
    editedName = users.first?.name ?? ""
    showEditName = true
}
.sheet(isPresented: $showEditName) {
    VStack(spacing: 20) {
        Text("Edit Name")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(AppColors.textPrimary)
        
        TextField("Your name", text: $editedName)
            .padding(16)
            .background(AppColors.bgCardHigh)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(AppColors.textPrimary)
        
        Button("Save") {
            users.first?.name = editedName
            try? modelContext.save()
            showEditName = false
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(AppColors.accentTeal)
        .foregroundStyle(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding(20)
    .background(AppColors.bgCard)
    .presentationDetents([.medium])
}
```

---

## FIX 9 — Weight showing in lbs instead of kg

Weight is stored in kg but displaying in lbs everywhere.

Fix: Search ALL files for "lbs" and "2.20462" and remove.
Weight must ALWAYS display in kg.

In WeightView.swift — remove any conversion:
```swift
// WRONG - remove this:
let weightInLbs = weight * 2.20462

// CORRECT - just use kg directly:
Text("\(weight, specifier: "%.1f") kg")
```

In DashboardView.swift weight card:
```swift
Text("\(currentWeight ?? 0, specifier: "%.1f") kg")
```

---

## FIX 10 — Score starts at 33 instead of 0

New user with nothing logged should show score 0.

Fix discipline score in DashboardView.swift:
```swift
var disciplineScore: Int {
    var score = 0
    if todayWakeUp != nil { score += 34 }
    if morningLogged || afternoonLogged || eveningLogged {
        score += 33
    }
    if todaySlept?.sleptOnTime == true { score += 33 }
    return score
    // NO base score - starts at 0
}
```

---

## FIX 11 — Day 0 showing instead of actual days

Fix daysSinceStart to show Day 1 on first day:
```swift
var daysSinceStart: Int {
    guard let user = users.first else { return 1 }
    let calendar = Calendar.current
    let start = calendar.startOfDay(for: user.startDate)
    let today = calendar.startOfDay(for: Date())
    let days = calendar.dateComponents([.day], 
                from: start, to: today).day ?? 0
    return days + 1  // Day 1 on first day, not Day 0
}
```

---

## FIX 12 — Safe area black bars top and bottom

Still seeing black bars on some screens.

In EVERY view file, find the background and ensure:
```swift
AppColors.bgBase
    .ignoresSafeArea(.all)  // Must be .all
```

Run this to find files missing it:
```bash
grep -rL "ignoresSafeArea" WakeFit/Views/
```
Fix every file in the output.

---

## AFTER ALL FIXES

Run complete build check:
```bash
xcodebuild -scheme WakeFit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build 2>&1 | grep -E "error:|BUILD"
```

List every file changed.
Confirm BUILD SUCCEEDED.
Confirm each fix was applied.

---

## WHAT OPENAI API DOES IN THIS APP

For reference — OpenAI is used ONLY here:
- File: Services/AIAnalysisService.swift
- Triggered: When user taps "Analyze My Day" in AIAnalysisView
- Input: All food logs for today
- Output: Calories, protein, discipline status, coaching text
- Cost: ~$0.01 per analysis (very cheap)
- Key location: Utilities/Secrets.swift → APIKeys.openAI
- It is NOT used for anything else in the app

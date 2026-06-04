# WakeFit — Speech-to-Text Implementation Spec

## What needs to be built

The mic button in AddFoodItemView must:
1. Request microphone + speech recognition permission
2. Start recording when tapped
3. Convert speech to text in real time
4. Show transcribed text in the food input field
5. Stop recording when tapped again
6. Save the transcribed text as a food log entry

---

## Files to create/modify

### NEW: Services/SpeechToTextService.swift
### MODIFY: Views/FoodLog/AddFoodItemView.swift
### MODIFY: Info.plist — add permission keys

---

## CRITICAL: Info.plist permissions required

Add these two keys to Info.plist or the app will crash:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>WakeFit uses speech recognition to log food by voice.</string>

<key>NSMicrophoneUsageDescription</key>
<string>WakeFit needs microphone access to record your food log entries.</string>
```

Without these the app crashes immediately when mic is tapped.

---

## SpeechToTextService.swift

```swift
import Foundation
import Speech
import AVFoundation

// @Observable makes this class work with SwiftUI automatically
// When any property changes, views that use it update automatically
@Observable
class SpeechToTextService {
    
    // MARK: - State Properties
    var isRecording: Bool = false           // Is mic active right now?
    var transcribedText: String = ""        // Live transcription result
    var errorMessage: String? = nil         // Any error to show user
    var isAvailable: Bool = false           // Is speech recognition available?
    
    // MARK: - Private Apple Framework Objects
    
    // SFSpeechRecognizer: Apple's speech recognition engine
    private var speechRecognizer: SFSpeechRecognizer?
    
    // SFSpeechAudioBufferRecognitionRequest: Feeds live audio to recognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    // SFSpeechRecognitionTask: The active recognition task we can cancel
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // AVAudioEngine: Captures microphone audio in real time
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    
    // MARK: - Setup
    
    init() {
        // Use device locale for speech recognition (en-US, etc.)
        speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
        checkAvailability()
    }
    
    /// Checks if speech recognition is available on this device
    private func checkAvailability() {
        isAvailable = speechRecognizer?.isAvailable ?? false
    }
    
    // MARK: - Permission Request
    
    /// Requests both microphone and speech recognition permissions
    /// Must be called before startRecording()
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        // Step 1: Request speech recognition permission
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            // Step 2: Request microphone permission
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }
    
    // MARK: - Start Recording
    
    /// Starts live speech recognition
    /// Audio flows: Microphone → AVAudioEngine → SFSpeechRecognizer → transcribedText
    func startRecording() {
        // Cancel any existing task
        stopRecording()
        
        // Configure audio session for recording
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Could not set up audio session"
            return
        }
        
        // Create fresh recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        // Report partial results as user speaks (live transcription)
        recognitionRequest.shouldReportPartialResults = true
        
        // Get microphone input node from audio engine
        let inputNode = audioEngine.inputNode
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                // Update transcribed text with latest recognition
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                // Stop engine when done or on error
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }
        
        // Tap into microphone audio stream
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            // Feed audio buffer to speech recognizer
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
            errorMessage = nil
        } catch {
            errorMessage = "Could not start recording"
            isRecording = false
        }
    }
    
    // MARK: - Stop Recording
    
    /// Stops recording and finalizes transcription
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Toggle
    
    /// Toggles recording on/off — call this from the mic button
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    // MARK: - Clear
    
    /// Clears transcribed text (call when sheet dismisses)
    func clearTranscription() {
        transcribedText = ""
        errorMessage = nil
    }
}
```

---

## Updated AddFoodItemView.swift

```swift
import SwiftUI
import Speech

struct AddFoodItemView: View {
    
    // MARK: - Properties
    var timeBlock: String
    var onSave: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // Speech service - one instance per sheet
    @State private var speechService = SpeechToTextService()
    
    // Form state
    @State private var foodText: String = ""
    @State private var showEmptyError: Bool = false
    @State private var hasPermission: Bool = false
    
    // Design tokens
    private let bgCard = AppColors.bgCard
    private let bgCardHigh = AppColors.bgCardHigh
    private let accentTeal = AppColors.accentTeal
    private let textPrimary = AppColors.textPrimary
    private let textSecondary = AppColors.textSecondary
    private let textMuted = AppColors.textMuted
    private let cardBorder = AppColors.cardBorder
    private let danger = AppColors.danger
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Drag Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(cardBorder)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
            
            // MARK: - Header
            HStack {
                Text("Add Food Entry")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(textPrimary)
                
                Spacer()
                
                // Time block badge
                Text(timeBlock.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(accentTeal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(accentTeal.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // MARK: - Text Input
            VStack(alignment: .leading, spacing: 8) {
                Text("WHAT DID YOU EAT?")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(textMuted)
                    .tracking(1.5)
                
                // Text editor for food input
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $foodText)
                        .font(.system(size: 16))
                        .foregroundStyle(textPrimary)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 100)
                        // Sync speech transcription to text field
                        .onChange(of: speechService.transcribedText) { _, newValue in
                            if !newValue.isEmpty {
                                foodText = newValue
                            }
                        }
                    
                    // Placeholder text
                    if foodText.isEmpty && !speechService.isRecording {
                        Text("e.g. 2 eggs, toast, black coffee...")
                            .font(.system(size: 16))
                            .foregroundStyle(textMuted)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                    
                    // Live transcription indicator
                    if speechService.isRecording {
                        Text("Listening...")
                            .font(.system(size: 16))
                            .foregroundStyle(accentTeal.opacity(0.7))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
                .padding(16)
                .background(bgCardHigh)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(
                            speechService.isRecording ? accentTeal : cardBorder,
                            lineWidth: speechService.isRecording ? 2 : 1
                        )
                )
                
                // Validation error
                if showEmptyError {
                    Text("Please enter what you ate")
                        .font(.system(size: 13))
                        .foregroundStyle(danger)
                }
                
                // Speech error
                if let error = speechService.errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(danger)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            
            // MARK: - Mic Button
            VStack(spacing: 8) {
                Button {
                    handleMicTap()
                } label: {
                    ZStack {
                        // Outer pulsing ring when recording
                        if speechService.isRecording {
                            Circle()
                                .fill(danger.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .scaleEffect(speechService.isRecording ? 1.3 : 1.0)
                                .animation(
                                    speechService.isRecording ?
                                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                                    .default,
                                    value: speechService.isRecording
                                )
                        }
                        
                        // Main mic circle
                        Circle()
                            .fill(speechService.isRecording ? danger : bgCardHigh)
                            .frame(width: 64, height: 64)
                            .overlay(
                                Circle()
                                    .stroke(
                                        speechService.isRecording ? danger : cardBorder,
                                        lineWidth: 2
                                    )
                            )
                        
                        // Mic icon
                        Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(speechService.isRecording ? .white : textMuted)
                    }
                }
                
                Text(speechService.isRecording ? "Tap to stop" : "Or tap to speak")
                    .font(.system(size: 13))
                    .foregroundStyle(textMuted)
            }
            .padding(.top, 24)
            
            Spacer()
            
            // MARK: - Save Button
            Button {
                saveEntry()
            } label: {
                Text("Save Entry")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(foodText.isEmpty ? textMuted : Color.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(foodText.isEmpty ? bgCardHigh : accentTeal)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            }
            .disabled(foodText.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(AppColors.bgCard)
        .onAppear {
            requestPermissions()
        }
        .onDisappear {
            // Stop recording and clean up when sheet closes
            speechService.stopRecording()
            speechService.clearTranscription()
        }
    }
    
    // MARK: - Actions
    
    /// Request mic + speech permissions when sheet opens
    private func requestPermissions() {
        speechService.requestPermissions { granted in
            hasPermission = granted
        }
    }
    
    /// Handle mic button tap
    private func handleMicTap() {
        if !hasPermission {
            speechService.errorMessage = "Microphone permission required. Go to Settings → WakeFit to enable."
            return
        }
        speechService.toggleRecording()
    }
    
    /// Save food entry
    private func saveEntry() {
        // Stop recording if active
        if speechService.isRecording {
            speechService.stopRecording()
        }
        
        let trimmed = foodText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showEmptyError = true
            return
        }
        
        onSave(trimmed)
        dismiss()
    }
}
```

---

## Info.plist Keys (CRITICAL)

In Xcode:
1. Open `WakeFit/Resources/` folder or find Info.plist
2. Add these two keys:

Key: `Privacy - Microphone Usage Description`
Value: `WakeFit uses your microphone to log food entries by voice.`

Key: `Privacy - Speech Recognition Usage Description`  
Value: `WakeFit uses speech recognition to convert your voice into food log entries.`

If Info.plist is not visible in project:
- Go to WakeFit target → Info tab → add the keys there

---

## Testing on Simulator

Note: Speech recognition works on real iPhone but is limited on simulator.
On simulator: mic button will show permission dialog but transcription may not work perfectly.
On real iPhone: Full speech-to-text works.

To test properly → run on physical iPhone via Xcode.

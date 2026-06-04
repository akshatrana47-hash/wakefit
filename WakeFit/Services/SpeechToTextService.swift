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

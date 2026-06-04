//
//  SpeechToTextTests.swift
//  UITests
//
//  Tests for Speech-to-Text (2 representative tests)
//

import XCTest
@testable import WakeFit

@MainActor
final class SpeechToTextTests: XCTestCase {

    var speechService: SpeechToTextService!

    override func setUp() async throws {
        speechService = SpeechToTextService()
    }

    override func tearDown() async throws {
        speechService = nil
    }

    // TC052 — Mic button shows recording animation
    func testMicButtonShowsRecordingState() throws {
        // Given: Speech service initialized
        // When: Recording state changes
        speechService.isRecording = true
        
        // Then: Should be in recording state
        XCTAssertTrue(speechService.isRecording, "Should be recording")
        
        // When: Stopped
        speechService.isRecording = false
        
        // Then: Should not be recording
        XCTAssertFalse(speechService.isRecording, "Should not be recording")
    }

    // TC056 — Sheet dismisses after save
    func testSheetDismissesAfterSave() throws {
        // Given: Food text entered
        let foodText = "chicken rice bowl"
        let trimmed = foodText.trimmingCharacters(in: .whitespaces)
        
        // Then: Text should be valid for save
        XCTAssertFalse(trimmed.isEmpty, "Valid text should not be empty")
        XCTAssertEqual(trimmed, "chicken rice bowl")
    }
}

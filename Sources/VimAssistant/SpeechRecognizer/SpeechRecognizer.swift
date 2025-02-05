//
//  SpeechRecognizer.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import AVFoundation
import Foundation
import Speech
import SwiftUI

public actor SpeechRecognizer: ObservableObject {

    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?

    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    init() {
        recognizer = SFSpeechRecognizer()
    }
}

extension SFSpeechRecognizer {

    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioApplication {

    func hasPermissionToRecord() async -> Bool {

        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }

}

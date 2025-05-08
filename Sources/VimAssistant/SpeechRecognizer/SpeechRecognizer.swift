//
//  SpeechRecognizer.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import AVFoundation
import Foundation
import Speech

private let bus: AVAudioNodeBus = 0
private let bufferSize: AVAudioFrameCount = 1024

public actor SpeechRecognizer {

    enum RecognizerError: Error {

        case notAuthorizedToRecognize
        case notPermittedToRecord
        case unavailable

        var message: String {
            switch self {
            case .notAuthorizedToRecognize:
                return "Not authorized to recognize speech."
            case .notPermittedToRecord:
                return "Not permitted to record audio"
            case .unavailable:
                return "SpeechRecognizer is unavailable"
            }
        }
    }

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

    /// Reset the speech recognizer.
    private func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }

    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        #if !os(macOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif

        let inputNode = audioEngine.inputNode
        let outputFormat = inputNode.outputFormat(forBus: bus)

        inputNode.installTap(onBus: bus, bufferSize: bufferSize, format: outputFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()

        try audioEngine.start()

        return (audioEngine, request)
    }

    /**
     Begin streaming speech recognition results.
     */
    func stream() -> AsyncThrowingStream<String, Error> {

        reset()

        return AsyncThrowingStream<String, Error> { continuation in

            guard let recognizer, recognizer.isAvailable else {
                continuation.finish(throwing: RecognizerError.unavailable)
                return
            }

            do {
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                self.task = recognizer.recognitionTask(with: request) { result, error in

                    let receivedFinalResult = result?.isFinal ?? false
                    let receivedError = error != nil

                    if receivedFinalResult || receivedError {
                        audioEngine.stop()
                        audioEngine.inputNode.removeTap(onBus: bus)
                        continuation.finish(throwing: error)
                    }

                    if let result {
                        continuation.yield(result.bestTranscription.formattedString)
                    }
                }
            } catch {
                continuation.finish(throwing: error)
                self.reset()
            }

            continuation.onTermination = { _ in
                Task {
                    await self.reset()
                }
            }
        }
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

//
//  VimAssistant.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Combine
import Foundation
import VimKit

public class VimAssistant: ObservableObject, @unchecked Sendable {

    private let decoder: JSONDecoder = .init()
    private let speechRecognizer: SpeechRecognizer = .init()

    /// Speech Recognizer task.
    private var task: Task<Void, Error>?

    @MainActor
    public var prediction: Result<VimPrediction, Error>?

    @MainActor
    public var listen: Bool = false {
        didSet {
            if listen {
                start()
            } else {
                stop()
            }
        }
    }

    /// Public initializer.
    public init() { }

    /// Starts the speech recogntion task to being processing ML predictions.
    func start() {

        if let task { task.cancel() }

        task = Task {
            do {
                let stream = await speechRecognizer.stream()

                for try await text in stream {
                    guard text.isNotEmpty else { continue }
                    Task {
                        guard let processedResult = await process(text: text) else { return }
                        Task { @MainActor in
                            prediction = .success(processedResult)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    /// Stops the speech recognizer and clears any previous prediction results.
    func stop() {
        Task { @MainActor in
            prediction = nil
        }
        task?.cancel()
    }

    /// Sends a prediction request to a network addressable model which can be used when the network is available.
    /// - Parameter text: the text to process
    /// - Returns: the natural language processing prediction
    func process(text: String) async -> VimPrediction? {
        // TODO: The URL should be authenticated 
        guard text.isNotEmpty, var components = URLComponents(string: "http://localhost:8080") else {
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: text)
        ]

        guard let url = components.url else { return nil }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }

        return try? JSONDecoder().decode(VimPrediction.self, from: data)
    }
}

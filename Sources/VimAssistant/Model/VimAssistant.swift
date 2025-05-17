//
//  VimAssistant.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Combine
import Foundation
import SwiftData
import VimKit

public class VimAssistant: ObservableObject, @unchecked Sendable {

    private let decoder: JSONDecoder = .init()
    private let speechRecognizer: SpeechRecognizer = .init()

    private let scheduler: DispatchQueue = .init(label: "ai.assistant")
    private let dueTime: TimeInterval = 0.8
    private var cancellables: Set<AnyCancellable> = .init()

    /// Speech Recognizer task.
    private var task: Task<Void, Error>?

    @MainActor
    public var prediction: VimPrediction?

    /// Holds the latest text to process.
    @Published
    var text: String = .empty

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
    public init() {
        /// Debounce the text so we can limit rapid successive events from the speech recognizer.
        $text
            .removeDuplicates()
            .debounce(for: .seconds(dueTime), scheduler: scheduler)
            .sink(receiveValue: { [weak self] value in
                guard let self else { return }
                Task {
                    guard let receivedPrediction = await process(text: value) else { return }
                    Task { @MainActor in
                        prediction = receivedPrediction
                    }
                }
            })
            .store(in: &cancellables)
    }

    /// Starts the speech recogntion task to being processing ML predictions.
    func start() {

        task?.cancel()

        task = Task {
            do {
                let stream = await speechRecognizer.stream()

                for try await transciption in stream {
                    guard transciption.isNotEmpty else { continue }
                    text = transciption

                    Task { @MainActor in
                        prediction = .init(text: transciption)
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

    /// Completes the last natural language prediction task and restarts the task.
    func complete() {
        stop()
        start()
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

    /// Handles the specified prediction.
    /// - Parameters:
    ///   - vim: the vim object to update based on the given prediction.
    ///   - prediction: the prediction to handle
    func handle(vim: Vim, prediction: VimPrediction?) async {
        guard let prediction, let bestPrediction = prediction.bestPrediction else { return }
        let action = bestPrediction.action
        switch action {
        case .isolate:
            let ids = search(vim: vim, in: prediction)
            guard ids.isNotEmpty else { return }
            await vim.isolate(ids: ids)
        case .hide:
            let ids = search(vim: vim, in: prediction)
            guard ids.isNotEmpty else { return }
            await vim.hide(ids: ids)
        case .quantify:
            break
        case .zoomIn:
            await vim.zoom()
        case .zoomOut:
            await vim.zoom(out: true)
        case .lookLeft:
            await vim.look(.left)
        case .lookRight:
            await vim.look(.right)
        case .lookUp:
            await vim.look(.up)
        case .lookDown:
            await vim.look(.down)
        case .panLeft:
            await vim.pan(.left)
        case .panRight:
            await vim.pan(.right)
        case .panUp:
            await vim.pan(.up)
        case .panDown:
            await vim.pan(.down)
        }
    }

    /// Performs a fuzzy search using the levenshtein distance algorithm across the node tree to find the best results.
    /// - Parameters:
    ///   - vim: the vim object to search
    ///   - prediction: the prediction to extract entity names from
    /// - Returns: a set of node ids that match the prediction
    private func search(vim: Vim, in prediction: VimPrediction) -> Set<Int> {
        guard let tree = vim.tree else { return [] }
        var ids: Set<Int> = .init()
        let values = prediction.entities.map{ $0.value }
        for entity in prediction.entities {
            let searchResults = tree.search(entity.value)
            guard let bestResult = searchResults.first else { continue }
            ids.formUnion(bestResult.item.ids)
        }
        return ids
    }
}

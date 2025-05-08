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

public struct VimPrediction: Decodable {

    enum CodingKeys: String, CodingKey {
        case text = "text"
        case actions = "cats"
        case entities = "ents"
    }

    enum Action: String, Codable, Identifiable {
        case isolate = "ISOLATE"
        case hide = "HIDE"
        case quantify = "QUANTIFY"

        public var id: String {
            rawValue
        }
    }

    struct LabeledEntity: Decodable, Identifiable {

        enum CodingKeys: String, CodingKey {
            case label = "label"
            case start = "start"
            case end = "end"
        }

        var label: String
        var value: String = .empty
        var range: Range<Int>

        public var id: String {
            label + "_\(range)"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            label = try values.decode(String.self, forKey: .label)
            let start = try values.decode(Int.self, forKey: .start)
            let end = try values.decode(Int.self, forKey: .end)
            range = start..<end
        }

        mutating func update(text: String) {
            value = text[range]
        }

    }

    var text: String
    var actions: [Action: Float] = .init()
    var entities: [LabeledEntity] = .init()

    /// Provides a convenience list of tuples that contains
    /// the index of a known entity and it's range or -1 for unkown.
    var ranges: [(index: Int, range: Range<Int>)] = .init()

    /// Initializes the Prediction from json
    /// - Parameter decoder: the decoder to use
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = try values.decode(String.self, forKey: .text)
        let categories = try values.decode([String: Float].self, forKey: .actions)
        for (key, value) in categories {
            if let cat: Action = .init(rawValue: key) {
                actions[cat] = value
            }
        }

        var start = 0
        var end = text.count

        // Build the entities
        entities = try values.decode([LabeledEntity].self, forKey: .entities)
        for (i, entity) in entities.enumerated() {
            entities[i].update(text: text)

            // Append a previous range
            if start < entity.range.lowerBound {
                let range = start..<entity.range.lowerBound
                ranges.append((.empty, range))
            }

            // Append this entity range to the total list of ranges
            ranges.append((i, entity.range))
            start = entity.range.upperBound
        }

        // Append the last range (if not contained in last range)
        if start < end {
            let range = start..<end
            ranges.append((.empty, range))
        }
    }
}

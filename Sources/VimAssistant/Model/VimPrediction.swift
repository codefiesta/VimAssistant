//
//  VimPrediction.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Foundation

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

    var bestPrediction: (action: Action, confidence: Float)? {
        actions.sorted{ $0.value > $1.value }.first.map{ ($0.key, $0.value)}
    }

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
        let end = text.count

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

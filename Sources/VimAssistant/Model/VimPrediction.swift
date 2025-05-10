//
//  VimPrediction.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Foundation

public struct VimPrediction: Decodable, Equatable {

    enum CodingKeys: String, CodingKey {
        case text = "text"
        case actions = "cats"
        case entities = "ents"
        case tokens = "tokens"
    }

    enum NerLabel: String, Identifiable {

        case person = "PERSON"
        case organization = "ORGANIZATION"
        case location = "LOCATION"
        case date = "DATE"
        case time = "TIME"
        case event = "EVENT"
        case workOfArt = "WORK_OF_ART"
        case fac = "FAC"
        case gpe = "GPE"
        case language = "LANGUAGE"
        case law = "LAW"
        case norp = "NORP"
        case cardinal = "CARDINAL"
        case bimCategory = "CON-BIM-CATG"
        case bimFamily = "CON-BIM-FAML"
        case bimType = "CON-BIM-TYPE"
        case bimInstance = "CON-BIM-INST"
        case bimLevel = "CON-BIM-LEVL"
        case bimView = "CON-BIM-VIEW"

        public var id: String {
            rawValue
        }
    }

    enum Action: String, Codable, Identifiable {
        case isolate = "ISOLATE"
        case hide = "HIDE"
        case quantify = "QUANTIFY"

        public var id: String {
            rawValue
        }
    }

    /// Represents a slice of the prediction text that holds the range of characters
    /// that can be used to slice the prediction and an index into a recognized
    /// labeled entity or -1 for unkown.
    struct Slice: Identifiable, Equatable {

        var index: Int
        var range: Range<Int>

        public var id: String {
            "_\(range.lowerBound)..<\(range.upperBound)"
        }
    }

    struct Token: Decodable, Equatable, Identifiable {

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case start = "start"
            case end = "end"
            case tag = "tag"
            case pos = "pos"
            case lemma = "lemma"
        }

        var id: Int
        var range: Range<Int>
        var tag: String
        var pos: String
        var lemma: String

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            tag = try values.decode(String.self, forKey: .tag)
            pos = try values.decode(String.self, forKey: .pos)
            lemma = try values.decode(String.self, forKey: .lemma)
            let start = try values.decode(Int.self, forKey: .start)
            let end = try values.decode(Int.self, forKey: .end)
            range = start..<end
        }
    }

    struct LabeledEntity: Decodable, Identifiable, Equatable {

        enum CodingKeys: String, CodingKey {
            case label = "label"
            case start = "start"
            case end = "end"
        }

        var label: NerLabel
        var value: String = .empty
        var range: Range<Int>

        public var id: String {
            label.rawValue + "_\(range)"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let labelString = try values.decode(String.self, forKey: .label)
            label = .init(rawValue: labelString)!
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
    var tokens: [Token] = .init()

    var bestPrediction: (action: Action, confidence: Float)? {
        actions.sorted{ $0.value > $1.value }.first.map{ ($0.key, $0.value)}
    }

    /// Provides a convenience text slices.
    var slices: [Slice] = .init()

    /// Initializes a placeholder prediction with only text
    /// - Parameter text: the natural language text
    init(text: String) {
        self.text = text
    }

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

        // Decode the entities
        entities = try values.decode([LabeledEntity].self, forKey: .entities)
        for (i, entity) in entities.enumerated() {
            entities[i].update(text: text)

            // Append a previous range
            if start < entity.range.lowerBound {
                let range = start..<entity.range.lowerBound
                slices.append(Slice(index: .empty, range: range))
            }

            // Append this entity range to the total list of ranges
            slices.append(Slice(index: i, range: entity.range))
            start = entity.range.upperBound
        }

        // Append the last range (if not contained in last range)
        if start < end {
            let range = start..<end
            slices.append(Slice(index: .empty, range: range))
        }

        // Decode the tokens
        tokens = try values.decodeIfPresent([Token].self, forKey: .tokens) ?? []
    }
}

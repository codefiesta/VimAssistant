//
//  Vocabulary.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Foundation

private let vocabularyFileName = "bert-base-uncased-vocab"

public class Vocabulary: @unchecked Sendable {

    static let shared: Vocabulary = Vocabulary()

    private let values: [Substring: Int]

    var unknown: Int {
        values["[UNK]"]!
    }

    var padding: Int {
        values["[PAD]"]!
    }

    var separator: Int {
        values["[SEP]"]!
    }

    var classifyStart: Int {
        values["[CLS]"]!
    }

    init() {
        guard let url = Bundle.module.url(forResource: vocabularyFileName, withExtension: "txt") else {
            fatalError("Vocabulary file is missing")
        }
        guard let rawVocabulary: String = try? .init(contentsOf: url, encoding: .utf8) else {
            fatalError("Vocabulary file has no contents.")
        }

        let words = rawVocabulary.split(separator: "\n")
        let values = 0..<words.count
        self.values = Dictionary(uniqueKeysWithValues: zip(words, values))
    }

    public func tokenID(for token: Substring) -> Int {
        values[token] ?? unknown
    }

    public func tokenID(for string: String) -> Int {
        let token = Substring(string)
        return values[token] ?? unknown
    }
}

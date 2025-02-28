//
//  TokenizedString.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import NaturalLanguage

private let defaultPrefix: String = "##"
private let maxTokenCount: Int = 128

struct TokenizedString {

    /// Use Natural Language's NLTagger to tokenize the input by word.
    private let tagger: NLTagger = .init(tagSchemes: [.tokenType])

    /// The vocabulary.
    private let vocabulary: Vocabulary = .shared

    /// The raw untokenized string value.
    private let rawValue: String

    /// The array of tokens
    public private(set) var tokens: [Substring] = .init()

    /// The array of token IDs
    public private(set) var tokenIDs: [Int] = .init()

    /// Common Initializer
    /// - Parameter value: the raw value to tokenize.
    init(_ value: String) {
        rawValue = value
        tagger.string = rawValue

        let results = wordpieceTokens()
        tokens = results.tokens
        tokenIDs = results.tokenIDs
    }

    /// Splits the raw text into an array of word tokens.
    /// - Returns: An array of substrings.
    private func wordTokens() -> [Substring] {
        var results: [Substring] = []

        let range = rawValue.startIndex..<rawValue.endIndex

        // Find all tokens in the string and append to the array.
        tagger.enumerateTags(in: range,
                             unit: .word,
                             scheme: .tokenType,
                             options: [.omitWhitespace]) { (_, range) -> Bool in
            results.append(rawValue[range])
            return true
        }

        return results
    }

    /// Splits word tokens into its component wordpiece tokens, if possible.
    /// - Returns: A tuple of  word/wordpiece tokens and their IDs.
    private func wordpieceTokens() -> (tokens: [Substring], tokenIDs: [Int]) {

        let wordTokens = wordTokens()

        var wordpieceTokens = [Substring]()
        var wordpieceTokenIDs = [Int]()

        for token in wordTokens {
            // Skip tokens that are too long.
            guard token.count <= maxTokenCount else {
                continue
            }

            var subTokens = [Substring]()
            var subTokenIDs = [Int]()

            // Start with the whole token.
            var subToken = token

            // Note when we've found the root word.
            var foundFirstSubtoken = false

            while subToken.isNotEmpty {

                // Word suffixes begin with ## in the vocabulary, such as `##ing`.
                let prefix = foundFirstSubtoken ? defaultPrefix : ""

                // Convert the string to lowercase to match the vocabulary.
                let searchTerm = Substring(prefix + subToken).lowercased()

                let subTokenID = vocabulary.tokenID(for: searchTerm)

                if subTokenID == vocabulary.unknown {
                    // Remove the last character and try again.
                    let nextSubtoken = subToken.dropLast()

                    if nextSubtoken.isEmpty {

                        // This token and its components are not in the vocabulary.
                        subTokens = [token]
                        subTokenIDs = [vocabulary.unknown]

                        // Exit the while-loop, but continue the for-loop.
                        break
                    }

                    // Prepare for the next iteration of the while-loop.
                    subToken = nextSubtoken

                } else {

                    // Note that this loop has found the first subtoken.
                    // Ok to set true for additional subtokens.
                    foundFirstSubtoken = true

                    // Save this wordpiece and its ID.
                    subTokens.append(subToken)
                    subTokenIDs.append(subTokenID)

                    // Repeat search with the token's remainder, if any.
                    subToken = token.suffix(from: subToken.endIndex)
                }
            }

            // Append all of this token's sub-tokens and their IDs.
            wordpieceTokens += subTokens
            wordpieceTokenIDs += subTokenIDs

        }

        guard wordpieceTokens.count == wordpieceTokenIDs.count else {
            fatalError("Tokens array and TokenIDs arrays must be the same size.")
        }

        return (wordpieceTokens, wordpieceTokenIDs)
    }
}

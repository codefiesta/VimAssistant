//
//  TokenizedStringTests.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Testing
@testable import VimAssistant

@Test("Check tokenized string data",
      .tags(.tokenizer))
func tokenizedStringTest() async throws {

    let tokenizedString = TokenizedString("The quick brown fox jumps over the lazy dog.")
    #expect(tokenizedString.tokens.count == 10)
    #expect(tokenizedString.tokens.count == tokenizedString.tokenIDs.count)
}

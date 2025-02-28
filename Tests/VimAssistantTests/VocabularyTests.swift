//
//  VocabularyTests.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Testing
@testable import VimAssistant

@Test("Check vocabulary data",
      .tags(.vocabulary))
func vocabularyTest() async throws {

    let vocabulary = Vocabulary.shared
    #expect(vocabulary.padding == 0)
    #expect(vocabulary.unknown == 100)
    #expect(vocabulary.classifyStart == 101)
    #expect(vocabulary.separator == 102)
    #expect(vocabulary.tokenID(for: "[MASK]") != nil)
}

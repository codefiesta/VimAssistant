//
//  AttributedString+Extensions.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Foundation

extension AttributedString {

    /// Replaces a range of the string with the new elements.
    /// - Parameters:
    ///   - bounds: the range bounds
    ///   - newElements: the new elements to replace with
    public mutating func replaceSubrange(bounds: Range<Int>, with s: some AttributedStringProtocol) {
        let start = index(startIndex, offsetByCharacters: bounds.lowerBound)
        let end = index(startIndex, offsetByCharacters: bounds.upperBound)
        let subrange: Range<AttributedString.Index> = start..<end
        replaceSubrange(subrange, with: s)
    }
}

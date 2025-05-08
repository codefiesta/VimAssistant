//
//  String+Extensions.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Foundation

extension String {

    /// Replaces a range of the string with the new elements.
    /// - Parameters:
    ///   - bounds: the range bounds
    ///   - newElements: the new elements to replace with
    public mutating func replaceSubrange<C>(bounds: Range<Int>, with newElements: C) where C: Collection, C.Element == Character {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        let subrange: Range<String.Index> = start..<end
        replaceSubrange(subrange, with: newElements)
    }
}

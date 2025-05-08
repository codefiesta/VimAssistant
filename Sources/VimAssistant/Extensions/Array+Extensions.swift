//
//  Array+Extensions.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import Foundation

extension Array where Element: Comparable {

    /// Returns the largest indices of the array elements
    /// - Parameter count: the total elements to sort
    /// - Returns: the indices of the largest elements
    func largestIndices(_ count: Int = 10) -> [Int] {
        let count = Swift.min(count, self.count)
        let sorted = enumerated().sorted{ $0.element > $1.element }
        let elements = sorted[0..<count]
        let indices = elements.map { (tuple) in tuple.offset }
        return indices
    }
}

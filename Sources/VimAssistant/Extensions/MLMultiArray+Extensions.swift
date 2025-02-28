//
//  MLMultiArray+Extensions.swift
//  VimAssistant
//
//  Created by Kevin McKee
//

import CoreML

extension MLMultiArray {

    /// Builds an UnsafeBufferPointer from the multi-array's contents contents as the specifed type.
    /// - Returns: a mutable buffer pointer of the specified type and length.
    func toUnsafeBufferPointer<T>() -> UnsafeBufferPointer<T> {
        let pointer: UnsafeMutablePointer<T> = dataPointer.bindMemory(to: T.self, capacity: count)
        let bufferPointer = UnsafeBufferPointer(start: pointer, count: count)
        return bufferPointer
    }


    /// Returns a copy of the multi-array's contents as an array of the specified type.
    /// - Returns: an array of the specified type.
    func toArray<T>() -> [T] {
        let bufferPointer: UnsafeBufferPointer<T> = toUnsafeBufferPointer()
        return [T](bufferPointer)
    }
}

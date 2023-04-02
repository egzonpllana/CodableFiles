//
//  Optional+extensions.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 2.4.23.
//

import Foundation

public extension Optional {
    /// Unwraps an optional value and returns it, or throws an error if the value is nil.
    /// - Parameters:
    ///   - error: The error to throw if the value is nil.
    /// - Returns: The unwrapped value.
    /// - Throws: The specified error if the value is nil.
    func unwrap(orThrow error: Error) throws -> Wrapped {
        guard let unwrapped = self else {
            throw error
        }
        return unwrapped
    }
}

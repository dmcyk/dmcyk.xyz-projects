//
//  ValueStream.swift
//  Bench
//
//  Created by Damian Malarczyk on 09/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

final public  class ValueStream<T> {

    private let values: [T]
    private var index: Int

    public init(_ values: [T]) {
        guard !values.isEmpty else {
            fatalError("Values can't be empty")
        }

        self.values = values
        self.index = values.startIndex
    }

    public var next: T {
        defer {
            let next = values.index(after: index)
            if next == values.endIndex {
                index = values.startIndex
            } else {
                index = next
            }
        }

        return values[index]
    }
}

extension ValueStream: ExpressibleByArrayLiteral {

    public convenience init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

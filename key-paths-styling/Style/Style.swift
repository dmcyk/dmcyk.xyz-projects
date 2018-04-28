//
//  Style.swift
//  Style
//
//  Created by Damian Malarczyk on 28/04/2018.
//  Copyright © 2018 dmcyk. All rights reserved.
//

import Foundation

struct DefaultStyleDefinition<Subject> {

    fileprivate var values: [PartialKeyPath<Subject>: Any] = [:]
    fileprivate private(set) var properties: [
        PartialKeyPath<Subject>: (Subject, Any) -> Void
    ] = [:]

    private mutating func register<Property>(
        _ path: ReferenceWritableKeyPath<Subject, Property>
    ) {
        guard properties[path] == nil else { return }

        properties[path] = { subject, rawValue in
            guard let value = rawValue as? Property else {
                assertionFailure(
                    """
                    thanks to public interface...
                    this should never be reached
                    """
                )
                return
            }

            subject[keyPath: path] = value
        }
    }

    mutating func style<Property>(
        _ path: ReferenceWritableKeyPath<Subject, Property>,
        _ value: Property
    ) {
        register(path)
        values[path] = value
    }

    func styling<Property>(
        _ path: ReferenceWritableKeyPath<Subject, Property>,
        _ value: Property
    ) -> DefaultStyleDefinition {
        var copy = self
        copy.style(path, value)
        return copy
    }

    static func styling<Property>(
        _ path: ReferenceWritableKeyPath<Subject, Property>,
        _ value: Property
    ) -> DefaultStyleDefinition {
        var new = DefaultStyleDefinition()
        new.style(path, value)
        return new
    }

    fileprivate subscript<Property>(
        _ path: PartialKeyPath<Subject>
    ) -> Property? {
        return values[path] as? Property
    }

    func apply(to subject: Subject) {
        properties.forEach { path, writeBlock in
            guard let value = values[path] else {
                return
            }

            writeBlock(subject, value)
        }
    }
}

struct StyleDefinition<Subject, State: Hashable> {

    private var defaults = DefaultStyleDefinition<Subject>()
    private var store: [State: [PartialKeyPath<Subject>: Any]] = [:]

    private mutating func registerStyleProperty<Property>(
        _ path: ReferenceWritableKeyPath<Subject, Property>,
        `default`: Property
    ) {
        defaults.style(path, `default`)
    }

    private mutating func register<Property>(
        value: Property,
        for state: State,
        path: ReferenceWritableKeyPath<Subject, Property>
    ) {
        var currentStore = store[state] ?? [:]
        currentStore[path] = value
        store[state] = currentStore
    }

    mutating func style<Property>(
        _ path: ReferenceWritableKeyPath<Subject, Property>,
        _ values: [State: Property] = [:],
        `default`: Property
    ) {
        registerStyleProperty(path, default: `default`)

        values.forEach { state, value in
            register(value: value, for: state, path: path)
        }
    }

    func styling<Property>(
        _ path: ReferenceWritableKeyPath<Subject, Property>,
        _ values: [State: Property] = [:],
        `default`: Property
    ) -> StyleDefinition {
        var copy = self
        copy.style(path, values, default: `default`)
        return copy
    }


    static func styling<Property>(
        _ path: ReferenceWritableKeyPath<Subject, Property>,
        _ values: [State: Property] = [:],
        `default`: Property
    ) -> StyleDefinition {
        var new = StyleDefinition()
        new.style(path, values, default: `default`)
        return new
    }

    func apply(for state: State, to: Subject) {
        let currentStore = store[state] ?? [:]

        defaults.properties.forEach { path, writeBlock in
            guard let value = currentStore[path] ?? defaults[path] else {
                return
            }

            writeBlock(to, value)
        }
    }
}

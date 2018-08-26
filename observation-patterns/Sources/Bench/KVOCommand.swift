//
//  KVOCommand.swift
//  Bench
//
//  Created by Damian Malarczyk on 26/08/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import Console

public class KVOCommand: Command {

    private class Foo: NSObject {

        @objc dynamic var bar: String = ""
    }

    let nRepetitionsArg = Argument("repetitions", description: [], default: 100_000, shortForm: "n")

    public let name: String = "kvo"
    public let help: [String] = [
        "custom implementation of KVO block-based observation"
    ]

    public init() {}

    public func run(data: CommandData, with child: Command?) throws {
        let foo = Foo()

        var c = 0
        let ob = DMCKeyValueObservation(
            object: foo,
            keyPath: \Foo.bar
        ) { _, change in
            c += 1
        }
        ob.start([])

        let nRepetitions = try data.argumentValue(nRepetitionsArg)

        for _ in 0 ..< nRepetitions {
            foo.bar = "foo_bar"
        }
        
        print(c)
    }
}

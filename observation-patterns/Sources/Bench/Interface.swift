//
//  Interface.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 21/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import Atomics

struct AnyProducer {

    let updateProperties: (Int) -> Void
    let info: String

    init<T: Producer>(_ producer: T) {
        info = type(of: producer).info
        updateProperties = {
            producer.updateProperties($0)
        }
    }
}

protocol Producer {

    static var info: String { get }

    associatedtype Storage: AnyObject
    var storage: Storage { get }

    func updateProperties(_ i: Int)
    init()
}

struct AnyConsumer {

    private let counterCall: () -> Int
    let raw: Any
    var counter: Int {
        return counterCall()
    }

    init<T: Consumer>(_ consumer: T) {
        raw = consumer
        counterCall = {
            var counter = consumer.counter
            return counter.load()
        }
    }
}

protocol Consumer: class {

    associatedtype AssociatedProducer: Producer

    init(_ storage: AssociatedProducer.Storage)
    var counter: AtomicInt { get }
}

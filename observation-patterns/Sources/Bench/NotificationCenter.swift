//
//  NotificationCenter.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 21/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import Atomics

class NCStorage {

    let center = NotificationCenter.default
    var foo: TimeInterval = 0
    var bar: TimeInterval = 0
    var baz: String = ""
    var qux: String = ""
}

class NCProducer: Producer {

    let storage = NCStorage()

    static var info: String {
        return "NotificationCenter"
    }

    required init() {}

    func updateProperties(_ i: Int) {
        let center = storage.center
        storage.foo = Double(i)
        center.post(name: .NCProducerDidChangeFoo, object: storage)
        storage.bar = Double(i)
        center.post(name: .NCProducerDidChangeBar, object: storage)
        storage.baz = "foo \(i)"
        center.post(name: .NCProducerDidChangeBaz, object: storage)
        storage.qux = "bar \(i)"
        center.post(name: .NCProducerDidChangeQux, object: storage)
    }
}

class NCConsumer: Consumer {

    typealias AssociatedProducer = NCProducer

    let storage: NCStorage
    let observations: [NSNotification.Name] = [
        .NCProducerDidChangeFoo,
        .NCProducerDidChangeBar,
        .NCProducerDidChangeBaz,
        .NCProducerDidChangeQux
    ]

    private(set) var active: [NSObjectProtocol] = []
    var counter = AtomicInt()

    required init(_ storage: NCStorage) {
        self.storage = storage
        active = observations.map {
            storage.center.addObserver(
                forName: $0,
                object: storage,
                queue: nil
            ) { [weak self] notification in
                var not = notification
                self?.sink(&not)
            }
        }
    }

    deinit {
        storage.center.removeObserver(self)
    }

    @inline(never)
    private func sink<T>(_ val: inout T) {
        counter.increment()
    }
}

extension NSNotification.Name {

    static let NCProducerDidChangeFoo = NSNotification.Name("NCProducerDidChangeFoo")
    static let NCProducerDidChangeBar = NSNotification.Name("NCProducerDidChangeBar")
    static let NCProducerDidChangeBaz = NSNotification.Name("NCProducerDidChangeBaz")
    static let NCProducerDidChangeQux = NSNotification.Name("NCProducerDidChangeQux")
}

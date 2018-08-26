//
//  ModernKVOConsumer.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 21/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import Atomics

class ModernKVOConsumer: Consumer {

    typealias AssociatedProducer = KVOModernProducer

    private var observers: [NSKeyValueObservation] = []
    private let storage: KVOStorage
    var counter = AtomicInt()

    private func observe<T>(path: KeyPath<KVOStorage, T>) {
        let kvo = storage.observe(
            path,
            options: [.initial]
        ) { [weak self] val, _ in
            var _val = val
            self?.sink(&_val)
        }

        observers.append(kvo)
    }

    required init(_ storage: KVOStorage) {
        self.storage = storage

        self.observe(path: \.foo)
        self.observe(path: \.bar)
        self.observe(path: \.baz)
        self.observe(path: \.qux)
    }

    @inline(never)
    private func sink<T>(_ val: inout T) {
        counter.increment()
    }
}

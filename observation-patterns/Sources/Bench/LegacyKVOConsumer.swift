//
//  LegacyKVOConsumer.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 21/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import Atomics

class LegacyKVOConsumer: NSObject, Consumer {

    typealias AssociatedProducer = KVOLegacyProducer

    private let storage: KVOStorage
    let paths: Set<String> = [
        #keyPath(KVOStorage.foo),
        #keyPath(KVOStorage.bar),
        #keyPath(KVOStorage.baz),
        #keyPath(KVOStorage.qux)
    ]
    var counter = AtomicInt()

    required init(_ storage: KVOStorage) {
        self.storage = storage
        super.init()

        paths.forEach {
            storage.addObserver(self, forKeyPath: $0, options: [.initial], context: nil)
        }
    }

    deinit {
        paths.forEach {
            storage.removeObserver(self, forKeyPath: $0)
        }
    }

    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let path = keyPath, paths.contains(path) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        var obj = object
        sink(&obj)
    }

    @inline(never)
    private func sink<T>(_ val: inout T) {
        counter.increment()
    }
}

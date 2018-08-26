//
//  KVOProducer.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 21/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

class KVOStorage: NSObject {

    @objc public dynamic var foo: TimeInterval = 0
    @objc public dynamic var bar: TimeInterval = 0
    @objc public dynamic var baz: String = ""
    @objc public dynamic var qux: String = ""
}

class _KVOProducer: Producer {

    let storage = KVOStorage()

    class var info: String {
        fatalError("abstract")
    }

    required init() {}

    func updateProperties(_ i: Int) {
        storage.foo = Double(i)
        storage.bar = Double(i)
        storage.baz = "foo \(i)"
        storage.qux = "bar \(i)"
    }
}

class KVOModernProducer: _KVOProducer {

    override class var info: String {
        return "KVO - with consumer using Swift 4 KeyPath observation"
    }

    required init() {}
}

class KVOObjCProducer: _KVOProducer {

    override class var info: String {
        return "KVO - with consumer implemented in ObjC"
    }

    required init() {}
}

class KVOLegacyProducer: _KVOProducer {

    override class var info: String {
        return "KVO - with consumer implemented in Swift (`observeValue`)"
    }

    required init() {}
}

//
//  Obj+.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 21/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import ObjCConsumer
import Atomics

class ObjConsumerBridge: Consumer {

    typealias AssociatedProducer = KVOObjCProducer
    let raw: OBJConsumer

    var counter: AtomicInt  {
        return UnsafePointer<AtomicInt>(raw.getCounter())!.pointee
    }

    required init(_ storage: KVOStorage) {
        raw = OBJConsumer(producer: storage)
    }
}

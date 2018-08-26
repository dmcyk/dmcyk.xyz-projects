//
//  SwiftFoo.swift
//  Bench
//
//  Created by Damian Malarczyk on 14/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
@_exported import class ObjCConsumer.Foo

public class SwiftFoo: ObjCConsumer.Foo {

    public var counter = 0

    public override func takeRawDictionary(_ dict: [AnyHashable: Any]) {
        var x = dict
        sink(&x)
    }

    public override func takeGenericDictionary(_ dict: [String: NSNumber]) {
        var x = dict
        sink(&x)
    }

    @inline(never)
    func sink<T>(_ val: inout T) {
        counter += 1
    }
}

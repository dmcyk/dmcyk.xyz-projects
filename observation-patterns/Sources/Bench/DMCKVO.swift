//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2017 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
//  Modifications copyright (c) 2018 Damian Malarczyk
//

import Foundation

struct DMCKeyValueObservedChange<Value> {
    public typealias Kind = NSKeyValueChange
    public let kind: Kind
    ///newValue and oldValue will only be non-nil if .new/.old is passed to `observe()`. In general, get the most up to date value by accessing it directly on the observed object instead.
    public let newValue: Value?
    public let oldValue: Value?
    ///indexes will be nil unless the observed KeyPath refers to an ordered to-many property
    public let indexes: IndexSet?
    ///'isPrior' will be true if this change observation is being sent before the change happens, due to .prior being passed to `observe()`
    public let isPrior:Bool
}

struct DMCKeyValueChangeKey: RawRepresentable {

    let rawValue: NSString

    static let newKey = DMCKeyValueChangeKey(rawValue: NSKeyValueChangeKey.newKey.rawValue as NSString)
    static let oldKey = DMCKeyValueChangeKey(rawValue: NSKeyValueChangeKey.oldKey.rawValue as NSString)
    static let indexesKey = DMCKeyValueChangeKey(rawValue: NSKeyValueChangeKey.indexesKey.rawValue as NSString)
    static let notificationIsPriorKey = DMCKeyValueChangeKey(rawValue: NSKeyValueChangeKey.notificationIsPriorKey.rawValue as NSString)
    static let kindKey = DMCKeyValueChangeKey(rawValue: NSKeyValueChangeKey.kindKey.rawValue as NSString)
}

//private typealias ChangeKey = NSKeyValueChangeKey
private typealias ChangeKey = DMCKeyValueChangeKey

public class DMCKeyValueObservation: NSObject {

    @nonobjc weak var object : NSObject?
    @nonobjc let callback : (NSObject, DMCKeyValueObservedChange<Any>) -> Void
    @nonobjc let path : String

    @nonobjc static var swizzler : DMCKeyValueObservation? = {
        let bridgeClass: AnyClass = DMCKeyValueObservation.self
        let observeSel = #selector(NSObject.observeValue(forKeyPath:of:change:context:))
        let swapSel = #selector(DMCKeyValueObservation._swizzle_me_observeValue(forKeyPath:of:change:context:))
        let rootObserveImpl = class_getInstanceMethod(bridgeClass, observeSel)!
        let swapObserveImpl = class_getInstanceMethod(bridgeClass, swapSel)!
        method_exchangeImplementations(rootObserveImpl, swapObserveImpl)
        return nil
    }()

    init(object: NSObject, keyPath: AnyKeyPath, callback: @escaping (NSObject, DMCKeyValueObservedChange<Any>) -> Void) {
        path = keyPath._kvcKeyPathString!
        let _ = DMCKeyValueObservation.swizzler
        self.object = object
        self.callback = callback
    }

    func start(_ options: NSKeyValueObservingOptions) {
        object?.addObserver(self, forKeyPath: path, options: options, context: nil)
    }

    ///invalidate() will be called automatically when an NSKeyValueObservation is deinited
    @objc public func invalidate() {
        object?.removeObserver(self, forKeyPath: path, context: nil)
        object = nil
    }

//    @objc func _swizzle_me_observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSString: Any]?, context: UnsafeMutableRawPointer?) {
    @objc func _swizzle_me_observeValue(forKeyPath keyPath: String?, of object: Any?, change: NSDictionary?, context: UnsafeMutableRawPointer?) {
        guard let ourObject = self.object, object as? NSObject == ourObject, let change = change else { return }

        let rawKind: UInt = change[ChangeKey.kindKey.rawValue as NSString] as! UInt
        let kind = NSKeyValueChange(rawValue: rawKind)!
        let notification = DMCKeyValueObservedChange(
            kind: kind,
            newValue: change[ChangeKey.newKey.rawValue as NSString],
            oldValue: change[ChangeKey.oldKey.rawValue as NSString],
            indexes: change[ChangeKey.indexesKey.rawValue as NSString] as! IndexSet?,
            isPrior: change[ChangeKey.notificationIsPriorKey.rawValue as NSString] as? Bool ?? false
        )

        callback(ourObject, notification)
    }

    deinit {
        object?.removeObserver(self, forKeyPath: path, context: nil)
    }
}

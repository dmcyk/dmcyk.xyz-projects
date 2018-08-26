//
//  Rx.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 21/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import RxSwift
import Atomics

class RxStorage {

    let fooSubject = BehaviorSubject<TimeInterval>(value: 0)
    let barSubject = BehaviorSubject<TimeInterval>(value: 0)
    let bazSubject = BehaviorSubject<String>(value: "")
    let quxSubject = BehaviorSubject<String>(value: "")
}

class RxConsumer: Consumer {

    typealias AssociatedProducer = RxProducer
    private let disposeBag = DisposeBag()

    var counter = AtomicInt()

    required init(_ storage: RxStorage) {
        storage.fooSubject
            .asObservable()
            .subscribe { [weak self] event in
                var _event = event
                self?.sink(&_event)
            }.disposed(by: self.disposeBag)

        storage.barSubject
            .asObservable()
            .subscribe { [weak self] event in
                var _event = event
                self?.sink(&_event)
            }.disposed(by: self.disposeBag)

        storage.bazSubject
            .asObservable()
            .subscribe { [weak self] event in
                var _event = event
                self?.sink(&_event)
            }.disposed(by: self.disposeBag)

        storage.quxSubject
            .asObservable()
            .subscribe { [weak self] event in
                var _event = event
                self?.sink(&_event)
            }.disposed(by: self.disposeBag)
    }

    @inline(never)
    private func sink<T>(_ val: inout T) {
        counter.increment()
    }
}

class RxProducer: Producer {

    let storage = RxStorage()

    static var info: String {
        return "RxSwift"
    }

    required init() {}

    func updateProperties(_ i: Int) {
        storage.fooSubject.onNext(Double(i))
        storage.barSubject.onNext(Double(i))
        storage.bazSubject.onNext("foo \(i)")
        storage.quxSubject.onNext("bar \(i)")
    }
}

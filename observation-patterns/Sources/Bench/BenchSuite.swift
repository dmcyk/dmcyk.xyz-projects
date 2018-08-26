//
//  BenchSuite.swift
//  Bench
//
//  Created by Damian Malarczyk on 19/06/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import Utility

private let kProperties = 4
public class BenchSuite {

    public struct Result {

        public let observationType: ObservationType
        public let time: TimeInterval
    }

    public enum ObservationType: String, CaseIterable {

        case modernKVO, baseKVO, objcKVO, rxSwift, notificationCenter

        var producerInfo: String {
            switch self {
            case .modernKVO:
                return ModernKVOConsumer.AssociatedProducer.info
            case .baseKVO:
                return LegacyKVOConsumer.AssociatedProducer.info
            case .objcKVO:
                return ObjConsumerBridge.AssociatedProducer.info
            case .rxSwift:
                return RxConsumer.AssociatedProducer.info
            case .notificationCenter:
                return NCConsumer.AssociatedProducer.info
            }
        }
    }

    public func run(nObservers n: Int, mRepetitions m: Int, observationTypes: [ObservationType]) throws -> [ObservationType: TimeInterval] {
        let types = Array(Set(observationTypes))
        var producers: [AnyProducer] = []
        var consumers: [AnyConsumer] = []

        func addConsumer<T: Consumer>(_ type: T.Type) {
            let producer = type.AssociatedProducer.init()
            consumers += (0 ..< n).map { _ in AnyConsumer(type.init(producer.storage)) }
            producers.append(AnyProducer(producer))
        }

        types.forEach {
            switch $0 {
            case .modernKVO:
                addConsumer(ModernKVOConsumer.self)
            case .baseKVO:
                addConsumer(LegacyKVOConsumer.self)
            case .objcKVO:
                addConsumer(ObjConsumerBridge.self)
            case .rxSwift:
                addConsumer(RxConsumer.self)
            case .notificationCenter:
                addConsumer(NCConsumer.self)
            }
        }

        var results: [ObservationType: TimeInterval] = [:]

        producers.enumerated().forEach {
            let observationType = types[$0]
            results[observationType] = testProducer($1, m: m)
        }

        // validate
        guard let target = consumers.map({ $0.counter }).min() else { return results }

        let ncBase = m * kProperties
        // the OR case as notification center subscribes to notifications
        // there's no concept of initial value at the point of subscription
        precondition(target == ncBase || target == ncBase + kProperties)
        consumers.forEach {
            let ct = $0.counter
            precondition(ct == target || ct == target + kProperties)
        }

        return results
    }

    public func run(nObservers n: Int, mRepetitionSets m: [Int], observationTypes: [ObservationType]) throws -> [[ObservationType: TimeInterval]] {
        return try m.map {
            try self.run(nObservers: n, mRepetitions: $0, observationTypes: observationTypes)
        }
    }

    public func run(nObserverSets n: [Int], mRepetitions m: Int, observationTypes: [ObservationType]) throws -> [[ObservationType: TimeInterval]] {
        return try n.map {
            try self.run(nObservers: $0, mRepetitions: m, observationTypes: observationTypes)
        }
    }

    func testProducer(_ producer: AnyProducer, m: Int) -> TimeInterval {
        let time = Utils.measureTime {
            //        DispatchQueue.concurrentPerform(iterations: m) {
            //            producer.updateProperties($0)
            //        }
            (0 ..< m).forEach(producer.updateProperties)
        }

        return time
    }
}

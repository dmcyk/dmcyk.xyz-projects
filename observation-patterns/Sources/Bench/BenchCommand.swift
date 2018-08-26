//
//  BenchCommand.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 21/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation
import Console
import Utility

public class BenchCommand: Command {

    let observationCase = CaseArgument("types", BenchSuite.ObservationType.allCases)
    let resultFileNameArg = Argument("output", default: "result", shortForm: "o")
    let logscaleFlag = FlagOption("logscale", shortForm: "l")

    public let name: String = "bench"
    public let subcommands: [Command] = [
        BenchRepetitions(),
        BenchObservers()
    ]

    public let help: [String] = [
        "various observation patterns."
    ]

    public init() { }

    public func run(data: CommandData, with child: Command?) throws {
        guard child == nil else { return }

        print("Use `\(name)` help to see available benchmarks\n")
    }
}

public class BenchRepetitions: Subcommand {

    let repetitionsArg = Argument("repetitions", default: [100, 500, 1_000, 2_000, 5_000], shortForm: "m")
    let observersArg = Argument("observers", default: 10, shortForm: "n")

    public let name: String = "repetitions"
    public let help: [String] = []

    init() {}

    public func run(data: CommandData, fromParent parent: Command) throws -> Bool {
        guard let benchParent = parent as? BenchCommand else { fatalError() }

        let mSets = try data.argumentValue(repetitionsArg)
        let types = try benchParent.observationCase.values(from: data)
        let n = try data.argumentValue(observersArg)
        let logscale = try data.flag(benchParent.logscaleFlag)
        let resultFileName = try data.argumentValue(benchParent.resultFileNameArg)
        let title = "'m' repetitions"
        let labels = mSets.map(String.init)

        let results = try BenchSuite().run(
            nObservers: n,
            mRepetitionSets: mSets,
            observationTypes: types
        )

        try makePlot(results, allTypes: types, title: title, labels: labels, resultFileName: resultFileName, logscale: logscale)

        return false
    }

    public func run(data: CommandData, with child: Command?) throws {}
}

public class BenchObservers: Subcommand {

    let repetitionsArg = Argument("repetitions", default: 1_000, shortForm: "m")
    let observersArg = Argument("observers", default: [5, 10, 20, 50], shortForm: "n")

    public let name: String = "observers"
    public let help: [String] = []

    init() {}

    public func run(data: CommandData, fromParent parent: Command) throws -> Bool {
        guard let benchParent = parent as? BenchCommand else { fatalError() }

        let m = try data.argumentValue(repetitionsArg)
        let types = try benchParent.observationCase.values(from: data)
        let nSets = try data.argumentValue(observersArg)
        let logscale = try data.flag(benchParent.logscaleFlag)
        let resultFileName = try data.argumentValue(benchParent.resultFileNameArg)
        let title = "'n' observers"
        let labels = nSets.map(String.init)

        let results = try BenchSuite().run(
            nObserverSets: nSets,
            mRepetitions: m,
            observationTypes: types
        )

        try makePlot(results, allTypes: types, title: title, labels: labels, resultFileName: resultFileName, logscale: logscale)

        return false
    }

    public func run(data: CommandData, with child: Command?) throws {}
}

private extension NumberFormatter {

    static func csvFormatter() -> NumberFormatter {
        let nf = NumberFormatter()
        nf.minimumIntegerDigits = 1
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 4
        return nf
    }
}

private func buildCSV(_ results: [[BenchSuite.ObservationType: TimeInterval]], allTypes: [BenchSuite.ObservationType], title: String, labels: [String]) -> String {
    let nf = NumberFormatter.csvFormatter()
    return Utils.buildCSV(
        labels: labels,
        data: (results.map { r in allTypes.map { nf.string(for: r[$0])! }}),
        names: [title] + allTypes.map { $0.rawValue }
    )
}

private func buildEntryCSV(_ results: [[BenchSuite.ObservationType: TimeInterval]], allTypes: [BenchSuite.ObservationType], title: String, labels: [String]) -> [String] {
    let nf = NumberFormatter.csvFormatter()
    return allTypes.map { key in
        Utils.buildCSV(
            labels: labels,
            data: [(results.map { nf.string(for: $0[key]!)! })].getColumns(),
            names: [title] + [key.rawValue]
        )
    }
}

private func makePlot(_ results: [[BenchSuite.ObservationType: TimeInterval]], allTypes: [BenchSuite.ObservationType], title: String, labels: [String], resultFileName: String, logscale: Bool) throws {
    guard !results.isEmpty else { return }

    let entries = buildEntryCSV(results, allTypes: allTypes, title: title, labels: labels)
    let tmpFiles = entries.enumerated().map { URL(fileURLWithPath: "plot-\($0.offset).tmp") }
    try zip(entries, tmpFiles).forEach {
        try $0.write(to: $1, atomically: true, encoding: .utf8)
    }
    let joinedResults = buildCSV(results, allTypes: allTypes, title: title, labels: labels)
    try joinedResults.write(to: URL(fileURLWithPath: "\(resultFileName).csv"), atomically: true, encoding: .utf8)

    func plot(logscale: Bool, resultFileName: String) throws {
        var conf = GnuPlot.Configuration()
        if logscale {
            conf.set(property: .logscale, value: "y 10")
        }
        conf.set(option: GnuPlot.Key(position: .outside, autotitle: .init(isOn: true, isColumnhead: true)))
        conf.set(option: GnuPlot.Title(title))
        conf.set(option: GnuPlot.Label(name: .ylabel, value: "t (s)"))
        conf.set(option: .line)
        try GnuPlot.run(files: tmpFiles.map { $0.path }, configuration: conf, resultFileName: resultFileName, open: false)
    }

    try plot(logscale: false, resultFileName: resultFileName)

    if logscale {
        try plot(logscale: true, resultFileName: resultFileName + "_log")
    }

    try tmpFiles.forEach {
        try FileManager.default.removeItem(at: $0)
    }
}

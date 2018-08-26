//
//  GNUPlot.swift
//  Bench
//
//  Created by Damian Malarczyk on 09/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

public protocol GnuPlotTerminal: CustomStringConvertible {

    var fileExtension: String { get }
}

public protocol GnuPlotOption: CustomStringConvertible {}
public protocol SetGnuPlotOption: GnuPlotOption {}

public enum GnuPlot {

    public enum Property: String {

        case logscale = "logscale", linestyle = "style line"

        var escapesValue: Bool {
            switch self {
            case .logscale, .linestyle:
                return false
            }
        }
    }

    public enum PlotOption {

        case line
        case pointtype(String)
    }

    public struct Configuration {

        fileprivate var properties: [(Property, String)] = []
        fileprivate var plotOptions: [PlotOption] = []
        fileprivate var setOptions: [SetGnuPlotOption] = []
        var terminal: GnuPlotTerminal = SVGTerminal()

        public init() {
            set(option: SimpleOption(name: .datafileSeparator, value: ","))
            set(option: SimpleOption(name: .decimalsign, value: "."))
        }

        public mutating func set(option: PlotOption) {
            plotOptions.append(option)
        }

        public mutating func set(option: SetGnuPlotOption) {
            setOptions.append(option)
        }

        public mutating func set(property: Property, value: String) {
            properties.append((property, value))
        }
    }

    static var colors: ValueStream<String> {
        return ["blue", "green", "red", "purple", "gray", "black"]
    }

    static private func runGnuPlotfile(_ cmd: String, resultFile: String, open: Bool) throws {
        let gnuplotFile = ".tmp.gnuplot"
        try cmd.write(toFile: gnuplotFile, atomically: true, encoding: .utf8)
        Shell.run(.gnuplot, blocks: true, args: gnuplotFile)
        try? FileManager.default.removeItem(atPath: gnuplotFile)

        if open {
            Shell.run(.open, blocks: false, args: resultFile)
        } else {
            let resultURL = URL(fileURLWithPath: resultFile)
            print("GnuPlot output at: \(resultURL.path)")
        }
    }

    public static func run(files: [String], configuration conf: Configuration, labels: [String]? = nil, resultFileName: String = "result", open: Bool = true) throws {
        guard !files.isEmpty else { return }

        let resultFile = "\(resultFileName).\(conf.terminal.fileExtension)"
        let setKeyword = "set"
        var cmd = """
        \(setKeyword) terminal \(conf.terminal)
        \(setKeyword) output \(escape(resultFile))

        """
        let colors = GnuPlot.colors
        let newlineString = Character.newline.asString

        func addLine(_ string: String) {
            cmd += string + newlineString
        }

        var hasLineStyle: Bool = false
        conf.properties.map { (property, value) -> String in
            if case .linestyle = property {
                hasLineStyle = true
            }

            let value = property.escapesValue ? escape(value) : value
            return "\(setKeyword) \(property.rawValue) \(value)"
        }.forEach(addLine)

        conf.setOptions.forEach {
            addLine("\(setKeyword) \($0)")
        }

        if !hasLineStyle {
            // apply default line styling if none defined
            let linestyle = Property.linestyle
            files.enumerated().forEach { i, _ in
                addLine("\(setKeyword) \(linestyle.rawValue) \(i + 1) linecolor rgb \(escape(colors.next)) linewidth 2")
            }
        }

        cmd += "plot"
        
        for (i, f) in files.enumerated() {
            cmd += " \"\(f)\""
            conf.plotOptions.forEach {
                switch $0 {
                case .line:
                    cmd += " with lines"
                case .pointtype(let type):
                    cmd += " with points pointtype \(type)"
                }
            }
            cmd += "\(labels.map { Title($0[i]) }.leadingWhitespaceDescription) ls \(i + 1),"
        }
        cmd = String(cmd.dropLast())

        try runGnuPlotfile(cmd, resultFile: resultFile, open: open)
    }

    public static func run(file: String, configuration: Configuration, open: Bool = true) throws {
        try run(files: [file], configuration: configuration, open: open)
    }
}

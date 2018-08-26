//
//  GNUPlot+Options.swift
//  Bench
//
//  Created by Damian Malarczyk on 09/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

extension GnuPlot {

    public struct Title: SetGnuPlotOption, CustomStringConvertible {

        public let title: String

        public var description: String {
            return "title \(escape(title))"
        }

        public init(_ title: String) {
            self.title = title
        }
    }

    public struct Size: GnuPlotOption, CustomStringConvertible {

        public let width: Int
        public let height: Int

        public var description: String {
            return "size \(width),\(height)"
        }

        public init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }

    public struct Label: SetGnuPlotOption, CustomStringConvertible {

        public enum Name: CustomStringConvertible {

            case xlabel, ylabel, other(String)

            public var description: String {
                switch self {
                case .xlabel: return "xlabel"
                case .ylabel: return "ylabel"
                case .other(let val): return val
                }
            }
        }

        public let name: Name
        public let value: String

        public var description: String {
            return "\(name) \(escape(value))"
        }

        public init(name: Name, value: String) {
            self.name = name
            self.value = value
        }
    }

    public struct SimpleOption: SetGnuPlotOption, CustomStringConvertible {

        public struct Name: CustomStringConvertible {

            public static let decimalsign = Name("decimalsign")
            public static let datafileSeparator = Name("datafile separator")

            public let raw: String

            public var description: String {
                return "\(raw)"
            }

            public init(_ raw: String) {
                self.raw = raw
            }
        }

        public let name: Name
        public let value: String

        public var description: String {
            return "\(name) \(escape(value))"
        }

        public init(name: Name, value: String) {
            self.name = name
            self.value = value
        }
    }

    public struct Key: SetGnuPlotOption, CustomStringConvertible {

        public enum Position: String, CustomStringConvertible {

            case inside, outside

            public var description: String {
                return self.rawValue
            }
        }

        public struct Autotile: CustomStringConvertible {

            public let isOn: Bool
            public let isColumnhead: Bool

            public var description: String {
                guard isOn else { return "noautotitle" }

                return "autotitle\(isColumnhead ? " columnhead" : "")"
            }

            public init(isOn: Bool, isColumnhead: Bool) {
                self.isOn = isOn
                self.isColumnhead = isColumnhead
            }
        }

        public let position: Position
        public let autotitle: Autotile

        public var description: String {
            return "key on \(position) \(autotitle)"
        }

        public init(position: Position, autotitle: Autotile) {
            self.position = position
            self.autotitle = autotitle
        }
    }

    static func escape(_ value: String) -> String {
        return "\"\(value)\""
    }
}

extension Optional: CustomStringConvertible where Wrapped: GnuPlotOption {

    public var description: String {
        switch self {
        case .none:
            return ""
        case .some(let val):
            return "\(val)"
        }
    }

    public var leadingWhitespaceDescription: String {
        switch self {
        case .none:
            return ""
        case .some(let val):
            return " \(val)"
        }
    }
}

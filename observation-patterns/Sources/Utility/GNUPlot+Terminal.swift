//
//  GNUPlot+Terminal.swift
//  Bench
//
//  Created by Damian Malarczyk on 09/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

public extension GnuPlot {

    public static let kDefaultTerminalSize = GnuPlot.Size(width: 1920, height: 1080)

    public struct Font {

        public struct Face: CustomStringConvertible {

            public static let arial = Face("arial")

            public let raw: String

            public init(_ raw: String) {
                self.raw = raw
            }

            public var description: String {
                return raw
            }
        }

        public let face: Face
        public let size: Int

        public var whitespaceDescription: String {
            return "font \(face) \(size)"
        }

        public var escapedDescription: String {
            return "font \"\(face),\(size)\""
        }

        public init(face: Face, size: Int) {
            self.face = face
            self.size = size
        }
    }

    public struct PNGTerminal: GnuPlotTerminal, CustomStringConvertible {

        public let size: Size
        public let font: Font

        public var fileExtension: String {
            return "png"
        }

        public var description: String {
            return "png \(font.whitespaceDescription) \(size)"
        }

        public init(size: Size = kDefaultTerminalSize, font: Font = GnuPlot.Font(face: .arial, size: 14)) {
            self.size = size
            self.font = font
        }
    }

    public struct SVGTerminal: GnuPlotTerminal, CustomStringConvertible {

        public enum SizeType: String {
            case fixed, dynamic
        }

        public let size: Size
        public let sizeType: SizeType
        public let font: Font

        public var fileExtension: String {
            return "svg"
        }

        public var description: String {
            return "svg \(size) \(sizeType) \(font.escapedDescription)"
        }

        public init(size: Size = kDefaultTerminalSize, sizeType: SizeType = .dynamic, font: Font = GnuPlot.Font(face: .arial, size: 22)) {
            self.size = size
            self.sizeType = sizeType
            self.font = font
        }
    }
}

extension GnuPlot.Font.Face: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

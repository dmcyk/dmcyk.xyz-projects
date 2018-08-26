//
//  Utils.swift
//  KVOBench
//
//  Created by Damian Malarczyk on 25/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

public class Utils {

    public static func measureTime(_ block: () -> Void) -> TimeInterval {
        let startTime = mach_absolute_time()

        block()

        let timeElapsed = mach_absolute_time() - startTime
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)

        let elapsedNano = timeElapsed * UInt64(info.denom / info.denom)
        let seconds = Double(elapsedNano) / pow(10, 9)

        return seconds
    }

    public static func buildCSV(labels: [String], data: [[String]], names: [String] = [], separator: String = ",", escapeNumeric shouldEscapeNumeric: Bool = false) -> String {
        var str = ""
        let textEscapeCh = "\""
        let numberEscapeCh = shouldEscapeNumeric ? textEscapeCh : ""
        let newlineCh = Character.newline.asString

        func escape(_ input: String, numeric: Bool = false) -> String {
            let escapeCh = numeric ? numberEscapeCh : textEscapeCh
            return "\(escapeCh)\(input)\(escapeCh)"
        }

        if !names.isEmpty {
            str = names.map { escape($0) }.joined(separator: separator)
            str += newlineCh
        }

        str += zip(labels, data).map { (l, d) in
            var o = escape(l)
            if !d.isEmpty {
                o += separator
                o += d.map { escape($0, numeric: true)}.joined(separator: separator)
            }
            return o
        }.joined(separator: newlineCh)

        return str
    }
}

extension Array where Element: RandomAccessCollection {

    public func getColumns() -> [[Element.Element]] {
        guard let first = self.first else { return [] }

        return (0 ..< first.count).map { i -> [Element.Element] in
            (0 ..< self.count).map { j -> Element.Element in
                let elements = self[j]
                let index = elements.index(elements.startIndex, offsetBy: i)
                return elements[index]
            }
        }
    }
}

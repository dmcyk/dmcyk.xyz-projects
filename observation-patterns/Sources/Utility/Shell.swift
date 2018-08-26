//
//  Shell.swift
//  chaosoffline
//
//  Created by Damian Malarczyk on 15/12/2017.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

open class Shell {

    open class var binPaths: [String] {
        return [
            "/usr/local/sbin",
            "/usr/local/bin",
            "/usr/sbin",
            "/usr/bin",
            "/sbin",
            "/bin"
        ]
    }

    public static let envPath: String = {
        for path in binPaths {
            let envPath = (path.appending("/env") as NSString).resolvingSymlinksInPath

            if FileManager.default.isExecutableFile(atPath: envPath) {
                return envPath
            }
        }

        fatalError("Couldn't find `env` executable")
    }()

    open class var environment: [String: String] {
        var envShell = ProcessInfo.processInfo.environment
        envShell["PATH"] = binPaths.joined(separator: ":")
        return envShell
    }

    @discardableResult
    open class func run(_ name: String, blocks: Bool = false, args: [String]) -> Process {
        let task = Process()
        task.launchPath = envPath
        task.environment = environment
        task.arguments = [name] + args
        task.launch()

        if blocks {
            task.waitUntilExit()
        }
        return task
    }

    @discardableResult
    open class func run(_ name: String, blocks: Bool = false, args: String...) -> Process {
        return run(name, blocks: blocks, args: args)
    }

    @discardableResult
    open class func run(_ clt: CommandLineTool, blocks: Bool = false, args: [String]) -> Process {
        return run(clt.name, blocks: blocks, args: args)
    }

    @discardableResult
    open class func run(_ clt: CommandLineTool, blocks: Bool = false, args: String...) -> Process {
        return run(clt, blocks: blocks, args: args)
    }

    public struct CommandLineTool {

        public static let open = CommandLineTool(name: "open")
        public static let gnuplot = CommandLineTool(name: "gnuplot")

        public let name: String

        public init(name: String) {
            self.name = name
        }
    }
}

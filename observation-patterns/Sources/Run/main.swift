
import Foundation
import Bench
import ObjCConsumer
import Console

do {
    let console = Console(
        commands: [
            BenchCommand(),
            KVOCommand()
        ]
    )

    try console.run(arguments: CommandLine.arguments)
} catch {
    print(error.localizedDescription)
}

import os

/// Logging facade: every entry goes to both Apple's unified logging (view with
/// Console.app or `/usr/bin/log`) and the on-disk file at
/// `~/Library/Logs/Umbra/Umbra.log` (via `FileLog`).
enum Log {
    static let subsystem = "com.umbramacos.app"

    enum Category: String { case app, overlay, dock }

    static func write(_ category: Category, _ message: String) {
        Logger(subsystem: subsystem, category: category.rawValue)
            .notice("\(message, privacy: .public)")
        FileLog.shared.append(category: category.rawValue, message: message)
    }

    static func app(_ message: String) { write(.app, message) }
    static func overlay(_ message: String) { write(.overlay, message) }
    static func dock(_ message: String) { write(.dock, message) }
}

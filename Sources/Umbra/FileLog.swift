import Foundation

/// Appends timestamped lines to `~/Library/Logs/Umbra/Umbra.log` so
/// problems can be captured to a file without a live `log stream`. Writes are
/// serialized on a private queue; the file is reset if it grows past ~1 MB.
final class FileLog: @unchecked Sendable {
    static let shared = FileLog()

    let fileURL: URL
    private let queue = DispatchQueue(label: "com.umbramacos.app.filelog")
    private let formatter: DateFormatter

    private init() {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/Umbra", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("Umbra.log")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        self.formatter = formatter

        if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let size = attrs[.size] as? Int, size > 1_000_000 {
            try? "".write(to: fileURL, atomically: true, encoding: .utf8)
        }
        append(category: "app", message: "=== session start ===")
    }

    func append(category: String, message: String) {
        let now = Date()
        queue.async {
            let line = "\(self.formatter.string(from: now)) [\(category)] \(message)\n"
            guard let data = line.data(using: .utf8) else { return }
            if let handle = try? FileHandle(forWritingTo: self.fileURL) {
                defer { try? handle.close() }
                handle.seekToEndOfFile()
                handle.write(data)
            } else {
                try? data.write(to: self.fileURL)
            }
        }
    }
}

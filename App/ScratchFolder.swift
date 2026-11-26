import Foundation

/// A throwaway folder under the temporary directory for scenarios that need a
/// store file on disk. Each call gets its own folder, so screens and tests
/// never share a file by accident.
enum ScratchFolder {
    static func storeURL(named name: String) -> URL {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("multivitamin-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("\(name).store")
    }

    /// Removes the store file's folder, which also holds the SQLite sidecar files.
    static func discard(_ storeURL: URL) {
        try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
    }

    static func sidecarNames(beside storeURL: URL) -> [String] {
        let names = try? FileManager.default.contentsOfDirectory(atPath: storeURL.deletingLastPathComponent().path)
        return (names ?? []).sorted()
    }
}

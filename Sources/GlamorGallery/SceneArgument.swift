#if os(macOS)
/// What a launch's arguments say about the scene (`--scene <name>` or `--scene=<name>`).
enum SceneArgument: Equatable {
    /// No scene argument: the gallery shows its fallback scene.
    case absent
    /// A scene name; whether the gallery knows it is decided by `GalleryScenes`.
    case name(String)
    /// An argument that starts with `--scene` but gives no name (or is not `--scene` itself), as typed.
    case malformed(String)

    /// Reads `CommandLine.arguments` (the first word is the program). The first argument that starts with `--scene` decides.
    static func parse(_ args: [String]) -> SceneArgument {
        let words = Array(args.dropFirst())
        guard let i = words.firstIndex(where: { $0.hasPrefix("--scene") }) else { return .absent }
        let word = words[i]
        if word == "--scene" {
            guard i + 1 < words.count, !words[i + 1].hasPrefix("--") else { return .malformed(word) }
            return .name(words[i + 1])
        }
        if word.hasPrefix("--scene=") {
            let name = word.dropFirst("--scene=".count)
            return name.isEmpty ? .malformed(word) : .name(String(name))
        }
        return .malformed(word)
    }
}
#endif

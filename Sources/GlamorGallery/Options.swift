#if os(macOS)
import AppKit

// Launch arguments, for scripts/check-window.sh (they change only this app, never the system settings):
//   --scene <name>            which scene the window shows (default: components; the names are in GalleryScenes);
//                             --scene=<name> works too, and any argument that starts with --scene must give a name
//   --appearance light|dark   the app's own appearance
//   --increase-contrast       draws the Increase contrast colours (IncreasedContrast.forced, debug builds only)
//   --open-sheet              opens a sheet at launch (scripts/check-window.sh reads its title as a heading)
//   --log-activations         puts the last activated control's name and a count in the window title, and prints
//                             the accessibility environment the views received
//
// SwiftUI's accessibilityReduceTransparency and colorSchemeContrast are read-only environment values, so they
// cannot be set from here, and the high-contrast NSAppearance names are not honoured for an app whose system
// setting is off: what the views received is printed, and the check script reports it.
struct Options {
    static let args = CommandLine.arguments
    static let increaseContrast = args.contains("--increase-contrast")
    static let logActivations = args.contains("--log-activations")
    static let openSheet = args.contains("--open-sheet")
    static let scene = SceneArgument.parse(args)
    static var appearance: NSAppearance.Name? {
        guard let i = args.firstIndex(of: "--appearance"), i + 1 < args.count else { return nil }
        return args[i + 1] == "dark" ? .darkAqua : .aqua
    }
}
#endif

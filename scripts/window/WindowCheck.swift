// Checks of the running GlamorGallery window, driven by scripts/check-window.sh.
//
// Each takes an optional last argument, the scene the gallery was started with (`GlamorGallery --scene <name>`,
// default `components`). A scene has its own list of controls and its own modes: see `scenes` below.
//
//   windowcheck pixels <pid> <theme> <out-dir>    pixel contrast and the label-to-icon gap, from a capture of that window only
//   windowcheck strings <pid> <theme> <out-dir>   VoiceOver strings and AXPress activation, from the accessibility tree;
//                                                 after the presses: the theme switch's new name, the clear button after
//                                                 typing with key events, the unlabelled spinner's name (AXBusyIndicator)
//   windowcheck sheet <pid> <theme> <out-dir>     the title of the sheet the gallery opens with --open-sheet, read as a heading
//   windowcheck keys <pid> <theme> <out-dir>      Tab order, Space and Return
//   windowcheck ready <pid> [scene]               exits 0 once the window is on screen with its controls
//
// Every line it prints starts with CHECK, NOTE or UNPROVEN. A CHECK line ends in PASS or FAIL; any FAIL
// makes the exit status 1. UNPROVEN means the system would not let the check run without changing a setting
// this script never touches. Needs the Accessibility and Screen Recording permissions of the calling app.
import AppKit
import ApplicationServices
import CoreGraphics
import Foundation
import ImageIO

var failures = 0
var log: [String] = []

func emit(_ line: String) {
    print(line)
    log.append(line)
}

func check(_ id: String, _ theme: String, _ what: String, _ value: String, _ need: String, _ ok: Bool) {
    if !ok { failures += 1 }
    emit("CHECK\t\(id)\t\(theme)\t\(what)\t\(value)\t\(need)\t\(ok ? "PASS" : "FAIL")")
}

func note(_ id: String, _ theme: String, _ text: String) { emit("NOTE\t\(id)\t\(theme)\t\(text)") }
func unproven(_ id: String, _ theme: String, _ text: String) { emit("UNPROVEN\t\(id)\t\(theme)\t\(text)") }

// MARK: Accessibility tree

func attr(_ e: AXUIElement, _ name: String) -> AnyObject? {
    var v: CFTypeRef?
    return AXUIElementCopyAttributeValue(e, name as CFString, &v) == .success ? v : nil
}

func text(_ e: AXUIElement, _ name: String) -> String { attr(e, name) as? String ?? "" }

func axFrame(_ e: AXUIElement) -> CGRect? {
    guard let p = attr(e, "AXPosition"), let s = attr(e, "AXSize") else { return nil }
    var pt = CGPoint.zero, sz = CGSize.zero
    AXValueGetValue(p as! AXValue, .cgPoint, &pt)
    AXValueGetValue(s as! AXValue, .cgSize, &sz)
    return CGRect(origin: pt, size: sz)
}

/// The element and everything below it. The tree is read once per element (a repeated element is skipped) and to a
/// fixed depth, so a cycle in the accessibility tree ends the walk instead of overflowing the stack.
func descendants(_ e: AXUIElement) -> [AXUIElement] {
    var out: [AXUIElement] = []
    func walk(_ el: AXUIElement, _ depth: Int) {
        guard depth < 60, !out.contains(where: { CFEqual($0, el) }) else { return }
        out.append(el)
        for child in (attr(el, "AXChildren") as? [AXUIElement]) ?? [] { walk(child, depth + 1) }
    }
    walk(e, 0)
    return out
}

struct Control {
    let element: AXUIElement
    var role: String { text(element, "AXRole") }
    var subrole: String { text(element, "AXSubrole") }
    var roleDescription: String { text(element, "AXRoleDescription") }
    var description: String { text(element, "AXDescription") }
    var title: String { text(element, "AXTitle") }
    var help: String { text(element, "AXHelp") }
    /// AXValue as text. A switch is guessed to read "1" (on) or "0" (off): not yet seen on this macOS, proven by the owner's window run.
    var value: String { attr(element, "AXValue").map { "\($0)" } ?? "" }
    var placeholder: String { text(element, "AXPlaceholderValue") }
    var selected: Bool { (attr(element, "AXSelected") as? Bool) == true }
    var enabled: Bool { (attr(element, "AXEnabled") as? Bool) != false }
    var frame: CGRect { axFrame(element) ?? .zero }
    /// What VoiceOver reads first: the description, else the title, else a text field's placeholder.
    var name: String { [description, title, placeholder].first { !$0.isEmpty } ?? "" }
    var nameSource: String {
        if !description.isEmpty { return "AXDescription" }
        if !title.isEmpty { return "AXTitle" }
        return placeholder.isEmpty ? "none" : "AXPlaceholderValue"
    }
}

struct Target {
    let pid: pid_t
    let theme: String
    let out: URL
    let scene: SceneSpec
    let app: AXUIElement
    let window: AXUIElement

    init(pid: pid_t, theme: String, out: URL, scene: SceneSpec) {
        self.pid = pid
        self.theme = theme
        self.out = out
        self.scene = scene
        app = AXUIElementCreateApplication(pid)
        guard let w = (attr(app, "AXWindows") as? [AXUIElement])?.first else {
            FileHandle.standardError.write(Data("no window for pid \(pid)\n".utf8))
            exit(2)
        }
        window = w
    }

    var controls: [Control] {
        descendants(window).map(Control.init).filter {
            (["AXButton", "AXMenuButton", "AXTextField"].contains($0.role) && $0.subrole.isEmpty)
                // UNPROVEN: a SwiftUI Toggle with .toggleStyle(.switch) is guessed to read AXCheckBox, subrole AXSwitch (or none).
                // Not yet seen on this macOS; proven by the owner's window run (`strings` prints "switch-ax" with what was read).
                || ($0.role == "AXCheckBox" && ["", "AXSwitch"].contains($0.subrole))
        }
    }

    /// Text that is not a control (a mark's "Pro", a section's label): the tree's static texts, by their spoken string.
    var staticTexts: [String] {
        descendants(window).filter { text($0, "AXRole") == "AXStaticText" }.map(spokenName).filter { !$0.isEmpty }
    }

    /// What a popover (the profile menu) holds, by role and spoken name; empty when none is open.
    var popoverChildren: [(role: String, name: String)] {
        descendants(window).filter { text($0, "AXRole") == "AXPopover" }
            .flatMap { descendants($0).dropFirst() }
            .map { (text($0, "AXRole"), spokenName($0)) }
    }

    /// A control by any of the strings it carries: VoiceOver may read the description or the title.
    func control(_ name: String) -> Control? {
        controls.first { $0.name == name } ?? controls.first { $0.description == name || $0.title == name }
    }
    var windowTitle: String { text(window, "AXTitle") }
    var focused: Control? { (attr(app, "AXFocusedUIElement")).map { Control(element: $0 as! AXUIElement) } }

    func focus(_ c: Control) -> Bool {
        AXUIElementSetAttributeValue(c.element, "AXFocused" as CFString, kCFBooleanTrue)
        usleep(250_000)
        guard let f = attr(app, "AXFocusedUIElement") else { return false }
        return CFEqual(f, c.element)
    }

    func press(_ code: CGKeyCode, shift: Bool = false) {
        for down in [true, false] {
            let e = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: down)!
            if shift { e.flags = .maskShift }
            e.postToPid(pid)
            usleep(40_000)
        }
        usleep(350_000)
    }

    /// Types the letters w, e and b with real key events (the same path as press), each carrying its character, so
    /// the focused text field receives them as typing and SwiftUI's text binding changes. The first run set
    /// AXValue instead and saw no clear button; this path was read from the live tree to show it.
    func type(_ letters: String) {
        let codes: [Character: CGKeyCode] = ["w": 13, "e": 14, "b": 11]
        for letter in letters {
            guard let code = codes[letter] else { continue }
            for down in [true, false] {
                let e = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: down)!
                var unit = Array(String(letter).utf16)
                e.keyboardSetUnicodeString(stringLength: unit.count, unicodeString: &unit)
                e.postToPid(pid)
                usleep(40_000)
            }
            usleep(250_000)
        }
    }
}

// MARK: Capture and pixels

struct Shot {
    let width: Int, height: Int
    let rgba: [UInt8]
    let scale: Double
    let origin: CGPoint   // the window's top-left, in screen points

    func px(_ x: Int, _ y: Int) -> (r: Double, g: Double, b: Double) {
        let x = min(max(x, 0), width - 1), y = min(max(y, 0), height - 1)
        let i = (y * width + x) * 4
        return (Double(rgba[i]) / 255, Double(rgba[i + 1]) / 255, Double(rgba[i + 2]) / 255)
    }

    /// A screen point (as the accessibility tree reports it) to a pixel of the capture.
    func pixel(_ p: CGPoint) -> (x: Int, y: Int) {
        (Int(((p.x - origin.x) * scale).rounded()), Int(((p.y - origin.y) * scale).rounded()))
    }
}

typealias RGB = (r: Double, g: Double, b: Double)

func lum(_ c: RGB) -> Double {
    func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b)
}

func ratio(_ a: RGB, _ b: RGB) -> Double {
    let (x, y) = (lum(a), lum(b))
    return (max(x, y) + 0.05) / (min(x, y) + 0.05)
}

func hex(_ c: RGB) -> String {
    String(format: "#%02X%02X%02X", Int((c.r * 255).rounded()), Int((c.g * 255).rounded()), Int((c.b * 255).rounded()))
}

/// Captures the one window by its id, never the screen, and reads it as sRGB.
func capture(_ t: Target, name: String) -> Shot {
    let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
    guard let w = list.first(where: { ($0[kCGWindowOwnerPID as String] as? Int32) == t.pid && ($0[kCGWindowLayer as String] as? Int) == 0 }),
          let number = w[kCGWindowNumber as String] as? Int,
          let bounds = (w[kCGWindowBounds as String] as? NSDictionary).flatMap({ CGRect(dictionaryRepresentation: $0) }) else {
        FileHandle.standardError.write(Data("window of pid \(t.pid) is not on screen\n".utf8))
        exit(2)
    }
    let file = t.out.appendingPathComponent("\(name).png")
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    p.arguments = ["-l", String(number), "-o", "-x", file.path]
    try? p.run()
    p.waitUntilExit()
    guard p.terminationStatus == 0, let src = CGImageSourceCreateWithURL(file as CFURL, nil),
          let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
        FileHandle.standardError.write(Data("screencapture failed (Screen Recording permission?)\n".utf8))
        exit(2)
    }
    let w8 = img.width, h8 = img.height
    var data = [UInt8](repeating: 0, count: w8 * h8 * 4)
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    data.withUnsafeMutableBytes { buf in
        let ctx = CGContext(data: buf.baseAddress, width: w8, height: h8, bitsPerComponent: 8, bytesPerRow: w8 * 4, space: space,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.draw(img, in: CGRect(x: 0, y: 0, width: w8, height: h8))
    }
    return Shot(width: w8, height: h8, rgba: data, scale: Double(w8) / bounds.width, origin: bounds.origin)
}

struct InkReading { let ink: RGB; let ground: RGB; let typical: Double; let worst: Double }

/// The strongest ink in a region against the ground that fills most of it. `typical` is ink against the median
/// ground pixel. `worst` is ink against the weakest pixel within 12% of that ground (so a glass gradient counts,
/// anti-aliased ink does not).
func readInk(_ s: Shot, rect: CGRect) -> InkReading {
    let a = s.pixel(rect.origin), b = s.pixel(CGPoint(x: rect.maxX, y: rect.maxY))
    var all: [RGB] = []
    for y in a.y..<b.y { for x in a.x..<b.x { all.append(s.px(x, y)) } }
    let ground = all.sorted { lum($0) < lum($1) }[all.count / 2]
    let ink = all.max { ratio($0, ground) < ratio($1, ground) }!
    let top = ratio(ink, ground)
    let ground2 = all.filter { ratio($0, ground) < 1.12 }
    let worst = ground2.map { ratio(ink, $0) }.min() ?? top
    return InkReading(ink: ink, ground: ground, typical: top, worst: worst)
}

func f2(_ v: Double) -> String { String(format: "%.2f", v) }

/// The shortest distance between two frames in points: 0 when they touch or overlap.
func frameGap(_ a: CGRect, _ b: CGRect) -> Double {
    let dx = max(0, a.minX - b.maxX, b.minX - a.maxX)
    let dy = max(0, a.minY - b.maxY, b.minY - a.maxY)
    return Double((dx * dx + dy * dy).squareRoot())
}

// MARK: Modes

func pixelsMode(_ t: Target) {
    let theme = t.theme
    // The search field must not be focused: its edge is the unfocused one (GL17). Focus a menu button instead.
    if let more = t.controls.first(where: { $0.title.hasPrefix("More") || $0.description.hasPrefix("More") }) { _ = t.focus(more) }
    guard let field = t.controls.first(where: { $0.role == "AXTextField" }),
          let deploy = t.control("Deploy"), let daily = t.controls.first(where: { $0.title == "Daily" }),
          let host = descendants(t.window).first(where: { text($0, "AXSubrole") == "AXHostingView" }) else {
        let have = t.controls.map { "\($0.name) (\($0.role))" }.joined(separator: ", ")
        let hosting = descendants(t.window).contains { text($0, "AXSubrole") == "AXHostingView" }
        check("setup", theme, "gallery controls found", "missing; hosting view \(hosting ? "present" : "absent"), controls read: \(have.isEmpty ? "none" : have)", "a text field, Deploy, Daily, a hosting view", false); return
    }
    check("setup", theme, "search field is not focused when measured", (attr(field.element, "AXFocused") as? Bool) == true ? "focused" : "unfocused", "unfocused",
          (attr(field.element, "AXFocused") as? Bool) != true)
    let shot = capture(t, name: theme)
    note("shot", theme, "\(t.out.path)/\(theme).png, \(shot.width)x\(shot.height) px, scale \(f2(shot.scale))")

    // 1a. Search placeholder against the field ground (4.5:1).
    let hostFrame = axFrame(host) ?? .zero
    let bar = CGRect(x: hostFrame.minX + 24, y: field.frame.midY - 20, width: hostFrame.width - 48, height: 40)
    let ph = readInk(shot, rect: CGRect(x: field.frame.minX, y: field.frame.minY - 2, width: 110, height: field.frame.height + 4))
    check("placeholder", theme, "search placeholder ink \(hex(ph.ink)) on field \(hex(ph.ground))", f2(ph.typical) + ":1", ">= 4.5:1", ph.typical >= 4.5)
    if ph.worst < 4.5 { note("placeholder", theme, "against the weakest ground pixel the ratio is \(f2(ph.worst)):1") }

    // 1b. Deploy label against its glass fill (4.5:1). The accessibility frame is the whole 32 pt button; a frame
    // that is only the label (16 pt high) is widened by the button's 12 pt side padding.
    let whole = deploy.frame.height >= 30
    let buttonRect = (whole ? deploy.frame : CGRect(x: deploy.frame.minX - 12, y: deploy.frame.midY - 16, width: deploy.frame.width + 24, height: 32)).insetBy(dx: 5, dy: 5)
    let dp = readInk(shot, rect: buttonRect)
    check("deploy-label", theme, "Deploy label ink \(hex(dp.ink)) on fill \(hex(dp.ground))", f2(dp.typical) + ":1", ">= 4.5:1", dp.typical >= 4.5)
    if dp.worst < 4.5 { note("deploy-label", theme, "against the weakest fill pixel the ratio is \(f2(dp.worst)):1") }

    // 1c. Unfocused search field edge against the surface around it (3:1, GL17): top, left and right edges
    // (the bottom edge sits in the glass's own shadow, so it is reported but does not decide).
    typealias Edge = (name: String, ratio: Double, edge: RGB, surround: RGB, decides: Bool)
    func edge(_ name: String, decides: Bool, along: (Int) -> (x: Int, y: Int), outward: Int, at: Int) -> Edge {
        let outside = along(at - outward * Int((7 * shot.scale).rounded()))
        let surround = shot.px(outside.x, outside.y)
        var best: (ratio: Double, color: RGB) = (0, surround)
        let reach = Int((4 * shot.scale).rounded())
        for d in -reach...reach {
            let p = along(at + d), c = shot.px(p.x, p.y)
            let r = ratio(c, surround)
            if r > best.ratio { best = (r, c) }
        }
        return (name, best.ratio, best.color, surround, decides)
    }
    let topLeft = shot.pixel(CGPoint(x: bar.minX, y: bar.minY)), bottomRight = shot.pixel(CGPoint(x: bar.maxX, y: bar.maxY))
    let midX = (topLeft.x + bottomRight.x) / 2, midY = (topLeft.y + bottomRight.y) / 2
    let sides: [Edge] = [
        edge("top", decides: true, along: { (midX, $0) }, outward: 1, at: topLeft.y),
        edge("left", decides: true, along: { ($0, midY) }, outward: 1, at: topLeft.x),
        edge("right", decides: true, along: { ($0, midY) }, outward: -1, at: bottomRight.x),
        edge("bottom", decides: false, along: { (midX, $0) }, outward: -1, at: bottomRight.y),
    ]
    for (name, r, edgeColor, surround, decides) in sides.map({ ($0.name, $0.ratio, $0.edge, $0.surround, $0.decides) }) {
        let what = "unfocused search edge (\(name)) \(hex(edgeColor)) vs surround \(hex(surround))"
        if decides { check("search-edge", theme, what, f2(r) + ":1", ">= 3:1", r >= 3) } else { note("search-edge", theme, what + ": \(f2(r)):1") }
    }

    // 2. Label-to-icon gap on the Daily menu button, ink to ink, in pixels (8 pt times the backing scale).
    let region = CGRect(x: daily.frame.minX - 3, y: daily.frame.minY - 3, width: daily.frame.width + 6, height: daily.frame.height + 6)
    let a = shot.pixel(region.origin), b = shot.pixel(CGPoint(x: region.maxX, y: region.maxY))
    var cells: [RGB] = []
    for y in a.y..<b.y { for x in a.x..<b.x { cells.append(shot.px(x, y)) } }
    let ground = cells.sorted { lum($0) < lum($1) }[cells.count / 2]
    let top = cells.map { ratio($0, ground) }.max() ?? 1
    func isInk(_ x: Int, _ y: Int) -> Bool { ratio(shot.px(x, y), ground) > 1 + (top - 1) * 0.35 }
    var runs: [(start: Int, end: Int, top: Int, bottom: Int)] = []
    for x in a.x..<b.x {
        let rows = (a.y..<b.y).filter { isInk(x, $0) }
        guard let first = rows.first, let last = rows.last else { continue }
        if let r = runs.last, r.end == x - 1 { runs[runs.count - 1] = (r.start, x, min(r.top, first), max(r.bottom, last)) } else { runs.append((x, x, first, last)) }
    }
    let pt = 8.0 * shot.scale
    // The chevron is the one run wider than it is tall; the gap is between it and the next run (the word).
    if let ci = runs.firstIndex(where: { ($0.end - $0.start + 1) > ($0.bottom - $0.top + 1) }) {
        let neighbour = ci == 0 ? ci + 1 : ci - 1
        let gap = ci == 0 ? runs[neighbour].start - runs[ci].end - 1 : runs[ci].start - runs[neighbour].end - 1
        let side = ci == 0 ? "chevron first" : "chevron last"
        check("label-icon-gap", theme, "Daily menu button draws the chevron after the word", side, "chevron last", ci == runs.count - 1)
        // Ink to ink is the layout gap plus the side bearings of the chevron and the letter (about 1 pt each).
        check("label-icon-gap", theme, "Daily menu button, ink gap between label and chevron (\(side), \(runs.count) ink runs)", "\(gap) px = \(f2(Double(gap) / shot.scale)) pt",
              "8 pt = \(Int(pt)) px, bearings allow up to +\(Int((3 * shot.scale).rounded())) px", Double(gap) >= pt - 1 && Double(gap) <= pt + 3 * shot.scale)
    } else {
        check("label-icon-gap", theme, "Daily menu button chevron found", "\(runs.count) runs, none wider than tall", "one chevron", false)
    }

    switchTint(t, shot)
}

/// GL43 (GL27): the ToggleCard's switch is on at launch and drawn in `accentEdge`; its track must stand 3:1 off the card
/// it sits on. The track is the flat colour that fills most of the switch's frame, so it is the most common colour there
/// that is not the card (the knob and the edge are smaller, a glass sheen is not flat). The card ground is read 6 pt to
/// the left of the frame, inside the card's padding.
/// UNPROVEN: that the flat track is the most common non-card colour, and that 6 pt left of the frame is card ground, are
/// guesses; not yet seen on this macOS, proven by the owner's window run (a reading it cannot make ends UNPROVEN).
func switchTint(_ t: Target, _ shot: Shot) {
    let theme = t.theme
    guard let sw = t.control(switchName) else { check("switch-tint", theme, "switch found", "missing", "present", false); return }
    let f = sw.frame
    let ground = shot.px(shot.pixel(CGPoint(x: f.minX - 6, y: f.midY)).x, shot.pixel(CGPoint(x: f.minX - 6, y: f.midY)).y)
    let a = shot.pixel(f.origin), b = shot.pixel(CGPoint(x: f.maxX, y: f.maxY))
    var counts: [String: (n: Int, color: RGB)] = [:]
    for y in a.y..<b.y { for x in a.x..<b.x {
        let c = shot.px(x, y)
        guard ratio(c, ground) > 1.15 else { continue }
        let key = hex(c)
        counts[key] = ((counts[key]?.n ?? 0) + 1, c)
    } }
    guard let track = counts.values.max(by: { $0.n < $1.n }) else {
        unproven("switch-tint", theme, "no pixel in the switch's frame \(Int(f.width))x\(Int(f.height)) pt differs from the card, so the track could not be read"); return
    }
    let r = ratio(track.color, ground)
    check("switch-tint", theme, "switch-on track \(hex(track.color)) on card \(hex(ground))", f2(r) + ":1", ">= 3:1", r >= 3)
}

/// One control a scene must show. `value` is what AXValue reads before anything is pressed (a switch: "1" for on).
struct Expected {
    let name: String
    let role: String
    let selected: Bool
    let pressEvent: String?
    var value: String? = nil
}

/// What one gallery scene (`GlamorGallery --scene <name>`) must show, and the checks that belong to it alone.
/// `expected` is the reading order of its controls: the Tab-order walk, the names and the presses all read it.
/// A mode a scene has no function for is not run: the script says so and stops with status 2.
struct SceneSpec {
    let name: String
    /// Buttons in the tree before `ready` says the window is up.
    let readyButtons: Int
    let expected: [Expected]
    let pixels: ((Target) -> Void)?
    /// Names that only appear after the presses of `strings` (GL30).
    let afterActions: ((Target) -> Void)?
    let sheet: ((Target) -> Void)?
    /// Checks only this scene needs, run at the end of `keys` (a header folded with Space, a row scrolled into view).
    var keys: ((Target) -> Void)? = nil
}

/// The switch of the components scene (GL43). Not translated: the script runs the gallery in English.
let switchName = "Send reports"

let componentsControls: [Expected] = [
    Expected(name: "web-1", role: "AXButton", selected: false, pressEvent: "web-1"),
    Expected(name: "db-primary (selected)", role: "AXButton", selected: true, pressEvent: "db-primary"),
    Expected(name: "queue-3", role: "AXButton", selected: false, pressEvent: "queue-3"),
    Expected(name: "Save", role: "AXButton", selected: false, pressEvent: "Save"),
    Expected(name: "Cancel", role: "AXButton", selected: false, pressEvent: "Cancel"),
    Expected(name: "Daily", role: "AXMenuButton", selected: false, pressEvent: nil),
    Expected(name: "More for web-1", role: "AXMenuButton", selected: false, pressEvent: nil),
    Expected(name: "Deploy", role: "AXButton", selected: false, pressEvent: "Deploy"),
    Expected(name: "Day", role: "AXButton", selected: true, pressEvent: nil),
    Expected(name: "Week", role: "AXButton", selected: false, pressEvent: "segment 1"),
    Expected(name: "Month", role: "AXButton", selected: false, pressEvent: "segment 2"),
    Expected(name: "Switch to dark theme", role: "AXButton", selected: false, pressEvent: "theme dark"),
    Expected(name: "Search hosts", role: "AXTextField", selected: false, pressEvent: nil),
    // UNPROVEN: role AXCheckBox, AXValue "1" and the press toggling it are guesses; not yet seen on this macOS, proven by the owner's window run.
    Expected(name: switchName, role: "AXCheckBox", selected: false, pressEvent: "switch false", value: "1"),
]

/// The sidebar-a scene (GL31 to GL34, GL40): Home, four sections of places, Settings in the footer, in reading order.
/// Names are the gallery's English words and the CLI words; the script runs the gallery in English. A row's press event is
/// its place id (the name in lower case); the row that is chosen at launch has none, since pressing it changes nothing.
let sidebarASections: [(title: String, places: [String])] = [
    ("Targets", ["Host", "Database", "Cache", "Queue", "Storage", "Cluster", "Registry", "VPN", "Cloud"]),
    ("Across types", ["Copy", "Tunnel", "Sessions"]),
    ("Komando's own", ["Snippet", "Credential", "Group", "Policy"]),
    ("About komando", ["Audit", "Doctor", "Agent"]),
]
let sidebarAStart = "Host"
let sidebarACounts = ["Copy": "2 transfers running", "Doctor": "3 findings to review"]

func sidebarARow(_ name: String) -> Expected {
    Expected(name: name, role: "AXButton", selected: name == sidebarAStart, pressEvent: name == sidebarAStart ? nil : name.lowercased(),
             value: sidebarACounts[name])
}

let sidebarAControls: [Expected] = [
    Expected(name: "Hide sidebar", role: "AXButton", selected: false, pressEvent: "hide"),
    Expected(name: "Search", role: "AXButton", selected: false, pressEvent: "search"),
    sidebarARow("Home"),
] + sidebarASections.flatMap { section in
    // A header is folded and opened by the `afterActions` and `keys` checks, so the press loop does not touch it.
    [Expected(name: section.title, role: "AXButton", selected: false, pressEvent: nil, value: "expanded")] + section.places.map(sidebarARow)
} + [sidebarARow("Settings")]

let scenes: [String: SceneSpec] = [
    "components": SceneSpec(name: "components", readyButtons: 10, expected: componentsControls,
                            pixels: pixelsMode, afterActions: afterActionStrings, sheet: sheetMode),
    "sidebar-a": SceneSpec(name: "sidebar-a", readyButtons: 27, expected: sidebarAControls,
                           pixels: sidebarAPixels, afterActions: sidebarAAfterActions, sheet: nil, keys: sidebarAKeys),
]

func stringsMode(_ t: Target) {
    let theme = t.theme
    emit("TABLE\tname\trole\troleDescription\tname from\tAXDescription\tAXTitle\tAXHelp\tselected\tframe (pt)")
    for c in t.controls {
        emit("TABLE\t\(c.name)\t\(c.role)\t\(c.roleDescription)\t\(c.nameSource)\t\(c.description)\t\(c.title)\t\(c.help)\t\(c.selected)\t\(Int(c.frame.width))x\(Int(c.frame.height))")
    }
    for e in t.scene.expected {
        guard let c = t.control(e.name) else {
            check("voiceover", theme, "control named \"\(e.name)\"", "not in the accessibility tree", "present", false); continue
        }
        check("voiceover", theme, "\"\(e.name)\": role \(e.role), selected \(e.selected), enabled",
              "\(c.role) (\(c.roleDescription)), selected \(c.selected), enabled \(c.enabled), name from \(c.nameSource)",
              "\(e.role), selected \(e.selected), enabled true", c.role == e.role && c.selected == e.selected && c.enabled)
        if c.role == "AXTextField" {
            let labelled = c.description == c.placeholder || c.title == c.placeholder
            check("voiceover", theme, "the text field is named by a label equal to its placeholder, not by the placeholder alone",
                  "AXDescription \"\(c.description)\", AXTitle \"\(c.title)\", placeholder \"\(c.placeholder)\"", "a label \"\(c.placeholder)\"", labelled)
        }
        if e.role == "AXCheckBox" {
            note("switch-ax", theme, "\"\(e.name)\" read as role \(c.role), subrole \"\(c.subrole)\", role description \"\(c.roleDescription)\", AXValue \"\(c.value)\"; not yet seen on this macOS, proven by the owner's window run")
        }
        if let value = e.value {
            check("voiceover", theme, "\"\(e.name)\" reads its value before any press", "AXValue \"\(c.value)\"", "\"\(value)\"", c.value == value)
        }
        // One name: a title and a description that differ are two names for one control.
        let names = Set([c.title, c.description].filter { !$0.isEmpty })
        check("voiceover", theme, "\"\(e.name)\" has one name", "AXTitle \"\(c.title)\", AXDescription \"\(c.description)\"", "one", names.count <= 1)
    }
    for c in t.controls where c.name.isEmpty {
        check("voiceover", theme, "every control has a name", "an unnamed \(c.role)", "named", false)
    }
    // Target size in the tree (WCAG 2.5.8 AA: 24 x 24 pt). Frames are the tree's; a click was not simulated.
    for e in t.scene.expected where e.role != "AXTextField" {
        if let c = t.control(e.name) {
            // A switch is drawn small (controlSize .small). WCAG 2.5.8 lets a target under 24 x 24 pt stand when no other
            // target sits within 24 pt of it, so for a small one the size is a NOTE and the spacing is the CHECK. The gap
            // is frame to frame, a little stricter than the standard's 24 pt circle round the target's centre.
            if e.role == "AXCheckBox", c.frame.width < 24 || c.frame.height < 24 {
                note("target-size", theme, "\"\(e.name)\" accessibility frame \(f2(Double(c.frame.width)))x\(f2(Double(c.frame.height))) pt, under 24x24 pt: the spacing check below applies (WCAG 2.5.8)")
                let nearest = t.controls.filter { !CFEqual($0.element, c.element) }.map { frameGap(c.frame, $0.frame) }.min()
                check("target-spacing", theme, "\"\(e.name)\" to the nearest other target", nearest.map { "nearest target \(f2($0)) pt" } ?? "no other target",
                      ">= 24 pt (WCAG 2.5.8)", (nearest ?? .infinity) >= 24)
                continue
            }
            check("target-size", theme, "\"\(e.name)\" accessibility frame", "\(f2(Double(c.frame.width)))x\(f2(Double(c.frame.height))) pt", ">= 24x24 pt",
                  c.frame.width >= 24 && c.frame.height >= 24)
        }
    }
    // Activation by the accessibility action (what VoiceOver's "press" and Voice Control do).
    var lastCount = Int(t.windowTitle.split(separator: "|").last.map { $0.trimmingCharacters(in: .whitespaces) } ?? "") ?? 0
    for e in t.scene.expected {
        guard let event = e.pressEvent, let c = t.control(e.name) else { continue }
        let r = AXUIElementPerformAction(c.element, "AXPress" as CFString)
        usleep(300_000)
        let parts = t.windowTitle.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        let count = Int(parts.last ?? "") ?? 0
        check("press", theme, "AXPress on \"\(e.name)\"", "window title now \"\(t.windowTitle)\"", "event \"\(event)\"", r == .success && count == lastCount + 1 && parts.contains(event))
        lastCount = count
    }
    t.scene.afterActions?(t)
}

/// Polls the tree until `done` holds or `seconds` pass: a control that a press or a keystroke adds or renames
/// shows up a moment later.
func waitUntil(_ seconds: Double, _ done: () -> Bool) -> Bool {
    let end = Date().addingTimeInterval(seconds)
    while Date() < end {
        if done() { return true }
        usleep(200_000)
    }
    return done()
}

/// What VoiceOver reads for any element, not only the controls: the description, else the title, else the text value.
func spokenName(_ e: AXUIElement) -> String {
    [text(e, "AXDescription"), text(e, "AXTitle"), text(e, "AXValue")].first { !$0.isEmpty } ?? ""
}

/// The names that only appear once something is done (GL30), proven after the presses of stringsMode.
func afterActionStrings(_ t: Target) {
    let theme = t.theme

    // The theme switch was pressed above ("Switch to dark theme"); it must now offer the way back.
    let back = waitUntil(3) { t.control("Switch to light theme") != nil }
    let themeNames = t.controls.map(\.name).filter { $0.contains("theme") }.joined(separator: ", ")
    check("voiceover", theme, "after the toggle the theme switch is named \"Switch to light theme\"",
          back ? "named" : "names now: \(themeNames)", "\"Switch to light theme\"", back)

    // Typing in the search field adds the clear button, and VoiceOver must read "Clear the search". The letters go in
    // as key events to the focused field: typing is what drives SwiftUI's text binding.
    guard let field = t.control("Search hosts") else {
        check("voiceover", theme, "search field found to type into", "missing; controls read: \(t.controls.map(\.name).joined(separator: ", "))", "present", false); return
    }
    let focusTaken = t.focus(field)
    t.type("web")
    let clear = waitUntil(3) { t.control("Clear the search") != nil }
    let read = (attr(field.element, "AXValue") as? String) ?? ""
    let holder = t.focused.map { "\($0.role) \"\($0.name)\"" } ?? "nothing"
    let names = t.controls.map { "\($0.name) (\($0.role))" }.joined(separator: ", ")
    check("voiceover", theme, "after typing the search field has a button named \"Clear the search\"",
          clear ? "named" : "no such button; field text \"\(read)\", focus \(focusTaken ? "taken" : "not confirmed"), focus now on \(holder); names now: \(names)",
          "\"Clear the search\"", clear)

    // A spinner built without a label reads the library's "Working" (GL22). Read from the live tree: macOS exposes
    // the spinning ProgressView as AXBusyIndicator (a bar would be AXProgressIndicator), named by AXDescription.
    // Anything else of that kind in the window is only listed when the line fails.
    func progressLike() -> [AXUIElement] {
        descendants(t.window).filter {
            let role = text($0, "AXRole"), kind = text($0, "AXRoleDescription")
            return ["Progress", "Busy", "Indicator"].contains { role.contains($0) || kind.localizedCaseInsensitiveContains($0) }
        }
    }
    func named(_ e: AXUIElement) -> String { [text(e, "AXDescription"), text(e, "AXTitle"), text(e, "AXHelp")].first { !$0.isEmpty } ?? "" }
    let spinnerRoles = ["AXBusyIndicator", "AXProgressIndicator"]
    let working = waitUntil(3) { progressLike().contains { spinnerRoles.contains(text($0, "AXRole")) && named($0) == "Working" } }
    let seen = progressLike().map { "\(text($0, "AXRole")) (\(text($0, "AXRoleDescription"))) \"\(named($0))\"" }.joined(separator: ", ")
    check("voiceover", theme, "the unlabelled spinner is named \"Working\"",
          working ? "named" : "no AXBusyIndicator or AXProgressIndicator named \"Working\"; progress, busy or indicator elements in the window: \(seen.isEmpty ? "none" : seen)",
          "\"Working\"", working)
}

/// The gallery's sheet (opened by --open-sheet) must say its title as a heading.
func sheetMode(_ t: Target) {
    let theme = t.theme
    let title = "Edit host"
    func headings() -> [AXUIElement] {
        descendants(t.window).filter { text($0, "AXRole") == "AXHeading" || text($0, "AXRoleDescription") == "heading" }
    }
    let found = waitUntil(5) { headings().contains { spokenName($0) == title } }
    let seen = headings().map { "\"\(spokenName($0))\"" }.joined(separator: ", ")
    check("voiceover", theme, "the sheet title \"\(title)\" is read as a heading",
          found ? "heading" : "headings in the tree: \(seen.isEmpty ? "none" : seen)", "a heading \"\(title)\"", found)
}

func keysMode(_ t: Target) {
    let theme = t.theme
    let fka = NSApplication.shared.isFullKeyboardAccessEnabled
    note("keyboard", theme, "System Settings > Keyboard > Keyboard navigation is \(fka ? "ON" : "OFF") (read only; this script never changes it)")

    // Tab order. Expected: the reading order of the controls, as the accessibility tree lists them.
    let order = t.controls.map(\.name)
    var seen: [String] = []
    if let first = t.focused, order.contains(first.name) { seen.append(first.name) }
    for _ in 0..<(order.count + 2) {
        t.press(48)
        guard let n = t.focused?.name, order.contains(n), !seen.contains(n) else { break }
        seen.append(n)
    }
    note("tab-order", theme, "Tab stops found: \(seen.joined(separator: " > "))")
    if fka {
        // The walk may start anywhere (the search field has focus at launch), so the order is compared as a rotation.
        let start = seen.first.flatMap { order.firstIndex(of: $0) } ?? 0
        let rotated = Array(order[start...] + order[..<start])
        check("tab-order", theme, "Tab visits every control in reading order", seen.joined(separator: " > "), rotated.joined(separator: " > "), seen == rotated)
    } else {
        unproven("tab-order", theme, "with Keyboard navigation off macOS keeps Tab on text fields, so the order of \(order.count) controls cannot be walked; rerun after turning Keyboard navigation on yourself")
    }

    // Space and Return, on every control that takes focus. A control that will not take focus is reported, not skipped silently.
    for e in t.scene.expected where e.role != "AXTextField" {
        guard let c = t.control(e.name) else { continue }
        // Some controls (the glass theme switch) refuse AXFocused but take focus from Tab: reach them the way a user does.
        func focusOrTab(_ name: String) -> Bool {
            if let again = t.control(name), t.focus(again) { return true }
            guard fka else { return false }
            for _ in 0..<(order.count + 2) {
                t.press(48)
                if t.focused?.name == name { return true }
            }
            return false
        }
        guard focusOrTab(e.name) else {
            unproven("keys", theme, "\"\(e.name)\" does not take keyboard focus with Keyboard navigation \(fka ? "on" : "off"), so Space and Return could not be sent to it")
            continue
        }
        if e.role == "AXMenuButton" {
            t.press(49)
            let opened = ((attr(c.element, "AXChildren") as? [AXUIElement]) ?? []).contains { text($0, "AXRole") == "AXMenu" }
            check("keys", theme, "Space on focused \"\(e.name)\" opens its menu", opened ? "menu open" : "no menu", "menu open", opened)
            t.press(53)
            let closed = !((attr(c.element, "AXChildren") as? [AXUIElement]) ?? []).contains { text($0, "AXRole") == "AXMenu" }
            check("keys", theme, "Escape closes the menu of \"\(e.name)\"", closed ? "closed" : "still open", "closed", closed)
            _ = t.focus(c)
            t.press(36)
            let opened2 = ((attr(c.element, "AXChildren") as? [AXUIElement]) ?? []).contains { text($0, "AXRole") == "AXMenu" }
            note("keys", theme, "Return on focused \"\(e.name)\" \(opened2 ? "opens" : "does not open") its menu (system menu-button behaviour)")
            if opened2 { t.press(53) }
        } else if let event = e.pressEvent {
            // Space presses a focused button. Return presses only the window's default button, so on any other
            // button it is reported, not failed (the same system behaviour as Return on the menu buttons above).
            for (keyName, code) in [("Space", CGKeyCode(49)), ("Return", CGKeyCode(36))] {
                guard focusOrTab(e.name) else { continue }
                let before = t.windowTitle
                t.press(code)
                let fired = t.windowTitle != before && t.windowTitle.contains(event)
                if keyName == "Space" {
                    check("keys", theme, "Space on focused \"\(e.name)\"", t.windowTitle == before ? "no event" : t.windowTitle, "event \"\(event)\"", fired)
                } else {
                    note("keys", theme, "Return on focused \"\(e.name)\" \(fired ? "presses it" : "does not press it") (a button that is not the default button ignores Return on macOS)")
                }
            }
        }
    }
    t.scene.keys?(t)
}

// MARK: Scene sidebar-a (GL40)

/// The pixel checks of the Mac sidebar, from a capture of that window only. Ratios are read from the capture, never from
/// token values. A row's accessibility frame is the whole 32 pt row; the reads sit inside it, clear of its edges.
func sidebarAPixels(_ t: Target) {
    let theme = t.theme
    // The search capsule must not be focused: its edge is the unfocused one. Put focus on Home, a row nothing below reads.
    if let home = t.control("Home") { _ = t.focus(home) }
    guard let search = t.control("Search"), let cache = t.control("Cache"), let header = t.control("Targets"),
          let chosen = t.control(sidebarAStart), let copy = t.control("Copy") else {
        check("setup", theme, "sidebar controls found", "missing", "all", false); return
    }
    let shot = capture(t, name: theme)
    note("shot", theme, "\(t.out.path)/\(theme).png, \(shot.width)x\(shot.height) px, scale \(f2(shot.scale))")
    func at(_ p: CGPoint) -> RGB { let q = shot.pixel(p); return shot.px(q.x, q.y) }
    func ink(_ id: String, _ what: String, _ rect: CGRect, _ need: Double) {
        let r = readInk(shot, rect: rect)
        check(id, theme, "\(what): ink \(hex(r.ink)) on \(hex(r.ground))", f2(r.typical) + ":1", ">= \(f2(need)):1", r.typical >= need)
        if r.worst < need { note(id, theme, "against the weakest ground pixel the ratio is \(f2(r.worst)):1") }
    }
    /// The glyph and the start of the name: from the row's first glyph (12 pt in) to about 110 pt, between its top and bottom padding.
    func label(_ f: CGRect, width: Double = 110) -> CGRect { CGRect(x: f.minX + 12, y: f.minY + 6, width: min(f.width - 24, width), height: f.height - 12) }

    ink("row-text", "row name (text2) on the window ground", label(cache.frame), 4.5)
    ink("section-label", "section title (text3) on the window ground", label(header.frame, width: 90), 4.5)
    ink("selected-text", "selected row name on its panel fill", label(chosen.frame), 4.5)
    // The marker is 4 pt wide, 4 pt in from the row's edge; the panel fill is read at the row's right end, clear of any count.
    let f = chosen.frame
    let marker = at(CGPoint(x: f.minX + 6, y: f.midY)), panel = at(CGPoint(x: f.maxX - 24, y: f.midY))
    check("selected-marker", theme, "selected marker \(hex(marker)) against panel \(hex(panel))", f2(ratio(marker, panel)) + ":1", ">= 3:1", ratio(marker, panel) >= 3)
    // The count's pill ends 12 pt from the row's end; read the 20 pt of it that is always fill and text.
    let c = copy.frame
    ink("count", "count (accentFg) on its pill", CGRect(x: c.maxX - 12 - 21, y: c.midY - 7, width: 20, height: 14), 4.5)
    // The search label sits on the field fill: the glyph and the first of the word.
    ink("search-label", "search label (placeholder colour) on the field fill", label(search.frame, width: 90), 4.5)
    // The unfocused search edge against the window ground above and below it (the capsule's straight top and bottom).
    let s = search.frame
    for (name, y, outward) in [("top", s.minY, -1.0), ("bottom", s.maxY, 1.0)] {
        let surround = at(CGPoint(x: s.midX, y: y + outward * 7))
        var best: (ratio: Double, color: RGB) = (0, surround)
        for step in stride(from: -4.0, through: 4.0, by: 0.5) {
            let color = at(CGPoint(x: s.midX, y: y + step))
            if ratio(color, surround) > best.ratio { best = (ratio(color, surround), color) }
        }
        check("search-edge", theme, "unfocused search edge (\(name)) \(hex(best.color)) vs surround \(hex(surround))", f2(best.ratio) + ":1", ">= 3:1", best.ratio >= 3)
    }
}

/// Names that depend on an action, and the one name of the container (GL30 rule: proven, not assumed).
func sidebarAAfterActions(_ t: Target) {
    let theme = t.theme
    let named = descendants(t.window).contains { text($0, "AXDescription") == "Sidebar" || text($0, "AXTitle") == "Sidebar" }
    check("voiceover", theme, "the container is named \"Sidebar\"", named ? "named" : "no element named Sidebar", "named", named)
    // A header: AXPress folds it, so its rows leave the tree and its value says "collapsed"; a second press restores both.
    let title = "Targets", row = "Cloud"
    guard let header = t.control(title) else { check("voiceover", theme, "header \"\(title)\" found", "missing", "present", false); return }
    let pressed = AXUIElementPerformAction(header.element, "AXPress" as CFString) == .success
    let gone = pressed && waitUntil(3) { t.control(row) == nil }
    let collapsed = waitUntil(3) { t.control(title)?.value == "collapsed" }
    check("voiceover", theme, "AXPress on \"\(title)\" folds it: its row \"\(row)\" leaves the tree", gone ? "row gone" : "row still in the tree", "row gone", gone)
    check("voiceover", theme, "a folded header reads \"collapsed\"", "AXValue \"\(t.control(title)?.value ?? "")\"", "\"collapsed\"", collapsed)
    if let again = t.control(title) { _ = AXUIElementPerformAction(again.element, "AXPress" as CFString) }
    let back = waitUntil(3) { t.control(row) != nil }
    let open = waitUntil(3) { t.control(title)?.value == "expanded" }
    check("voiceover", theme, "a second AXPress restores \"\(row)\" and the value \"expanded\"", back && open ? "restored" : "row \(back ? "back" : "gone"), value \"\(t.control(title)?.value ?? "")\"", "restored", back && open)
}

/// Keys: Space on a header folds it and takes its rows out of the Tab order; Tab to the last row scrolls it into the window.
func sidebarAKeys(_ t: Target) {
    let theme = t.theme
    guard NSApplication.shared.isFullKeyboardAccessEnabled else {
        unproven("keys", theme, "with Keyboard navigation off Space and Tab cannot be sent to the sidebar's headers and rows; rerun after turning it on yourself")
        return
    }
    let folded = "Across types", next = "Komando's own", inside = "Copy", last = "Agent", before = "Doctor"
    guard let header = t.control(folded), t.focus(header) else {
        unproven("keys", theme, "\"\(folded)\" did not take keyboard focus, so Space could not be sent to it"); return
    }
    t.press(49)
    let gone = waitUntil(3) { t.control(inside) == nil }
    check("keys", theme, "Space on the focused header \"\(folded)\" folds it: \"\(inside)\" leaves the tree", gone ? "row gone" : "row still in the tree", "row gone", gone)
    // The next Tab stop after the folded header is the next header: the folded rows are out of the Tab order.
    t.press(48)
    let stop = t.focused?.name ?? "none"
    check("keys", theme, "after Tab from the folded header the next stop skips the folded rows", "\"\(stop)\"", "\"\(next)\"", stop == next)
    if let again = t.control(folded), t.focus(again) { t.press(49) }
    let back = waitUntil(3) { t.control(inside) != nil }
    check("keys", theme, "a second Space on \"\(folded)\" restores \"\(inside)\"", back ? "restored" : "still folded", "restored", back)
    // The window is 680 high with every section open, so the last rows start below the fold. Tab reaches \(last) and it must scroll in.
    guard let doctor = t.control(before), t.focus(doctor) else {
        unproven("keys", theme, "\"\(before)\" did not take keyboard focus, so Tab could not be sent on to \"\(last)\""); return
    }
    t.press(48)
    let arrived = t.focused?.name == last
    let inWindow = arrived && waitUntil(2) {
        guard let row = t.control(last), let win = axFrame(t.window) else { return false }
        return win.insetBy(dx: -1, dy: -1).contains(row.frame)
    }
    let frame = t.control(last)?.frame ?? .zero
    check("keys", theme, "after Tab to the last row \"\(last)\" it is inside the window frame (scrolled into view)",
          arrived ? "frame \(Int(frame.minX)),\(Int(frame.minY)) \(Int(frame.width))x\(Int(frame.height)); window \(axFrame(t.window).map { "\(Int($0.minY))..\(Int($0.maxY))" } ?? "?")" : "focus is on \"\(t.focused?.name ?? "none")\"",
          "row inside the window", inWindow)
}

// MARK: Entry

let args = CommandLine.arguments
func sceneNamed(_ name: String?) -> SceneSpec {
    guard let spec = scenes[name ?? "components"] else {
        FileHandle.standardError.write(Data("unknown scene \"\(name ?? "")\"; the scenes are \(scenes.keys.sorted().joined(separator: ", "))\n".utf8))
        exit(2)
    }
    return spec
}
if args.count >= 3, args.count <= 4, args[1] == "ready", let pid = Int32(args[2]) {
    let spec = sceneNamed(args.count == 4 ? args[3] : nil)
    let app = AXUIElementCreateApplication(pid)
    let window = (attr(app, "AXWindows") as? [AXUIElement])?.first
    let buttons = window.map { descendants($0).filter { text($0, "AXRole") == "AXButton" }.count } ?? 0
    let listed = (CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? [])
        .contains { ($0[kCGWindowOwnerPID as String] as? Int32) == pid && ($0[kCGWindowLayer as String] as? Int) == 0 }
    exit(buttons >= spec.readyButtons && listed ? 0 : 1)
}
guard args.count == 5 || args.count == 6, let pidValue = Int32(args[2]) else {
    FileHandle.standardError.write(Data("usage: windowcheck pixels|strings|keys|sheet <pid> <theme> <out-dir> [scene] | ready <pid> [scene]\n".utf8))
    exit(2)
}
guard AXIsProcessTrusted() else {
    FileHandle.standardError.write(Data("Accessibility permission is missing for the app that runs this script (System Settings > Privacy & Security > Accessibility)\n".utf8))
    exit(2)
}
let target = Target(pid: pidValue, theme: args[3], out: URL(fileURLWithPath: args[4]), scene: sceneNamed(args.count == 6 ? args[5] : nil))
try? FileManager.default.createDirectory(at: target.out, withIntermediateDirectories: true)
func run(_ mode: String, _ body: ((Target) -> Void)?) {
    guard let body else {
        FileHandle.standardError.write(Data("scene \(target.scene.name) has no \(mode) mode\n".utf8))
        exit(2)
    }
    body(target)
}
switch args[1] {
case "pixels": run("pixels", target.scene.pixels)
case "strings": stringsMode(target)
case "keys": keysMode(target)
case "sheet": run("sheet", target.scene.sheet)
default: exit(2)
}
let tsvName = target.scene.name == "components" ? "\(args[1])-\(target.theme).tsv" : "\(target.scene.name)-\(args[1])-\(target.theme).tsv"
try? log.joined(separator: "\n").appending("\n").write(to: target.out.appendingPathComponent(tsvName), atomically: true, encoding: .utf8)
exit(failures == 0 ? 0 : 1)

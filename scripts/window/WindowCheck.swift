// Checks of the running GlamorGallery window, driven by scripts/check-window.sh.
//
//   windowcheck pixels <pid> <theme> <out-dir>    pixel contrast and the label-to-icon gap, from a capture of that window only
//   windowcheck strings <pid> <theme> <out-dir>   VoiceOver strings and AXPress activation, from the accessibility tree
//   windowcheck keys <pid> <theme> <out-dir>      Tab order, Space and Return
//   windowcheck ready <pid>                       exits 0 once the window is on screen with its controls
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
    let app: AXUIElement
    let window: AXUIElement

    init(pid: pid_t, theme: String, out: URL) {
        self.pid = pid
        self.theme = theme
        self.out = out
        app = AXUIElementCreateApplication(pid)
        guard let w = (attr(app, "AXWindows") as? [AXUIElement])?.first else {
            FileHandle.standardError.write(Data("no window for pid \(pid)\n".utf8))
            exit(2)
        }
        window = w
    }

    var controls: [Control] {
        descendants(window).map(Control.init).filter {
            ["AXButton", "AXMenuButton", "AXTextField"].contains($0.role) && $0.subrole.isEmpty
        }
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

// MARK: Modes

func pixelsMode(_ t: Target) {
    let theme = t.theme
    // The search field must not be focused: its edge is the unfocused one (GL17). Focus a menu button instead.
    if let more = t.controls.first(where: { $0.title.hasPrefix("More") || $0.description.hasPrefix("More") }) { _ = t.focus(more) }
    guard let field = t.controls.first(where: { $0.role == "AXTextField" }),
          let deploy = t.control("Deploy"), let daily = t.controls.first(where: { $0.title == "Daily" }),
          let host = descendants(t.window).first(where: { text($0, "AXSubrole") == "AXHostingView" }) else {
        check("setup", theme, "gallery controls found", "missing", "all", false); return
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
}

struct Expected { let name: String; let role: String; let selected: Bool; let pressEvent: String? }

let expectedControls: [Expected] = [
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
]

func stringsMode(_ t: Target) {
    let theme = t.theme
    emit("TABLE\tname\trole\troleDescription\tname from\tAXDescription\tAXTitle\tAXHelp\tselected\tframe (pt)")
    for c in t.controls {
        emit("TABLE\t\(c.name)\t\(c.role)\t\(c.roleDescription)\t\(c.nameSource)\t\(c.description)\t\(c.title)\t\(c.help)\t\(c.selected)\t\(Int(c.frame.width))x\(Int(c.frame.height))")
    }
    for e in expectedControls {
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
        // One name: a title and a description that differ are two names for one control.
        let names = Set([c.title, c.description].filter { !$0.isEmpty })
        check("voiceover", theme, "\"\(e.name)\" has one name", "AXTitle \"\(c.title)\", AXDescription \"\(c.description)\"", "one", names.count <= 1)
    }
    for c in t.controls where c.name.isEmpty {
        check("voiceover", theme, "every control has a name", "an unnamed \(c.role)", "named", false)
    }
    // Target size in the tree (WCAG 2.5.8 AA: 24 x 24 pt). Frames are the tree's; a click was not simulated.
    for e in expectedControls where e.role != "AXTextField" {
        if let c = t.control(e.name) {
            check("target-size", theme, "\"\(e.name)\" accessibility frame", "\(f2(Double(c.frame.width)))x\(f2(Double(c.frame.height))) pt", ">= 24x24 pt",
                  c.frame.width >= 24 && c.frame.height >= 24)
        }
    }
    // Activation by the accessibility action (what VoiceOver's "press" and Voice Control do).
    var lastCount = Int(t.windowTitle.split(separator: "|").last.map { $0.trimmingCharacters(in: .whitespaces) } ?? "") ?? 0
    for e in expectedControls {
        guard let event = e.pressEvent, let c = t.control(e.name) else { continue }
        let r = AXUIElementPerformAction(c.element, "AXPress" as CFString)
        usleep(300_000)
        let parts = t.windowTitle.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        let count = Int(parts.last ?? "") ?? 0
        check("press", theme, "AXPress on \"\(e.name)\"", "window title now \"\(t.windowTitle)\"", "event \"\(event)\"", r == .success && count == lastCount + 1 && parts.contains(event))
        lastCount = count
    }
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
    for e in expectedControls where e.role != "AXTextField" {
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
}

// MARK: Entry

let args = CommandLine.arguments
if args.count == 3, args[1] == "ready", let pid = Int32(args[2]) {
    let app = AXUIElementCreateApplication(pid)
    let window = (attr(app, "AXWindows") as? [AXUIElement])?.first
    let buttons = window.map { descendants($0).filter { text($0, "AXRole") == "AXButton" }.count } ?? 0
    let listed = (CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? [])
        .contains { ($0[kCGWindowOwnerPID as String] as? Int32) == pid && ($0[kCGWindowLayer as String] as? Int) == 0 }
    exit(buttons >= 10 && listed ? 0 : 1)
}
guard args.count == 5, let pidValue = Int32(args[2]) else {
    FileHandle.standardError.write(Data("usage: windowcheck pixels|strings|keys <pid> <theme> <out-dir> | ready <pid>\n".utf8))
    exit(2)
}
guard AXIsProcessTrusted() else {
    FileHandle.standardError.write(Data("Accessibility permission is missing for the app that runs this script (System Settings > Privacy & Security > Accessibility)\n".utf8))
    exit(2)
}
let target = Target(pid: pidValue, theme: args[3], out: URL(fileURLWithPath: args[4]))
try? FileManager.default.createDirectory(at: target.out, withIntermediateDirectories: true)
switch args[1] {
case "pixels": pixelsMode(target)
case "strings": stringsMode(target)
case "keys": keysMode(target)
default: exit(2)
}
try? log.joined(separator: "\n").appending("\n").write(to: target.out.appendingPathComponent("\(args[1])-\(target.theme).tsv"), atomically: true, encoding: .utf8)
exit(failures == 0 ? 0 : 1)

#if os(macOS)
import AppKit
import Glamor
import SwiftUI
import Testing

/// GL41: the Button family is drawn as capsules (the one shape of buttons and tags), at the same heights as before.
/// The radius is read from a rendered button: 3 pt in from the corner of its bounding box a rounded rectangle of
/// radius 8 or 6 is filled, a capsule (radius 16 or 14) is not. The heights are the rendered size.
@MainActor
struct PillButtonTests {
    private struct Raster {
        let width: Int
        let height: Int
        let scale: CGFloat
        let pixels: [UInt8]

        var size: CGSize { CGSize(width: CGFloat(width) / scale, height: CGFloat(height) / scale) }

        /// The alpha (0 to 1) of the pixel `x`, `y` points in from the top left.
        func alpha(x: CGFloat, y: CGFloat) -> Double {
            let column = min(width - 1, Int(x * scale)), row = min(height - 1, Int(y * scale))
            return Double(pixels[(row * width + column) * 4 + 3]) / 255
        }
    }

    private func raster<V: View>(_ view: V) throws -> Raster {
        let renderer = ImageRenderer(content: view.environment(\.colorScheme, .light))
        renderer.scale = 4
        let image = try #require(renderer.cgImage)
        let width = image.width, height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                                          bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        try #require(drawn)
        return Raster(width: width, height: height, scale: 4, pixels: pixels)
    }

    /// A fill reaches 3 pt in from the corner only when the corner is not a half circle.
    private func isCapsule(_ raster: Raster) -> Bool {
        raster.alpha(x: 3, y: 3) < 0.2 && raster.alpha(x: raster.size.width / 2, y: raster.size.height / 2) > 0.9
    }

    // MARK: Radius

    @Test func theMainButtonIsACapsule() throws {
        let standard = try raster(Button("Save") {}.buttonStyle(PrimaryButtonStyle()))
        let compact = try raster(Button("Save") {}.buttonStyle(PrimaryButtonStyle(compact: true)))
        #expect(isCapsule(standard))
        #expect(isCapsule(compact))
    }

    @Test func theSecondaryButtonIsACapsule() throws {
        let standard = try raster(Button("Cancel") {}.buttonStyle(SecondaryButtonStyle()))
        let compact = try raster(Button("Cancel") {}.buttonStyle(SecondaryButtonStyle(compact: true)))
        #expect(isCapsule(standard))
        #expect(isCapsule(compact))
    }

    @Test func aSmallControlSizeDrawsTheCompactCapsule() throws {
        let small = try raster(Button("Cancel") {}.buttonStyle(SecondaryButtonStyle()).controlSize(.small))
        #expect(isCapsule(small))
    }

    // MARK: Height

    @Test func theMainButtonKeepsItsHeights() throws {
        #expect(try raster(Button("Save") {}.buttonStyle(PrimaryButtonStyle())).size.height == G.Height.control32)
        #expect(try raster(Button("Save") {}.buttonStyle(PrimaryButtonStyle(compact: true))).size.height == G.Height.control28)
    }

    @Test func theSecondaryButtonKeepsItsHeights() throws {
        #expect(try raster(Button("Cancel") {}.buttonStyle(SecondaryButtonStyle())).size.height == G.Height.control32)
        #expect(try raster(Button("Cancel") {}.buttonStyle(SecondaryButtonStyle(compact: true))).size.height == G.Height.control28)
    }

    @Test func theGhostButtonKeepsItsHeightsAndASquareStaysSquare() throws {
        #expect(try raster(Button("Edit") {}.buttonStyle(GhostButtonStyle())).size.height == G.Height.control32)
        #expect(try raster(Button("Edit") {}.buttonStyle(GhostButtonStyle(compact: true))).size.height == G.Height.control28)
        let square = try raster(Button { } label: { Image(systemName: "pencil") }.buttonStyle(GhostButtonStyle(square: true)))
        #expect(square.size.width == square.size.height)
        let inRow = try raster(Button { } label: { Image(systemName: "pencil") }.buttonStyle(GhostButtonStyle(square: true, size: G.Height.control24)))
        #expect(inRow.size == CGSize(width: G.Height.control24, height: G.Height.control24))
    }

    // MARK: Source: shapes that cannot be rendered in a test (hover, glass, the system Menu)

    private var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    private func source(_ path: String) throws -> String {
        try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    private func part(_ text: String, from start: String, to end: String) throws -> String {
        let a = try #require(text.range(of: start)), b = try #require(text.range(of: end))
        return String(text[a.lowerBound..<b.lowerBound])
    }

    @Test func theButtonStylesDrawNoRoundedRectangleForTheButtonItself() throws {
        let buttons = try source("macOS/Buttons.swift")
        #expect(!buttons.contains("cornerRadius: m.radius"), "a button's shape is a Capsule: no metrics radius")
        #expect(!buttons.contains("var radius: CGFloat { compact"), "ButtonMetrics has no radius any more")
        for style in [("PrimaryButtonStyle", "SecondaryButtonStyle"), ("SecondaryButtonStyle", "GhostButtonStyle")] {
            let body = try part(buttons, from: "public struct \(style.0)", to: "public struct \(style.1)")
            #expect(body.contains("Capsule()"), "\(style.0) fills, rims and rings a Capsule")
            #expect(!body.contains("RoundedRectangle"), "\(style.0) has no rounded rectangle left")
            #expect(body.contains(".focusRingCapsule()"), "\(style.0) rings a capsule with the capsule ring")
        }
    }

    @Test func aGhostMenuRowKeepsItsRowRadiusAndEveryOtherGhostIsACapsule() throws {
        let ghost = try part(try source("macOS/Buttons.swift"), from: "public struct GhostButtonStyle", to: "public extension ButtonStyle where Self == PrimaryButtonStyle")
        #expect(ghost.contains("wide ?"), "the wide ghost (a menu row) picks its own shape")
        #expect(ghost.contains("Capsule()"))
        #expect(ghost.contains("G.Radius.r8"), "a menu row stays r8: rows keep their radius")
    }

    @Test func theGlassMainActionIsACapsuleOnMacAndIOSAndKeepsItsHitArea() throws {
        let style = try source("Glass/GlassMainActionStyle.swift")
        #expect(style.contains("let shape = Capsule()"))
        #expect(!style.contains("RoundedRectangle"))
        #expect(style.contains(".contentShape(shape)"))
        #expect(style.contains(".focusRingCapsule()"))
        #expect(!style.contains(".focusRing(G.Radius.r8)"))
    }

    @Test func theMenuPickerIsACapsuleLikeTheSecondaryButtonBesideIt() throws {
        let picker = try part(try source("macOS/Controls.swift"), from: "public struct MenuPicker", to: "public struct SegmentedControl")
        #expect(picker.contains("let shape = Capsule()"))
        #expect(!picker.contains("RoundedRectangle"))
        #expect(picker.contains(".focusRingCapsule(isFocused: focused)"))
        #expect(picker.contains("small ? G.Height.control28 : G.Height.control32"), "the heights stay")
    }

    @Test func theMoreMenuHoversAsACircleLikeTheGhostSquare() throws {
        let more = try part(try source("macOS/Lists.swift"), from: "public struct MoreMenu<", to: "    public init(size: CGFloat = G.Height.control28, label: String?")
        #expect(more.contains("in: Capsule()"))
        #expect(!more.contains("RoundedRectangle"))
        #expect(more.contains(".focusRingCapsule(isFocused: focused)"))
        #expect(more.contains(".contentShape(Capsule())"), "the hit area follows the circle")
    }

    @Test func fieldsRowsBannersAndTheSegmentedControlKeepTheirRadius() throws {
        let controls = try source("macOS/Controls.swift")
        #expect(try part(controls, from: "public struct FieldBox", to: "/// A labelled form field").contains("RoundedRectangle"))
        #expect(try part(controls, from: "public struct SearchBar", to: "/// A choice from a list").contains("G.Radius.r12"))
        #expect(try part(controls, from: "public struct SegmentedControl", to: "private struct SegmentItem").contains("G.Radius.r8"))
        #expect(try source("macOS/Feedback.swift").contains("RoundedRectangle(cornerRadius: G.Radius.r8"))
    }
}
#endif

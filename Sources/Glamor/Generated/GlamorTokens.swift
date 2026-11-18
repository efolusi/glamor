// Generated from tokens.json by scripts/build.mjs. Do not edit.
// Values only: no SwiftUI or UIKit import. Glamor wraps these in Color, Font, and Animation.
// Web-only tokens (font stacks, box-shadows) are not here.

public enum GlamorTokens {
    public struct RGBA: Equatable, Sendable {
        public let red, green, blue, alpha: Double
        public init(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double) {
            self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
        }
    }

    /// Increased-contrast values default to the normal ones.
    public struct ColorPair: Equatable, Sendable {
        public let light, dark, increasedLight, increasedDark: RGBA
        public init(light: RGBA, dark: RGBA, increasedLight: RGBA? = nil, increasedDark: RGBA? = nil) {
            self.light = light; self.dark = dark
            self.increasedLight = increasedLight ?? light; self.increasedDark = increasedDark ?? dark
        }
    }

    public struct Bezier: Equatable, Sendable {
        public let x1, y1, x2, y2: Double
        public init(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) {
            self.x1 = x1; self.y1 = y1; self.x2 = x2; self.y2 = y2
        }
    }

    /// sRGB components 0...1: light, dark, and increased-contrast light and dark.
    public enum Color {
        public static let sand25 = ColorPair(light: RGBA(0.9882, 0.9843, 0.9765, 1.0), dark: RGBA(0.9882, 0.9843, 0.9765, 1.0))
        public static let sand50 = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 1.0), dark: RGBA(0.9804, 0.9765, 0.9647, 1.0))
        public static let sand100 = ColorPair(light: RGBA(0.9529, 0.9451, 0.9216, 1.0), dark: RGBA(0.9529, 0.9451, 0.9216, 1.0))
        public static let sand200 = ColorPair(light: RGBA(0.9059, 0.8902, 0.851, 1.0), dark: RGBA(0.9059, 0.8902, 0.851, 1.0))
        public static let sand300 = ColorPair(light: RGBA(0.8353, 0.8118, 0.7529, 1.0), dark: RGBA(0.8353, 0.8118, 0.7529, 1.0))
        public static let sand400 = ColorPair(light: RGBA(0.7059, 0.6706, 0.5922, 1.0), dark: RGBA(0.7059, 0.6706, 0.5922, 1.0))
        public static let sand500 = ColorPair(light: RGBA(0.5804, 0.5412, 0.4549, 1.0), dark: RGBA(0.5804, 0.5412, 0.4549, 1.0))
        public static let sand600 = ColorPair(light: RGBA(0.4706, 0.4314, 0.349, 1.0), dark: RGBA(0.4706, 0.4314, 0.349, 1.0))
        public static let sand700 = ColorPair(light: RGBA(0.3686, 0.3333, 0.2706, 1.0), dark: RGBA(0.3686, 0.3333, 0.2706, 1.0))
        public static let sand800 = ColorPair(light: RGBA(0.2667, 0.2392, 0.1961, 1.0), dark: RGBA(0.2667, 0.2392, 0.1961, 1.0))
        public static let sand900 = ColorPair(light: RGBA(0.1804, 0.1608, 0.1333, 1.0), dark: RGBA(0.1804, 0.1608, 0.1333, 1.0))
        public static let sand950 = ColorPair(light: RGBA(0.1176, 0.102, 0.0784, 1.0), dark: RGBA(0.1176, 0.102, 0.0784, 1.0))
        public static let brand50 = ColorPair(light: RGBA(0.9725, 0.9569, 0.902, 1.0), dark: RGBA(0.9725, 0.9569, 0.902, 1.0))
        public static let brand100 = ColorPair(light: RGBA(0.9569, 0.9137, 0.8235, 1.0), dark: RGBA(0.9569, 0.9137, 0.8235, 1.0))
        public static let brand200 = ColorPair(light: RGBA(0.9373, 0.8118, 0.6745, 1.0), dark: RGBA(0.9373, 0.8118, 0.6745, 1.0))
        public static let brand300 = ColorPair(light: RGBA(0.8745, 0.7098, 0.5216, 1.0), dark: RGBA(0.8745, 0.7098, 0.5216, 1.0))
        public static let brand400 = ColorPair(light: RGBA(0.8078, 0.6118, 0.4, 1.0), dark: RGBA(0.8078, 0.6118, 0.4, 1.0))
        public static let brand500 = ColorPair(light: RGBA(0.7529, 0.5412, 0.3529, 1.0), dark: RGBA(0.7529, 0.5412, 0.3529, 1.0))
        public static let brand600 = ColorPair(light: RGBA(0.6275, 0.4118, 0.2353, 1.0), dark: RGBA(0.6275, 0.4118, 0.2353, 1.0))
        public static let brand700 = ColorPair(light: RGBA(0.4784, 0.3059, 0.1686, 1.0), dark: RGBA(0.4784, 0.3059, 0.1686, 1.0))
        public static let brand800 = ColorPair(light: RGBA(0.3608, 0.2275, 0.1216, 1.0), dark: RGBA(0.3608, 0.2275, 0.1216, 1.0))
        public static let brand900 = ColorPair(light: RGBA(0.2824, 0.1569, 0.0941, 1.0), dark: RGBA(0.2824, 0.1569, 0.0941, 1.0))
        public static let brand950 = ColorPair(light: RGBA(0.1725, 0.0902, 0.0353, 1.0), dark: RGBA(0.1725, 0.0902, 0.0353, 1.0))
        public static let cocoa700 = ColorPair(light: RGBA(0.2824, 0.1569, 0.0941, 1.0), dark: RGBA(0.2824, 0.1569, 0.0941, 1.0))
        public static let cocoa900 = ColorPair(light: RGBA(0.2275, 0.1255, 0.0706, 1.0), dark: RGBA(0.2275, 0.1255, 0.0706, 1.0))
        public static let cocoa950 = ColorPair(light: RGBA(0.1725, 0.0902, 0.0353, 1.0), dark: RGBA(0.1725, 0.0902, 0.0353, 1.0))
        public static let caramel500 = ColorPair(light: RGBA(0.7529, 0.5412, 0.3529, 1.0), dark: RGBA(0.7529, 0.5412, 0.3529, 1.0))
        public static let peach200 = ColorPair(light: RGBA(0.9373, 0.8118, 0.6745, 1.0), dark: RGBA(0.9373, 0.8118, 0.6745, 1.0))
        public static let cream50 = ColorPair(light: RGBA(0.9725, 0.9569, 0.902, 1.0), dark: RGBA(0.9725, 0.9569, 0.902, 1.0))
        public static let success100 = ColorPair(light: RGBA(0.9216, 0.9608, 0.9255, 1.0), dark: RGBA(0.1098, 0.1686, 0.1216, 1.0))
        public static let success300 = ColorPair(light: RGBA(0.749, 0.8784, 0.7765, 1.0), dark: RGBA(0.1804, 0.2902, 0.2039, 1.0))
        public static let success600 = ColorPair(light: RGBA(0.1843, 0.4784, 0.251, 1.0), dark: RGBA(0.3725, 0.7216, 0.4314, 1.0))
        public static let successOnDark = ColorPair(light: RGBA(0.498, 0.8157, 0.5529, 1.0), dark: RGBA(0.498, 0.8157, 0.5529, 1.0))
        public static let successContrast = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(0.1176, 0.102, 0.0784, 1.0))
        public static let warning100 = ColorPair(light: RGBA(0.9922, 0.9529, 0.8784, 1.0), dark: RGBA(0.1804, 0.1412, 0.0745, 1.0))
        public static let warning300 = ColorPair(light: RGBA(0.9529, 0.851, 0.6588, 1.0), dark: RGBA(0.2902, 0.2275, 0.1137, 1.0))
        public static let warning600 = ColorPair(light: RGBA(0.7059, 0.3255, 0.0353, 1.0), dark: RGBA(0.851, 0.5098, 0.1686, 1.0))
        public static let warningOnDark = ColorPair(light: RGBA(0.949, 0.7529, 0.4706, 1.0), dark: RGBA(0.949, 0.7529, 0.4706, 1.0))
        public static let warningContrast = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(0.1176, 0.102, 0.0784, 1.0))
        public static let danger100 = ColorPair(light: RGBA(0.9922, 0.9333, 0.9255, 1.0), dark: RGBA(0.1961, 0.1059, 0.0941, 1.0))
        public static let danger300 = ColorPair(light: RGBA(0.9608, 0.7765, 0.7529, 1.0), dark: RGBA(0.3294, 0.1608, 0.1216, 1.0))
        public static let danger600 = ColorPair(light: RGBA(0.7843, 0.1176, 0.1176, 1.0), dark: RGBA(0.9098, 0.3647, 0.2902, 1.0))
        public static let danger700 = ColorPair(light: RGBA(0.7255, 0.1098, 0.1098, 1.0), dark: RGBA(0.9569, 0.4667, 0.3961, 1.0))
        public static let dangerOnDark = ColorPair(light: RGBA(0.9569, 0.6078, 0.5765, 1.0), dark: RGBA(0.9569, 0.6078, 0.5765, 1.0))
        public static let dangerContrast = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(0.1176, 0.102, 0.0784, 1.0))
        public static let chart1 = ColorPair(light: RGBA(0.1647, 0.4706, 0.8392, 1.0), dark: RGBA(0.2235, 0.5294, 0.898, 1.0))
        public static let chart2 = ColorPair(light: RGBA(0.9216, 0.4078, 0.2039, 1.0), dark: RGBA(0.851, 0.349, 0.149, 1.0))
        public static let chart3 = ColorPair(light: RGBA(0.1059, 0.6863, 0.4784, 1.0), dark: RGBA(0.098, 0.6196, 0.4392, 1.0))
        public static let chart4 = ColorPair(light: RGBA(0.3843, 0.3137, 0.8392, 1.0), dark: RGBA(0.5647, 0.5216, 0.9137, 1.0))
        public static let chart5 = ColorPair(light: RGBA(0.9098, 0.4824, 0.6431, 1.0), dark: RGBA(0.8353, 0.3176, 0.5059, 1.0))
        public static let surfacePage = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 1.0), dark: RGBA(0.098, 0.0824, 0.0706, 1.0))
        public static let surfaceCard = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(0.1294, 0.1098, 0.0902, 1.0))
        public static let surfacePanel = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(0.1294, 0.1098, 0.0902, 1.0))
        public static let surfaceCardHover = ColorPair(light: RGBA(0.9529, 0.9451, 0.9216, 1.0), dark: RGBA(0.1647, 0.1451, 0.1176, 1.0))
        public static let surfaceSunken = ColorPair(light: RGBA(0.9529, 0.9451, 0.9216, 1.0), dark: RGBA(0.1647, 0.1451, 0.1176, 1.0))
        public static let surfaceSubtle = ColorPair(light: RGBA(0.9882, 0.9843, 0.9765, 1.0), dark: RGBA(0.1137, 0.0941, 0.0784, 1.0))
        public static let surfaceInverse = ColorPair(light: RGBA(0.1176, 0.102, 0.0784, 1.0), dark: RGBA(0.9804, 0.9765, 0.9647, 1.0))
        public static let surfaceInverseHover = ColorPair(light: RGBA(0.1804, 0.1608, 0.1333, 1.0), dark: RGBA(0.9529, 0.9451, 0.9216, 1.0))
        public static let surfaceInverseActive = ColorPair(light: RGBA(0.2667, 0.2392, 0.1961, 1.0), dark: RGBA(0.9059, 0.8902, 0.851, 1.0))
        public static let surfaceBrand = ColorPair(light: RGBA(0.2824, 0.1569, 0.0941, 1.0), dark: RGBA(0.1725, 0.0902, 0.0353, 1.0))
        public static let surfaceCode = ColorPair(light: RGBA(0.0784, 0.0667, 0.0431, 1.0), dark: RGBA(0.0784, 0.0667, 0.0431, 1.0))
        public static let textCode = ColorPair(light: RGBA(0.9098, 0.8902, 0.851, 1.0), dark: RGBA(0.9098, 0.8902, 0.851, 1.0))
        public static let textOnBrandMuted = ColorPair(light: RGBA(0.9725, 0.9569, 0.902, 0.75), dark: RGBA(0.9725, 0.9569, 0.902, 0.75))
        public static let textOnBrand = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(1.0, 1.0, 1.0, 1.0))
        public static let textOnMedia = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 1.0), dark: RGBA(0.9804, 0.9765, 0.9647, 1.0))
        public static let textOnMediaMuted = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.75), dark: RGBA(0.9804, 0.9765, 0.9647, 0.75))
        public static let textPrimary = ColorPair(light: RGBA(0.1176, 0.102, 0.0784, 1.0), dark: RGBA(0.9529, 0.9373, 0.9059, 1.0))
        public static let textSecondary = ColorPair(light: RGBA(0.3686, 0.3333, 0.2706, 1.0), dark: RGBA(0.7882, 0.7529, 0.698, 1.0))
        public static let textMuted = ColorPair(light: RGBA(0.4549, 0.4157, 0.3333, 1.0), dark: RGBA(0.6118, 0.5725, 0.502, 1.0), increasedLight: RGBA(0.3686, 0.3333, 0.2706, 1.0), increasedDark: RGBA(0.7882, 0.7529, 0.698, 1.0))
        public static let textInverse = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 1.0), dark: RGBA(0.1176, 0.102, 0.0784, 1.0))
        public static let textInverseMuted = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.6), dark: RGBA(0.1176, 0.102, 0.0784, 0.55))
        public static let textLink = ColorPair(light: RGBA(0.4784, 0.3059, 0.1686, 1.0), dark: RGBA(0.8078, 0.6118, 0.4, 1.0))
        public static let textLinkHover = ColorPair(light: RGBA(0.2824, 0.1569, 0.0941, 1.0), dark: RGBA(0.8745, 0.7098, 0.5216, 1.0))
        public static let borderCode = ColorPair(light: RGBA(0.9412, 0.9216, 0.8824, 0.09), dark: RGBA(0.9412, 0.9216, 0.8824, 0.09))
        public static let borderDefault = ColorPair(light: RGBA(0.9059, 0.8902, 0.851, 1.0), dark: RGBA(0.2, 0.1725, 0.1412, 1.0), increasedLight: RGBA(0.5804, 0.5412, 0.4549, 1.0), increasedDark: RGBA(0.4706, 0.4314, 0.349, 1.0))
        public static let borderStrong = ColorPair(light: RGBA(0.8353, 0.8118, 0.7529, 1.0), dark: RGBA(0.2706, 0.2353, 0.1922, 1.0))
        public static let borderInverse = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.18), dark: RGBA(0.1176, 0.102, 0.0784, 0.2))
        public static let borderControl = ColorPair(light: RGBA(0.5804, 0.5412, 0.4549, 1.0), dark: RGBA(0.4706, 0.4314, 0.349, 1.0))
        public static let borderControlHover = ColorPair(light: RGBA(0.3686, 0.3333, 0.2706, 1.0), dark: RGBA(0.7059, 0.6706, 0.5922, 1.0))
        public static let codeInk = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.82), dark: RGBA(0.9804, 0.9765, 0.9647, 0.82))
        public static let codeInkStrong = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.85), dark: RGBA(0.9804, 0.9765, 0.9647, 0.85))
        public static let codeInkBright = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(1.0, 1.0, 1.0, 1.0))
        public static let codeInkMuted = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.6), dark: RGBA(0.9804, 0.9765, 0.9647, 0.6))
        public static let codeInkSubtle = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.55), dark: RGBA(0.9804, 0.9765, 0.9647, 0.55))
        public static let codeInkFaint = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.35), dark: RGBA(0.9804, 0.9765, 0.9647, 0.35))
        public static let codeDivider = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.1), dark: RGBA(0.9804, 0.9765, 0.9647, 0.1))
        public static let codeEdge = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.25), dark: RGBA(0.9804, 0.9765, 0.9647, 0.25))
        public static let codeEdgeHover = ColorPair(light: RGBA(0.9804, 0.9765, 0.9647, 0.5), dark: RGBA(0.9804, 0.9765, 0.9647, 0.5))
        public static let codeRaised = ColorPair(light: RGBA(0.1176, 0.102, 0.0784, 0.85), dark: RGBA(0.1176, 0.102, 0.0784, 0.85))
        public static let overlayScrim = ColorPair(light: RGBA(0.1216, 0.102, 0.0784, 0.45), dark: RGBA(0.1216, 0.102, 0.0784, 0.45))
        public static let mediaBackdrop = ColorPair(light: RGBA(0.0784, 0.0706, 0.0627, 1.0), dark: RGBA(0.0784, 0.0706, 0.0627, 1.0))
        public static let mediaBackdropDot = ColorPair(light: RGBA(0.9529, 0.9373, 0.9059, 0.22), dark: RGBA(0.9529, 0.9373, 0.9059, 0.22))
        public static let mediaScrim = ColorPair(light: RGBA(0.0784, 0.0627, 0.0471, 0.55), dark: RGBA(0.0784, 0.0627, 0.0471, 0.55))
        public static let mediaScrimSoft = ColorPair(light: RGBA(0.0784, 0.0627, 0.0471, 0.45), dark: RGBA(0.0784, 0.0627, 0.0471, 0.45))
        public static let mediaScrimStrong = ColorPair(light: RGBA(0.0784, 0.0627, 0.0471, 0.7), dark: RGBA(0.0784, 0.0627, 0.0471, 0.7))
        public static let accent = ColorPair(light: RGBA(0.1725, 0.0902, 0.0353, 1.0), dark: RGBA(0.9529, 0.9373, 0.9059, 1.0))
        public static let accentHover = ColorPair(light: RGBA(0.1137, 0.0549, 0.0157, 1.0), dark: RGBA(1.0, 1.0, 1.0, 1.0))
        public static let accentActive = ColorPair(light: RGBA(0.0706, 0.0314, 0.0039, 1.0), dark: RGBA(0.8353, 0.8118, 0.7529, 1.0))
        public static let accentSubtle = ColorPair(light: RGBA(0.9725, 0.9569, 0.902, 1.0), dark: RGBA(0.1647, 0.1294, 0.098, 1.0))
        public static let accentSubtleBorder = ColorPair(light: RGBA(0.9373, 0.8118, 0.6745, 1.0), dark: RGBA(0.2706, 0.2157, 0.1569, 1.0))
        public static let accentContrast = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(0.1176, 0.102, 0.0784, 1.0))
        public static let accentSubtleFg = ColorPair(light: RGBA(0.4784, 0.3059, 0.1686, 1.0), dark: RGBA(0.8078, 0.6118, 0.4, 1.0))
        public static let focusRingColor = ColorPair(light: RGBA(0.4784, 0.3059, 0.1686, 1.0), dark: RGBA(0.8078, 0.6118, 0.4, 1.0))
        public static let focusRingOffset = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(0.1294, 0.1098, 0.0902, 1.0))
        public static let avatarBg = ColorPair(light: RGBA(0.9529, 0.9451, 0.9216, 1.0), dark: RGBA(0.1647, 0.1451, 0.1176, 1.0))
        public static let avatarFg = ColorPair(light: RGBA(0.3686, 0.3333, 0.2706, 1.0), dark: RGBA(0.7882, 0.7529, 0.698, 1.0))
        public static let stateHoverOnCard = ColorPair(light: RGBA(0.9529, 0.9451, 0.9216, 1.0), dark: RGBA(0.1647, 0.1451, 0.1176, 1.0))
        public static let stateHoverOnPanel = ColorPair(light: RGBA(0.9529, 0.9451, 0.9216, 1.0), dark: RGBA(0.1647, 0.1451, 0.1176, 1.0))
        public static let stateHoverOnTab = ColorPair(light: RGBA(1.0, 1.0, 1.0, 1.0), dark: RGBA(0.1294, 0.1098, 0.0902, 1.0))
        public static let stateHoverOnWindow = ColorPair(light: RGBA(0.9529, 0.9451, 0.9216, 1.0), dark: RGBA(0.1647, 0.1451, 0.1176, 1.0))
        public static let statePressed = ColorPair(light: RGBA(0.9059, 0.8902, 0.851, 1.0), dark: RGBA(0.2, 0.1725, 0.1412, 1.0), increasedLight: RGBA(0.5804, 0.5412, 0.4549, 1.0), increasedDark: RGBA(0.4706, 0.4314, 0.349, 1.0))
    }

    /// Lengths in points (CSS px = pt).
    public enum Length {
        public static let text2xs: Double = 11.0
        public static let textXs: Double = 12.0
        public static let textSm: Double = 13.0
        public static let textMd: Double = 14.0
        public static let textLg: Double = 16.0
        public static let textXl: Double = 18.0
        public static let text2xl: Double = 21.0
        public static let text3xl: Double = 26.0
        public static let text4xl: Double = 34.0
        public static let text5xl: Double = 44.0
        public static let text6xl: Double = 60.0
        public static let text7xl: Double = 76.0
        public static let avatarSm: Double = 24.0
        public static let avatarMd: Double = 32.0
        public static let avatarLg: Double = 40.0
        public static let space0: Double = 0.0
        public static let space1: Double = 4.0
        public static let space2: Double = 8.0
        public static let space3: Double = 12.0
        public static let space4: Double = 16.0
        public static let space5: Double = 20.0
        public static let space6: Double = 24.0
        public static let space8: Double = 32.0
        public static let space10: Double = 40.0
        public static let space12: Double = 48.0
        public static let space16: Double = 64.0
        public static let space20: Double = 80.0
        public static let space24: Double = 96.0
        public static let space32: Double = 128.0
        public static let space05: Double = 2.0
        public static let radiusXs: Double = 4.0
        public static let radiusXsPlus: Double = 6.0
        public static let radiusSm: Double = 8.0
        public static let radiusMd: Double = 12.0
        public static let radiusLg: Double = 16.0
        public static let radiusXl: Double = 24.0
        public static let radiusFull: Double = 999.0
        public static let containerMax: Double = 1200.0
        public static let containerText: Double = 720.0
        public static let controlHXs: Double = 24.0
        public static let controlHSm: Double = 28.0
        public static let controlHMd: Double = 36.0
        public static let controlHLg: Double = 44.0
        public static let iconXs: Double = 8.0
        public static let iconSm: Double = 12.0
        public static let iconMd: Double = 16.0
        public static let iconLg: Double = 20.0
        public static let iconXl: Double = 24.0
        public static let icon2xl: Double = 32.0
        public static let sidebarWidth: Double = 256.0
        public static let sidebarWidthIcon: Double = 48.0
        public static let tapMin: Double = 44.0
        public static let tablePadY: Double = 12.0
        public static let tablePadX: Double = 16.0
    }

    /// Lengths in points for compact density. Only the tokens that change.
    public enum Compact {
        public static let controlHXs: Double = 20.0
        public static let controlHSm: Double = 24.0
        public static let controlHMd: Double = 30.0
        public static let controlHLg: Double = 38.0
        public static let tablePadY: Double = 7.0
        public static let tablePadX: Double = 12.0
    }

    /// Unitless: line-height multipliers, opacities, font weights, z-index.
    public enum Number {
        public static let leadingTight: Double = 1.05
        public static let leadingSnug: Double = 1.25
        public static let leadingNormal: Double = 1.5
        public static let leadingRelaxed: Double = 1.65
        public static let weightRegular: Double = 400.0
        public static let weightMedium: Double = 500.0
        public static let weightSemibold: Double = 600.0
        public static let weightBold: Double = 700.0
        public static let weightDisplay: Double = 680.0
        public static let zDropdown: Double = 1000.0
        public static let zSticky: Double = 1100.0
        public static let zOverlay: Double = 1200.0
        public static let zModal: Double = 1300.0
        public static let zPopover: Double = 1400.0
        public static let zToast: Double = 1500.0
        public static let zTooltip: Double = 1600.0
        public static let opacityTint: Double = 0.12
        public static let opacityPill: Double = 0.1
        public static let opacityIncreased: Double = 0.16
        public static let opacityBanner: Double = 0.1
        public static let opacitySelected: Double = 0.1
        public static let opacityBannerEdge: Double = 0.25
        public static let opacityAttention: Double = 0.05
        public static let opacityAttentionEdge: Double = 0.25
        public static let opacityRing: Double = 0.7
        public static let opacityKbd: Double = 0.18
        public static let opacitySoftHairline: Double = 0.7
        public static let opacityChip: Double = 0.6
        public static let opacityDisabled: Double = 0.3
    }

    /// Letter spacing as a fraction of the font size.
    public enum Em {
        public static let trackingDisplay: Double = -0.02
        public static let trackingTight: Double = -0.01
        public static let trackingWide: Double = 0.06
    }

    /// Durations in seconds.
    public enum Duration {
        public static let durFast: Double = 0.1
        public static let durMed: Double = 0.16
        public static let durSlow: Double = 0.24
    }

    /// Cubic Bezier control points (x1, y1, x2, y2).
    public enum Curve {
        public static let easeSpring = Bezier(0.3, 1.04, 0.35, 1.0)
        public static let easeOut = Bezier(0.22, 1.0, 0.36, 1.0)
        public static let easeInOut = Bezier(0.65, 0.0, 0.35, 1.0)
    }
}

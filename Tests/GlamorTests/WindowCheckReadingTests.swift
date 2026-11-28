#if os(macOS)
import Foundation
import Testing

/// What the window check reads from the accessibility tree, after run 2 of v0.4.0 (14 FAIL, 7 UNPROVEN): the switch, the
/// marks and the sidebar's folded value were looked up by a role or a state the tree did not have. The window check itself
/// is the owner's sitting; these keep its lookups from going back to a guessed role.
struct WindowCheckReadingTests {
    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    private func read(_ path: String) throws -> String {
        try String(contentsOf: Self.root.appendingPathComponent(path), encoding: .utf8)
    }

    /// The source of one top-level `func name(` up to the next top-level declaration.
    private func body(of function: String, in text: String) throws -> String {
        let start = try #require(text.range(of: "func \(function)("), "no func \(function) in WindowCheck.swift")
        let rest = text[start.lowerBound...]
        let end = rest.dropFirst().range(of: "\n}\n")
        return String(rest[..<(end?.upperBound ?? rest.endIndex)])
    }

    // MARK: The switch (GL43)

    /// Run 2: `controls` kept only the roles it guessed, so a switch with any other role was "missing", was "not in the
    /// accessibility tree", and was the Tab stop after "Search hosts" that the walk could not name and stopped at.
    @Test func theSwitchIsFoundByItsNameInAnyRoleExceptStaticText() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("var isSwitchLike: Bool"))
        let controls = try #require(check.range(of: "var controls: [Control]"))
        let region = String(check[controls.lowerBound...].prefix(900))
        #expect(region.contains("isSwitchLike"))
        #expect(region.contains("switchName"), "a control named like the switch is listed whatever its role, so a wrong role fails by name")
        #expect(region.contains("AXStaticText"), "the card's own title text is not the switch")
    }

    /// Run 3 read the switch: role AXCheckBox, subrole AXToggle, role description "toggle button", AXValue 1, AXHelp the card's help
    /// line, frame 32 by 18. The list says exactly that (AXSwitch is a role this macOS never gave it), and the line says what was read.
    @Test func theSwitchListEntryExpectsRoleAXCheckBoxAndSubroleAXToggleAndTheLineSaysWhatWasRead() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains(#"role: "AXCheckBox", subrole: "AXToggle""#))
        #expect(!check.contains("acceptedRoles"), "one role is expected, so no list of accepted ones")
        let strings = try body(of: "stringsMode", in: check)
        #expect(strings.contains("c.subrole == e.subrole"))
        #expect(strings.contains(#"note("switch-ax""#))
        #expect(strings.contains("window \\(axFrame(t.window)"), "the NOTE gives the frame against the window's, so a cut-off switch shows")
    }

    /// The name of the role is the one the tree read, in every place that says it: the check, the tests, the CHANGELOG and README.
    @Test func noFileCallsTheSwitchAnAXSwitch() throws {
        for path in ["scripts/window/WindowCheck.swift", "CHANGELOG.md", "README.md", "ARCHITECTURE.md", "Tests/GlamorTests/AccentEdgeTests.swift"] {
            #expect(!(try read(path)).contains("AXSwitch"), "\(path) still says AXSwitch; the tree reads AXCheckBox with subrole AXToggle")
        }
        #expect(try read("CHANGELOG.md").contains("role AXCheckBox, subrole AXToggle"))
    }

    /// ToggleCard draws no `contentShape` and no tap on its row: the switch alone is the pointer target (32 by 18 at `.small`). WCAG 2.5.8 AA holds
    /// by the spacing exception, which is a CHECK; the row's own frame is measured too, and the line says it is not the target.
    @Test func theSwitchCardsRowIsMeasuredAndTheLineSaysTheSwitchAloneIsTheTarget() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let strings = try body(of: "stringsMode", in: check)
        #expect(strings.contains(#"check("target-row""#))
        #expect(strings.contains(#"note("target-row""#), "the pointer target is the switch alone: the NOTE says so")
        let controls = try read("Sources/Glamor/macOS/Controls.swift")
        let start = try #require(controls.range(of: "/// A bordered card with a title, a line of help and a switch"))
        let declaration = try #require(controls.range(of: "public struct ToggleCard<Extra: View>"))
        let end = try #require(controls.range(of: "/// Tabs drawn as words"))
        #expect(controls[start.lowerBound..<declaration.lowerBound].contains("Only the switch is the pointer target"))
        let card = String(controls[declaration.lowerBound..<end.lowerBound])
        #expect(!card.contains("contentShape"), "if the row becomes the target, this test and the NOTE change together")
    }

    // MARK: Tab order and keyboard focus

    @Test func theTabWalkNamesWhatHeldFocusWhereItStopped() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let keys = try body(of: "keysMode", in: check)
        #expect(keys.contains(#"note("tab-stop""#), "the walk says why it ended and what held focus")
        #expect(keys.contains("holder("), "an element that is not a listed control is named by role, subrole and description")
    }

    @Test func aSceneAsksForKeyboardFocusTheWayTheGenericLoopDoes() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("func focusByKeyboard("), "AXFocused first, then Tab")
        for scene in ["sidebarAKeys", "sidebarBKeys", "profileKeys"] {
            let text = try body(of: scene, in: check)
            #expect(text.contains("focusByKeyboard("), "\(scene) must not stop at AXFocused alone")
            #expect(!text.contains("t.focus("), "\(scene) calls t.focus directly")
        }
        let keys = try body(of: "keysMode", in: check)
        #expect(keys.contains("focusByKeyboard("))
    }

    @Test func aRowThatTakesNoKeyboardFocusPrintsTheStopsTabVisited() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let helper = try body(of: "focusByKeyboard", in: check)
        #expect(helper.contains("visited"), "the stops Tab visited are kept for the UNPROVEN line")
        #expect(check.contains("Tab visited:"))
    }

    // MARK: The marks (GL36)

    @Test func theMarksAreFoundByWhatTheyReadInAnyRole() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let elements = try body(of: "markElements", in: check)
        #expect(!elements.contains("AXStaticText"), "Pill(mark:) is one accessibility element with a label, not a static text")
        #expect(elements.contains("spokenName"))
        #expect(try body(of: "markFrames", in: check).contains("markElements("))
        let strings = try body(of: "marksStrings", in: check)
        #expect(strings.contains(#"note("mark-ax""#), "the role each mark really reads is printed")
        #expect(!strings.contains("static text read"))
    }

    @Test func aMarksRunThatFindsNothingPrintsWhatTheWindowHolds() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("func roleCensus("))
        #expect(try body(of: "marksPixels", in: check).contains("roleCensus("))
        #expect(try body(of: "marksStrings", in: check).contains("roleCensus("))
    }

    @Test func theMarksWindowIsReadyOnlyOnceItsTextsAreInTheTree() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("let readyTexts: Int"))
        #expect(check.contains("texts >= spec.readyTexts"))
        let scene = try read("Sources/GlamorGallery/Scenes/MarksScene.swift")
        #expect(scene.contains(".background(EnvironmentProbe())"), "the run's ENV line says the contrast in force, as the other scenes' do")
    }

    // MARK: The tree, for the next sitting

    @Test func theStringsRunOfTheComponentsAndMarksScenesPrintsTheWholeTree() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("func treeLines("))
        #expect(check.contains("var dumpsTree: Bool"))
        let strings = try body(of: "stringsMode", in: check)
        #expect(strings.contains("t.scene.dumpsTree"))
        #expect(strings.contains(#""TREE\t"#))
        let start = try #require(check.range(of: "let scenes: [String: SceneSpec]"))
        let list = String(check[start.lowerBound...].prefix(1800))
        #expect(list.components(separatedBy: "dumpsTree: true").count == 3, "components and marks, no other scene")
    }

    // MARK: The buttons (GL41)

    /// The Cancel corner reads the same colour as the ground, so it cannot tell a capsule from a rectangle. Save and Deploy
    /// prove the shape; Cancel is the same `G.controlShape`.
    @Test func theCapsuleIsReadOnSaveAndDeployAndCancelSaysWhyItIsNotRead() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let pixels = try body(of: "pixelsMode", in: check)
        #expect(pixels.contains(#"for name in ["Save", "Deploy"]"#))
        #expect(!pixels.contains(#"["Save", "Cancel", "Deploy"]"#))
        #expect(pixels.contains(#"note("button-shape""#))
        let buttons = try read("Sources/Glamor/macOS/Buttons.swift")
        let primary = try #require(buttons.range(of: "public struct PrimaryButtonStyle"))
        let secondary = try #require(buttons.range(of: "public struct SecondaryButtonStyle"))
        let ghost = try #require(buttons.range(of: "public struct GhostButtonStyle"))
        #expect(buttons[primary.lowerBound..<secondary.lowerBound].contains("in: G.controlShape"))
        #expect(buttons[secondary.lowerBound..<ghost.lowerBound].contains("in: G.controlShape"), "Cancel draws the shape Save does")
    }

    // MARK: The sidebar's folded value

    /// Run 2 read "collapsed" for Targets and expected "collapsed, Host selected". The row presses before it had chosen
    /// Settings, so Targets held no chosen place and "collapsed" was right. The check chooses Host first.
    @Test func theFoldedHeaderIsReadAfterChoosingThePlaceInsideIt() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let after = try body(of: "sidebarAAfterActions", in: check)
        let choose = try #require(after.range(of: "sidebarAStart"), "the check names the place it chooses")
        let fold = try #require(after.range(of: #"let folded = "collapsed, \(sidebarAStart) selected""#))
        #expect(choose.lowerBound < fold.lowerBound)
        #expect(after.contains(#"t.control(sidebarAStart)?.selected == true"#), "it waits until the place is chosen")
    }

    @Test func aFoldedHeaderThatDoesNotHoldTheChosenPlaceReadsCollapsedAlone() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let after = try body(of: "sidebarAAfterActions", in: check)
        #expect(after.contains(#"value == "collapsed""#))
        #expect(after.contains("Komando's own"), "a section that does not hold Host")
    }

    // MARK: Keys start from a known row (run 3: "Host" and "Doctor" UNPROVEN)

    /// Run 3 sent Tab to "Host" from wherever focus happened to be, and the first stop was an unnamed AXHostingView. A scene names the
    /// row its keys start from; the check puts focus there before any key, so the walk and the Space lines start from a defined stop.
    @Test func aSceneNamesTheRowItsKeysStartFromAndTheCheckFocusesItFirst() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("var startsOn: String? = nil"))
        #expect(check.contains(#"startsOn: "Home""#))
        let keys = try body(of: "keysMode", in: check)
        let start = try #require(keys.range(of: "t.scene.startsOn"))
        let walk = try #require(keys.range(of: "t.press(48)"))
        #expect(start.lowerBound < walk.lowerBound, "focus is put on the starting row before the first Tab")
        #expect(keys.contains(#"note("keys-start""#))
    }

    /// A row that cannot be focused by AXFocused is reached by Tab from the row before it, which is put in focus first: the Tab
    /// starts from a defined row, not from the previous control's leftover focus.
    @Test func tabToARowStartsFromTheRowBeforeItAndAFailurePrintsTheTreeEvidence() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let helper = try body(of: "focusByKeyboard", in: check)
        #expect(helper.contains("order[at - 1]"), "the row before it in the reading order is focused before Tab")
        #expect(helper.contains("focusEvidence("))
        let evidence = try body(of: "focusEvidence", in: check)
        #expect(evidence.contains(#"attr(c.element, "AXFocused")"#), "what the row says about its own focus")
        #expect(evidence.contains("t.focused"), "and what holds focus instead")
        #expect(try body(of: "noFocusText", in: check).contains("evidence"))
    }

    /// AXFocusedUIElement may hand back a fresh element for the row that holds focus: the same words are the same row.
    @Test func focusIsConfirmedByTheRowsNameAsWellAsItsElement() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("Control(element: f as! AXUIElement).name == c.name"))
    }
}
#endif

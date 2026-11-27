#if os(macOS)
import Glamor
import SwiftUI

/// The components the window check drives: a list, the buttons and menus, the segmented control, the theme switch, the
/// search field, a bar with a spinner, a progress bar and a ToggleCard. Its controls and their Tab order are the
/// `components` list in scripts/window/WindowCheck.swift.
struct ComponentsScene: View {
    /// A host name is data, not a word to translate.
    static let host = "web-1"
    @State private var choice = Period.daily
    @State private var segment = 0
    @State private var search = ""
    @State private var appearance = Appearance.light
    @State private var sheetShown = Options.openSheet
    @State private var reports = true
    @FocusState private var saveFocused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: G.Space.s16) {
            CardList {
                ListRow(action: { activated(ComponentsScene.host) }) { Text(verbatim: ComponentsScene.host) }
                ListRow(selected: true, action: { activated("db-primary") }) { Text(Words.text("row.selected", "db-primary")) }
                ListRow(action: { activated("queue-3") }) { Text(verbatim: "queue-3") }
            }
            HStack(spacing: G.Space.s16) {
                Button(Words.text("action.save")) { activated("Save") }.buttonStyle(PrimaryButtonStyle()).focused($saveFocused)
                Button(Words.text("action.cancel")) { activated("Cancel") }.buttonStyle(SecondaryButtonStyle())
                MenuPicker(title: choice.title, selection: $choice) {
                    Text(Period.daily.title).tag(Period.daily); Text(Period.weekly.title).tag(Period.weekly)
                }
                MoreMenu(label: ComponentsScene.host) {
                    Button(Words.text("action.rename")) { activated("Rename") }
                    Button(Words.text("action.remove")) { activated("Remove") }
                }
            }
            HStack(spacing: G.Space.s16) {
                Button(Words.text("action.deploy")) { activated("Deploy") }.glassMainAction(fallback: PrimaryButtonStyle())
                SegmentedControl(items: ["period.day", "period.week", "period.month"].map(Words.text), selection: $segment)
                ThemeSwitch(appearance: $appearance, words: .current)
            }
            SearchBar(placeholder: Words.text("search.hosts"), text: $search)
            Text(Words.text("toolbar.title")).textStyle(.caption).foregroundStyle(G.text2)
                .frame(maxWidth: .infinity, minHeight: G.Height.control32).glassBar()
                // A spinner with no label of its own: VoiceOver reads the library's "Working" (GL22).
                .overlay(alignment: .trailing) { SpinnerSlot(shown: true).padding(.trailing, G.Space.s12) }
            ProgressBar(value: 0.6)
            ToggleCard(title: Words.text("toggle.title"), help: Words.text("toggle.help"), isOn: $reports)
        }
        .textStyle(.body)
        .foregroundStyle(G.text)
        .padding(G.Space.s24)
        .frame(width: 460)
        .background(G.panel)
        .onAppear { saveFocused = true }
        .onChange(of: segment) { activated("segment \(segment)") }
        .onChange(of: appearance) { activated("theme \(appearance)") }
        .onChange(of: reports) { activated(reports ? "switch on" : "switch off") }
        .background(EnvironmentProbe())
        .sheet(isPresented: $sheetShown) {
            SheetLayout(symbol: "desktopcomputer", title: Words.text("sheet.title")) {
                Text(Words.text("sheet.body"))
            } buttons: {
                Button(Words.text("action.cancel")) { sheetShown = false }
                    .buttonStyle(SecondaryButtonStyle()).keyboardShortcut(.cancelAction)
            }
        }
    }
}
#endif

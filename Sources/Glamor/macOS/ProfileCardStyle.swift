#if os(macOS)
/// How a `ProfileCard` is drawn: the two-line `row` for the sidebar's footer (variant A), or the `avatar` alone for the
/// rail's footer (variant B). Both are one button with the same name.
public enum ProfileCardStyle: Sendable {
    case row, avatar
}
#endif

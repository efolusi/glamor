import Foundation

/// The number on a sidebar row, with the words VoiceOver reads for it. Glamor does not know what is being counted
/// (transfers, hosts, alerts), so the caller writes the sentence: "2 transfers running". Read by the Mac and the iOS `SidebarItem`.
public struct SidebarCount: Hashable, Sendable {
    public let value: Int
    public let spoken: String

    public init(_ value: Int, spoken: String) {
        self.value = value
        self.spoken = spoken
    }
}

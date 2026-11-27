#if os(macOS)
import Foundation

/// A demo choice, named by its catalog key.
struct Period: Hashable {
    let titleKey: String
    var title: String { Words.text(titleKey) }
    static let daily = Period(titleKey: "period.daily")
    static let weekly = Period(titleKey: "period.weekly")
}
#endif

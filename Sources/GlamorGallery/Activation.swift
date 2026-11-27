#if os(macOS)
import Foundation

extension Notification.Name { static let galleryActivated = Notification.Name("glamor.gallery.activated") }

/// Records a control's name, so a script can see that Space or Return reached it.
func activated(_ name: String) {
    NotificationCenter.default.post(name: .galleryActivated, object: name)
}
#endif

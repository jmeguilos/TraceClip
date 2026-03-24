import AppKit

final class SelectionOverlayWindow: NSWindow {
    init(screen: NSScreen, onSelection: @escaping (CGRect?) -> Void) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        let overlayView = SelectionOverlayView(
            frame: NSRect(origin: .zero, size: screen.frame.size),
            onComplete: onSelection
        )

        contentView = overlayView
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isReleasedWhenClosed = false
        setFrame(screen.frame, display: true)
    }

    override var canBecomeKey: Bool { true }
}

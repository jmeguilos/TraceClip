import AppKit

final class SelectionOverlayView: NSView {
    private var selectionRect: NSRect?
    private var dragOrigin: NSPoint?
    private let onComplete: (CGRect?) -> Void

    private let dimColor = NSColor.black.withAlphaComponent(0.3)
    private let borderColor = NSColor.white.withAlphaComponent(0.8)
    private let borderWidth: CGFloat = 1.5
    private let minimumSelectionSize: CGFloat = 5

    init(frame: NSRect, onComplete: @escaping (CGRect?) -> Void) {
        self.onComplete = onComplete
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    // MARK: - Responder

    override var acceptsFirstResponder: Bool { true }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        dimColor.setFill()
        bounds.fill()

        guard let rect = selectionRect?.standardized else { return }

        // Clear the selected region to show the screen beneath
        NSColor.clear.setFill()
        rect.fill(using: .copy)

        // Stroke the selection border
        let path = NSBezierPath(rect: rect)
        path.lineWidth = borderWidth
        borderColor.setStroke()
        path.stroke()
    }

    // MARK: - Mouse events

    override func mouseDown(with event: NSEvent) {
        dragOrigin = convert(event.locationInWindow, from: nil)
        selectionRect = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let origin = dragOrigin else { return }
        let current = convert(event.locationInWindow, from: nil)
        selectionRect = NSRect(
            x: origin.x,
            y: origin.y,
            width: current.x - origin.x,
            height: current.y - origin.y
        )
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard let rect = selectionRect?.standardized,
              rect.width >= minimumSelectionSize,
              rect.height >= minimumSelectionSize,
              let window = window else {
            onComplete(nil)
            return
        }

        let screenRect = window.convertToScreen(convert(rect, to: nil))
        onComplete(screenRect)
    }

    // MARK: - Keyboard

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            onComplete(nil)
        }
    }

    // MARK: - Cursor

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }
}

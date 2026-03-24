import AppKit
import ScreenCaptureKit

enum ScreenCaptureService {
    /// Captures the given screen-coordinate rect as a CGImage.
    /// The input rect uses AppKit coordinates (origin at bottom-left of primary screen, Y-up).
    /// Returns nil if capture fails (e.g. Screen Recording permission denied).
    static func capture(rect: CGRect) async -> CGImage? {
        guard let content = try? await SCShareableContent.current else { return nil }

        // Find the display containing the selection origin
        let display = content.displays.first { display in
            let frame = CGRect(
                x: CGFloat(display.frame.origin.x),
                y: CGFloat(display.frame.origin.y),
                width: CGFloat(display.frame.width),
                height: CGFloat(display.frame.height)
            )
            return frame.contains(rect.origin)
        } ?? content.displays.first

        guard let display else { return nil }

        let quartzRect = convertToQuartzCoordinates(rect)

        // Compute source rect relative to the display's origin
        let sourceRect = CGRect(
            x: quartzRect.origin.x - CGFloat(display.frame.origin.x),
            y: quartzRect.origin.y - CGFloat(display.frame.origin.y),
            width: quartzRect.width,
            height: quartzRect.height
        )

        // Use NSScreen to get the backing scale factor for this display
        let scaleFactor = NSScreen.screens.first { screen in
            Int(screen.frame.width) == display.width && Int(screen.frame.height) == display.height
        }?.backingScaleFactor ?? 2.0

        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = SCStreamConfiguration()
        config.sourceRect = sourceRect
        config.width = Int(sourceRect.width * scaleFactor)
        config.height = Int(sourceRect.height * scaleFactor)
        config.showsCursor = false
        config.captureResolution = .best

        return try? await SCScreenshotManager.captureImage(
            contentFilter: filter,
            configuration: config
        )
    }

    /// Converts an AppKit screen rect (Y-up, origin bottom-left of primary)
    /// to Quartz display coordinates (Y-down, origin top-left of primary).
    private static func convertToQuartzCoordinates(_ rect: CGRect) -> CGRect {
        guard let primaryScreen = NSScreen.screens.first else { return rect }
        let screenHeight = primaryScreen.frame.height
        return CGRect(
            x: rect.origin.x,
            y: screenHeight - rect.origin.y - rect.height,
            width: rect.width,
            height: rect.height
        )
    }
}

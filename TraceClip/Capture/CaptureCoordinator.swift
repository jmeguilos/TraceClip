import AppKit

enum CaptureResult {
    case success(String)
    case noTextFound
    case captureFailed
    case cancelled
}

final class CaptureCoordinator {
    private var overlayWindows: [SelectionOverlayWindow] = []
    private var completion: ((CaptureResult) -> Void)?

    func startCapture(completion: @escaping (CaptureResult) -> Void) {
        self.completion = completion

        for screen in NSScreen.screens {
            let window = SelectionOverlayWindow(screen: screen) { [weak self] rect in
                self?.handleSelection(rect)
            }
            overlayWindows.append(window)
        }

        NSApp.activate()

        for window in overlayWindows {
            window.makeKeyAndOrderFront(nil)
        }

        // Make the main screen's overlay the key window
        if let mainWindow = overlayWindows.first {
            mainWindow.makeKey()
            mainWindow.makeFirstResponder(mainWindow.contentView)
        }
    }

    private func handleSelection(_ rect: CGRect?) {
        tearDown()

        guard let rect else {
            finish(with: .cancelled)
            return
        }

        Task {
            guard let image = await ScreenCaptureService.capture(rect: rect) else {
                finish(with: .captureFailed)
                return
            }

            // Run OCR off the main thread
            let text = await Task.detached(priority: .userInitiated) {
                TextRecognizer.recognizeText(in: image)
            }.value

            guard let text else {
                finish(with: .noTextFound)
                return
            }

            let settings = SettingsStore.shared
            let processed = settings.keepLineBreaks ? text : text.replacingOccurrences(of: "\n", with: " ")

            ClipboardWriter.copy(processed)
            finish(with: .success(processed))
        }
    }

    private func finish(with result: CaptureResult) {
        let callback = completion
        completion = nil
        callback?(result)
    }

    private func tearDown() {
        for window in overlayWindows {
            window.orderOut(nil)
        }
        overlayWindows.removeAll()
    }
}

import AppKit
import SwiftUI

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private var preferencesWindow: NSWindow?
    private var captureCoordinator: CaptureCoordinator?

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()
        setupButton()
        setupMenu()
    }

    private func setupButton() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "TraceClip")
    }

    private func setupMenu() {
        let menu = NSMenu()

        let captureItem = NSMenuItem(title: "Capture Text", action: #selector(captureText), keyEquivalent: "")
        captureItem.target = self
        menu.addItem(captureItem)

        menu.addItem(.separator())

        let preferencesItem = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit TraceClip", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func captureText() {
        guard captureCoordinator == nil else { return }

        let coordinator = CaptureCoordinator()
        captureCoordinator = coordinator

        coordinator.startCapture { [weak self] result in
            self?.captureCoordinator = nil

            switch result {
            case .success:
                NSSound(named: .init("Tink"))?.play()
            case .noTextFound:
                self?.showError("No text was found in the selected region.")
            case .captureFailed:
                self?.showError(
                    "Screen capture failed. Please enable Screen Recording for TraceClip in System Settings → Privacy & Security."
                )
            case .cancelled:
                break
            }
        }
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "TraceClip"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }

    @objc private func openPreferences() {
        if preferencesWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 100),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.contentView = NSHostingView(rootView: PreferencesView())
            window.title = "TraceClip Preferences"
            window.center()
            window.isReleasedWhenClosed = false
            preferencesWindow = window
        }
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

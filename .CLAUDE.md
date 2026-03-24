# TraceClip

This file gives project-specific guidance for Claude Code when working in this repository.

## Project overview
TraceClip is a native macOS menu bar utility inspired by TextSniper.

The core user flow:
1. User triggers capture from the menu bar.
2. User drags to select a region on screen.
3. The app captures that region.
4. The app runs offline OCR using Apple Vision.
5. The recognized text is copied to the clipboard.

The app should feel:
- native
- lightweight
- fast
- polished
- privacy-friendly

Do not treat this as a generic AI app or a cross-platform app.

## Tech stack
- Swift
- SwiftUI
- AppKit where necessary
- Vision for OCR
- UserDefaults for settings
- XCTest for tests

## Build & Run

```bash
# Open in Xcode
open TraceClip.xcodeproj

# Build from CLI
xcodebuild -scheme TraceClip

# Run all tests
xcodebuild test -scheme TraceClip

# Unit tests only
xcodebuild test -scheme TraceClip -only-testing TraceClipTests

# UI tests only
xcodebuild test -scheme TraceClip -only-testing TraceClipUITests
```

## Architecture priorities
- Prefer native Apple frameworks over third-party dependencies.
- Use SwiftUI for simple views like preferences.
- Use AppKit for:
  - NSStatusItem
  - overlay windows
  - mouse event handling
  - cursor control
  - macOS-specific window behavior
- Keep files small and focused.
- Avoid giant view models and giant service classes.
- Keep responsibilities separated by folder and file.
- Do not overengineer.

## Current MVP scope
Build the smallest high-quality version first.

MVP includes:
- menu bar app shell
- Capture Text menu action
- Preferences window
- screen-region selection overlay
- offline OCR using Vision
- copy result to clipboard
- Keep line breaks preference

MVP does NOT include:
- cloud APIs
- LLM integration
- SwiftData or database storage
- sync
- capture history
- table extraction
- QR/barcode support
- text to speech
- additive clipboard
- configurable shortcuts
- multi-language OCR controls beyond what is necessary for a simple MVP

## File structure
- App/: app lifecycle and app delegate
- MenuBar/: status item and menu logic
- Capture/: selection overlay and capture coordination
- OCR/: Vision OCR logic
- Clipboard/: pasteboard logic
- Settings/: settings persistence
- Views/: preferences UI
- Support/: shared constants/helpers if needed

Respect the existing project structure unless a change is clearly justified.

## Coding style
- Favor clarity over cleverness.
- Prefer explicit, readable names.
- Keep functions focused.
- Split files before they become bloated.
- Add small comments only where they meaningfully help.
- Avoid unnecessary abstractions, protocols, or generic wrappers.
- Do not add dependencies unless there is a strong reason.
- Do not silently rewrite architecture.

## Workflow rules
For non-trivial tasks:
1. Inspect the current project first.
2. Summarize the current architecture briefly.
3. Propose a short implementation plan.
4. List the exact files you want to modify.
5. State assumptions, risks, or missing setup.
6. Wait for approval before making large changes.

For small targeted requests, implement directly if the requested scope is clear.

## Build quality
- Code must compile in Xcode.
- Preserve a clean native macOS architecture.
- Prefer the smallest implementation that works cleanly.
- When changing behavior, explain what changed and why.
- After implementation, summarize:
  - files changed
  - any required project setting changes
  - known limitations
  - next recommended step

## Settings and storage
- Use UserDefaults for simple preferences.
- Do not introduce SwiftData, Core Data, SQLite, or file persistence unless explicitly requested.
- Keep settings logic centralized.

## macOS-specific rules
- This is a menu bar app.
- The app should hide the Dock icon using LSUIElement when appropriate.
- Screen capture flows may require Screen Recording permission.
- OCR must run locally using Vision.
- Keep the menu bar behavior stable and simple.

## Testing
- Prefer unit tests for deterministic logic.
- Do not add UI tests unless explicitly requested.
- Add tests for text normalization and settings behavior when practical.

## Product intent
TraceClip should eventually be able to compete with lightweight Mac OCR tools, but the first priority is a reliable, polished baseline.
Do not prematurely optimize for future features.
Build the essentials first, then layer on parity features, then differentiators.

## Naming
Use the product name "TraceClip" consistently in code, comments, strings, and documentation unless explicitly told otherwise.

## Project config
- Bundle ID: `com.julesmarvine.TraceClip`
- Default actor isolation: `@MainActor`
- Approachable concurrency enabled
- App Sandbox and Hardened Runtime enabled
- No third-party dependencies currently

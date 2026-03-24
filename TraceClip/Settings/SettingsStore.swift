import Foundation

@Observable
final class SettingsStore {
    static let shared = SettingsStore()

    var keepLineBreaks: Bool {
        didSet { UserDefaults.standard.set(keepLineBreaks, forKey: "keepLineBreaks") }
    }

    private init() {
        // Default to true — preserve line breaks unless the user opts out
        UserDefaults.standard.register(defaults: ["keepLineBreaks": true])
        self.keepLineBreaks = UserDefaults.standard.bool(forKey: "keepLineBreaks")
    }
}

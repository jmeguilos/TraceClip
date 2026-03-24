import SwiftUI

struct PreferencesView: View {
    @State private var settings = SettingsStore.shared

    var body: some View {
        Form {
            Toggle("Keep line breaks", isOn: $settings.keepLineBreaks)
        }
        .formStyle(.grouped)
        .frame(width: 320, height: 100)
    }
}

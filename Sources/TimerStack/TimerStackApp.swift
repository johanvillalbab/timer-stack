import SwiftUI
import AppKit

@main
struct TimerStackApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        MenuBarExtra {
            Button("Mostrar / ocultar widget") { AppDelegate.shared?.togglePanel() }
                .keyboardShortcut("t")
            Divider()
            Button("Salir de TimerStack") { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        } label: {
            Image(systemName: "timer")
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    private var panelController: FloatingPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        NSApp.setActivationPolicy(.accessory)

        // Una sola instancia.
        let myPID = ProcessInfo.processInfo.processIdentifier
        let others = NSRunningApplication
            .runningApplications(withBundleIdentifier: "com.johanvillalba.timerstack")
            .filter { $0.processIdentifier != myPID }
        if !others.isEmpty { NSApp.terminate(nil) }

        panelController = FloatingPanelController(model: AppModel.shared)
        panelController?.show()
    }

    func togglePanel() { panelController?.toggle() }
}

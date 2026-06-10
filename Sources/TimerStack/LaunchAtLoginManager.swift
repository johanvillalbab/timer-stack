import Foundation
import ServiceManagement

/// Arranque al iniciar sesión vía SMAppService (patrón AudioPriorityBar).
/// Se auto-activa en el primer arranque; el toggle del menú permite apagarlo.
@MainActor
final class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()

    private let setupKey = "timerstack.didSetupLaunchAtLogin"

    @Published var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            isEnabled ? enable() : disable()
        }
    }

    private init() {
        isEnabled = SMAppService.mainApp.status == .enabled

        // Primer arranque: registrar por defecto.
        if !UserDefaults.standard.bool(forKey: setupKey), !isEnabled {
            isEnabled = true
            enable()
        }
    }

    private func enable() {
        do {
            try SMAppService.mainApp.register()
            UserDefaults.standard.set(true, forKey: setupKey)
        } catch {
            NSLog("TimerStack: no se pudo registrar el login item: \(error.localizedDescription)")
            DispatchQueue.main.async { self.isEnabled = false }
        }
    }

    private func disable() {
        do {
            try SMAppService.mainApp.unregister()
            UserDefaults.standard.set(true, forKey: setupKey)
        } catch {
            NSLog("TimerStack: no se pudo quitar el login item: \(error.localizedDescription)")
        }
    }
}

import SwiftUI
import AppKit

@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()

    @Published var timer: TimerItem? {
        didSet {
            save()
            syncTick()
        }
    }
    @Published var now = Date()

    private var tick: Timer?
    private let storageKey = "timerstack.timer"

    private init() {
        load()
        syncTick()
    }

    // MARK: - Acciones

    func set(duration: TimeInterval, autostart: Bool = true) {
        var t = TimerItem(duration: duration)
        if autostart { t.endDate = Date().addingTimeInterval(duration) }
        timer = t
    }

    func toggle() {
        guard var t = timer, !t.isFinished else { return }
        if t.isRunning {
            t.remainingWhenPaused = t.remaining()
            t.endDate = nil
        } else {
            t.endDate = Date().addingTimeInterval(t.remaining())
            t.remainingWhenPaused = nil
        }
        timer = t
    }

    func reset() {
        guard var t = timer else { return }
        t.endDate = nil
        t.remainingWhenPaused = nil
        t.isFinished = false
        timer = t
    }

    /// Quita el timer y vuelve a la vista de seteo de tiempo.
    func clear() {
        timer = nil
    }

    // MARK: - Tick de UI (solo corre si el timer está activo)

    private func syncTick() {
        let running = timer?.isRunning ?? false
        if running, tick == nil {
            let t = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.update() }
            }
            t.tolerance = 0.05
            tick = t
        } else if !running, tick != nil {
            tick?.invalidate()
            tick = nil
        }
    }

    private func update() {
        now = Date()
        guard var t = timer, t.isRunning, t.remaining(at: now) <= 0 else { return }
        t.isFinished = true
        t.endDate = nil
        timer = t
        playAlarm()
    }

    private func playAlarm() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.5) {
                NSSound(named: "Glass")?.play()
            }
        }
    }

    // MARK: - Persistencia (UserDefaults + Codable, patrón monitor-scale)

    private func save() {
        if let t = timer, let data = try? JSONEncoder().encode(t) {
            UserDefaults.standard.set(data, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              var saved = try? JSONDecoder().decode(TimerItem.self, from: data) else { return }
        // Si expiró con la app cerrada queda como terminado (sin alarma).
        if saved.isRunning && saved.remaining() <= 0 {
            saved.isFinished = true
            saved.endDate = nil
        }
        timer = saved
    }
}

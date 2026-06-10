import Foundation

/// Un cronómetro de cuenta regresiva.
/// Cuando corre, guarda `endDate` (fecha objetivo) — el tiempo restante se
/// calcula contra `Date()`, así que es inmune a drift y al sleep del Mac.
struct TimerItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var duration: TimeInterval                  // tiempo seteado
    var endDate: Date?                          // corriendo: fecha en la que llega a 0
    var remainingWhenPaused: TimeInterval?      // pausado a mitad de camino
    var isFinished = false

    var isRunning: Bool { endDate != nil && !isFinished }

    func remaining(at now: Date = Date()) -> TimeInterval {
        if isFinished { return 0 }
        if let end = endDate { return max(0, end.timeIntervalSince(now)) }
        return remainingWhenPaused ?? duration
    }

    /// Fracción de tiempo restante (1 → recién seteado, 0 → terminado).
    func fractionRemaining(at now: Date = Date()) -> Double {
        guard duration > 0 else { return 0 }
        return min(1, max(0, remaining(at: now) / duration))
    }
}

/// "MM:SS" o "H:MM:SS". Redondea hacia arriba para que el display
/// arranque en el tiempo completo y marque 0:00 justo al terminar.
func formatTime(_ t: TimeInterval) -> String {
    let total = max(0, Int(t.rounded(.up)))
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    return h > 0 ? String(format: "%d:%02d:%02d", h, m, s)
                 : String(format: "%02d:%02d", m, s)
}

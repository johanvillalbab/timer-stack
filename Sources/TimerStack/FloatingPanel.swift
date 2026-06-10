import AppKit
import SwiftUI

/// Panel flotante estilo widget (patrón Whisp): borderless, no roba foco,
/// siempre encima de todo y visible en todos los escritorios.
final class FloatingPanel: NSPanel {
    // Necesario para que los text fields del editor reciban teclado
    // sin activar la app (estilo Spotlight).
    override var canBecomeKey: Bool { true }
}

@MainActor
final class FloatingPanelController {
    let panel: FloatingPanel
    private let frameName = "TimerStackPanel"

    init(model: AppModel) {
        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 120),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.becomesKeyOnlyIfNeeded = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false

        let root = WidgetView(onResize: { [weak panel] size in
            guard let panel, size.width > 0, size.height > 0,
                  abs(panel.frame.height - size.height) > 0.5 || abs(panel.frame.width - size.width) > 0.5
            else { return }
            // Redimensionar anclado al borde superior (el widget crece hacia abajo).
            let origin = NSPoint(x: panel.frame.origin.x, y: panel.frame.maxY - size.height)
            panel.setFrame(NSRect(origin: origin, size: size), display: true)
        })
        .environmentObject(model)

        panel.contentView = NSHostingView(rootView: root)
        position()
    }

    private func position() {
        if !panel.setFrameUsingName(frameName), let screen = NSScreen.main {
            // Primera vez: arriba a la derecha.
            let v = screen.visibleFrame
            panel.setFrameTopLeftPoint(NSPoint(x: v.maxX - panel.frame.width - 24, y: v.maxY - 24))
        }
        panel.setFrameAutosaveName(frameName)
    }

    func show() { panel.orderFrontRegardless() }

    func toggle() {
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.orderFrontRegardless()
        }
    }
}

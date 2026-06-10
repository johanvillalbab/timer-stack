import SwiftUI

private let widgetWidth: CGFloat = 200

// MARK: - Vista raíz del widget (Liquid Glass)

struct WidgetView: View {
    @EnvironmentObject var model: AppModel
    var onResize: (CGSize) -> Void

    private var isAlarming: Bool { model.timer?.isFinished == true }

    var body: some View {
        Group {
            if model.timer != nil {
                CountdownView()
            } else {
                SetTimeView()
            }
        }
        .frame(width: widgetWidth)
        .fixedSize(horizontal: false, vertical: true)
        .glassEffect(
            isAlarming ? .regular.tint(.red.opacity(0.25)) : .regular,
            in: .rect(cornerRadius: 24, style: .continuous)
        )
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: WidgetSizeKey.self, value: geo.size)
            }
        )
        .onPreferenceChange(WidgetSizeKey.self) { onResize($0) }
    }
}

private struct WidgetSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

// MARK: - Cuenta regresiva (tiempo grande + 3 controles circulares de vidrio)

struct CountdownView: View {
    @EnvironmentObject var model: AppModel
    @State private var flash = false

    private var item: TimerItem { model.timer ?? TimerItem(duration: 0) }

    var body: some View {
        VStack(spacing: 14) {
            Text(formatTime(item.remaining(at: model.now)))
                .font(.system(size: 46, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(item.isFinished ? AnyShapeStyle(.red) : AnyShapeStyle(.primary))
                .opacity(flash ? 0.25 : 1)
                .contentTransition(.numericText(countsDown: true))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 16)

            // Los controles comparten un contenedor de vidrio: al estar cerca,
            // Liquid Glass fusiona sus formas entre sí.
            GlassEffectContainer(spacing: 14) {
                HStack(spacing: 14) {
                    if !item.isFinished {
                        controlButton(item.isRunning ? "pause.fill" : "play.fill") {
                            model.toggle()
                        }
                    }
                    controlButton("arrow.counterclockwise") {
                        model.reset()
                    }
                    controlButton("xmark") {
                        model.clear()
                    }
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
        .onChange(of: item.isFinished) { _, finished in
            updateFlash(finished)
        }
        .onAppear { updateFlash(item.isFinished) }
    }

    private func updateFlash(_ finished: Bool) {
        if finished {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                flash = true
            }
        } else {
            withAnimation(.easeOut(duration: 0.15)) { flash = false }
        }
    }

    private func controlButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

// MARK: - Seteo de tiempo (cuando no hay timer)

struct SetTimeView: View {
    @EnvironmentObject var model: AppModel
    @State private var minutes = ""
    @State private var seconds = ""

    private let presets = [1, 5, 10, 15, 25]

    var body: some View {
        VStack(spacing: 12) {
            Text("Timer")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            GlassEffectContainer(spacing: 5) {
                HStack(spacing: 5) {
                    ForEach(presets, id: \.self) { m in
                        Button {
                            model.set(duration: TimeInterval(m * 60))
                        } label: {
                            Text("\(m)′")
                                .font(.caption.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive(), in: .capsule)
                    }
                }
            }

            HStack(spacing: 5) {
                TextField("min", text: $minutes)
                    .frame(width: 42)
                Text(":")
                    .foregroundStyle(.secondary)
                TextField("seg", text: $seconds)
                    .frame(width: 42)
                Spacer()
                Button("Iniciar") { startCustom() }
                    .font(.caption.weight(.semibold))
                    .controlSize(.small)
                    .buttonStyle(.glass)
                    .keyboardShortcut(.defaultAction)
            }
            .textFieldStyle(.roundedBorder)
            .controlSize(.small)
            .font(.caption.monospacedDigit())
            .multilineTextAlignment(.center)
            .onSubmit { startCustom() }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }

    private func startCustom() {
        let m = Int(minutes) ?? 0
        let s = Int(seconds) ?? 0
        let d = TimeInterval(m * 60 + s)
        guard d > 0 else { return }
        model.set(duration: d)
        minutes = ""
        seconds = ""
    }
}

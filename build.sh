#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP="dist/TimerStack.app"

echo "▸ Compilando…"
swift build -c release

echo "▸ Ensamblando $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/release/TimerStack" "$APP/Contents/MacOS/TimerStack"
cp "Info.plist"                "$APP/Contents/Info.plist"
chmod +x "$APP/Contents/MacOS/TimerStack"

echo "▸ Firmando (ad-hoc)…"
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true

echo "✓ Listo: $APP"

if [ "${1:-}" = "install" ]; then
  echo "▸ Instalando en /Applications…"
  rsync -a --delete "$APP/" "/Applications/TimerStack.app/"
  codesign --force --deep --sign - "/Applications/TimerStack.app" >/dev/null 2>&1 || true
  echo "✓ Instalado: /Applications/TimerStack.app"
fi

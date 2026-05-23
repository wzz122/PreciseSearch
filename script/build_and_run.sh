#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="PreciseSearch"
BUNDLE_ID="com.wzz122.PreciseSearch"
MIN_SYSTEM_VERSION="14.0"
SIGNING_IDENTITY="${CODESIGN_IDENTITY:-}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
STAGE_DIR="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/PreciseSearch.XXXXXX")"
STAGE_APP_BUNDLE="$STAGE_DIR/$APP_NAME.app"
APP_CONTENTS="$STAGE_APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
ICON_SOURCE="$ROOT_DIR/Resources/AppIcon.icns"

cleanup() {
  rm -rf "$STAGE_DIR"
}
trap cleanup EXIT

cd "$ROOT_DIR"

pkill -x "$APP_NAME" >/dev/null 2>&1 || true

swift build
BUILD_BINARY="$(swift build --show-bin-path)/$APP_NAME"

mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

if [[ -f "$ICON_SOURCE" ]]; then
  cp "$ICON_SOURCE" "$APP_RESOURCES/AppIcon.icns"
fi

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.2</string>
  <key>CFBundleVersion</key>
  <string>3</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

if [[ -z "$SIGNING_IDENTITY" ]]; then
  SIGNING_IDENTITY="$(/usr/bin/security find-identity -v -p codesigning 2>/dev/null | /usr/bin/awk -F '\"' '/Apple Development/ { print $2; exit }')"
fi

if [[ -z "$SIGNING_IDENTITY" ]]; then
  SIGNING_IDENTITY="-"
fi

/usr/bin/xattr -cr "$STAGE_APP_BUNDLE" >/dev/null 2>&1 || true
/usr/bin/codesign --force --deep --sign "$SIGNING_IDENTITY" "$STAGE_APP_BUNDLE" >/dev/null
/usr/bin/codesign --verify --deep --strict "$STAGE_APP_BUNDLE" >/dev/null

rm -rf "$APP_BUNDLE"
mkdir -p "$DIST_DIR"
/usr/bin/ditto --norsrc "$STAGE_APP_BUNDLE" "$APP_BUNDLE"

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac

#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:?usage: release.sh <app_name> <app_bundle> <dmg_path>}"
APP_BUNDLE="${2:?usage: release.sh <app_name> <app_bundle> <dmg_path>}"
DMG_PATH="${3:?usage: release.sh <app_name> <app_bundle> <dmg_path>}"

if [ -f .env ]; then
    set -a
    . ./.env
    set +a
fi

: "${DEV_ID:?DEV_ID not set — copy .env.example to .env and fill in}"
: "${NOTARY_PROFILE:?NOTARY_PROFILE not set — copy .env.example to .env and fill in}"

codesign --force --options runtime --timestamp --sign "$DEV_ID" "$APP_BUNDLE"
rm -f "$DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$APP_BUNDLE" -ov -format UDZO "$DMG_PATH" > /dev/null
codesign --force --timestamp --sign "$DEV_ID" "$DMG_PATH"
xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG_PATH"
echo "Signed + notarized: $DMG_PATH"

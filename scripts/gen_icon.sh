#!/usr/bin/env bash
set -euo pipefail

SRC="${1:?usage: gen_icon.sh <source.png> <output.icns>}"
OUT="${2:?usage: gen_icon.sh <source.png> <output.icns>}"

WORK="$(dirname "$OUT")/_iconset.tmp"
ICONSET="$WORK/AppIcon.iconset"
rm -rf "$WORK"
mkdir -p "$ICONSET"

W=$(sips -g pixelWidth "$SRC" | awk '/pixelWidth/ {print $2}')
H=$(sips -g pixelHeight "$SRC" | awk '/pixelHeight/ {print $2}')
SIDE=$((W > H ? W : H))
SQUARE="$WORK/square.png"
sips -p "$SIDE" "$SIDE" "$SRC" --out "$SQUARE" > /dev/null

for s in 16 32 64 128 256 512 1024; do
    sips -z "$s" "$s" "$SQUARE" --out "$WORK/$s.png" > /dev/null
done

cp "$WORK/16.png"   "$ICONSET/icon_16x16.png"
cp "$WORK/32.png"   "$ICONSET/icon_16x16@2x.png"
cp "$WORK/32.png"   "$ICONSET/icon_32x32.png"
cp "$WORK/64.png"   "$ICONSET/icon_32x32@2x.png"
cp "$WORK/128.png"  "$ICONSET/icon_128x128.png"
cp "$WORK/256.png"  "$ICONSET/icon_128x128@2x.png"
cp "$WORK/256.png"  "$ICONSET/icon_256x256.png"
cp "$WORK/512.png"  "$ICONSET/icon_256x256@2x.png"
cp "$WORK/512.png"  "$ICONSET/icon_512x512.png"
cp "$WORK/1024.png" "$ICONSET/icon_512x512@2x.png"

iconutil -c icns "$ICONSET" -o "$OUT"
rm -rf "$WORK"
echo "Generated: $OUT"

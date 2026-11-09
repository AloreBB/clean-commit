#!/usr/bin/env bash
# Render every HTML in this folder to PNG with headless Chrome.
set -euo pipefail
cd "$(dirname "$0")"; OUT=../screenshots; CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
python3 build.py
for f in 0*.html; do "$CH" --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=1 --window-size=1600,1000 --screenshot="$OUT/${f%.html}.png" "file://$PWD/$f" 2>/dev/null; done
"$CH" --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=2 --default-background-color=00000000 --window-size=640,150 --screenshot="../install-button.png" "file://$PWD/install-button.html" 2>/dev/null
"$CH" --headless --disable-gpu --hide-scrollbars --window-size=512,512 --screenshot="../logo-512.png" "file://$PWD/logo.html" 2>/dev/null
ls -la $OUT ../logo-512.png

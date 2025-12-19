@'
#!/usr/bin/env bash
set -e
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.38.5
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter pub get
flutter build web --release --no-wasm-dry-run
'@ | Set-Content -Path vercel-build.sh -NoNewline -Encoding UTF8
#!/usr/bin/env bash
dart2js -O0 -o out.js main.dart
cat dart_main_runner.js node_preamble.js out.js > main.js
rm out.*

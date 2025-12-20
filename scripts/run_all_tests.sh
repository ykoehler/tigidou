#!/bin/bash

# Exit on error
set -e

echo "🚀 Running Unit and Widget tests..."
flutter test

echo "🚀 Running Integration tests..."

# Check for available devices
DEVICES=$(flutter devices --machine)

if echo "$DEVICES" | grep -q '"id": *"macos"'; then
  echo "✅ Detected macOS desktop. Using flutter test for integration tests (native runner requires additional setup)."
  flutter test integration_test/login_flow_test.dart -d macos
elif echo "$DEVICES" | grep -q '"id": *"chrome"'; then
  echo "✅ Detected Chrome. Using flutter test for integration tests."
  flutter test integration_test/login_flow_test.dart -d chrome
else
  echo "🚀 No desktop device detected. Attempting to use Patrol on first available device..."
  patrol test -t integration_test
fi

echo "✨ All tests passed!"

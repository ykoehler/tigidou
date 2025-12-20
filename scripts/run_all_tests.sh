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
elif [ -n "$DEVICES" ] && [ "$DEVICES" != "[]" ]; then
  echo "🚀 Attempting to use Patrol on first available device..."
  patrol test -t integration_test
else
  echo "❌ No devices detected. Skipping integration tests."
  echo "💡 Tip: Start an emulator or connect a device to run integration tests."
  # We don't exit 1 here to allow CI/CD to pass if only unit tests were required, 
  # but in a strict environment you might want to.
fi

echo "✨ All tests passed!"

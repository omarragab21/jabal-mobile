#!/bin/bash
set -euo pipefail

# Navigate to the Flutter project root
cd "$(dirname "$0")"

# Ensure UTF-8 encoding (required by CocoaPods) and Flutter/Homebrew in PATH
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PATH="$HOME/development/flutter/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "=========================================="
echo "🚀 Starting Dr Jabel TestFlight Deployment"
echo "=========================================="

# Auto-increment build number in pubspec.yaml unless --no-bump is passed
if [[ "${1:-}" != "--no-bump" ]]; then
  CURRENT_VERSION=$(grep -E '^version:\s*' pubspec.yaml | awk '{print $2}')
  VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
  BUILD_NUM=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)
  NEW_BUILD_NUM=$((BUILD_NUM + 1))
  NEW_VERSION="${VERSION_NAME}+${NEW_BUILD_NUM}"
  sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml
  echo "📌 Bumped version: ${CURRENT_VERSION} -> ${NEW_VERSION}"
else
  CURRENT_VERSION=$(grep -E '^version:\s*' pubspec.yaml | awk '{print $2}')
  echo "📌 Using current version: ${CURRENT_VERSION}"
fi

echo "🧹 Step 1/4: Running flutter clean..."
flutter clean

echo "📦 Step 2/4: Running flutter pub get..."
flutter pub get

echo "🍫 Step 3/4: Installing CocoaPods (pod install)..."
(cd ios && pod install)

echo "🏗️  Step 4/4: Building Release Archive & Uploading to TestFlight..."
# Note: When ExportOptions.plist uses destination=upload, xcodebuild uploads directly to
# App Store Connect instead of creating build/ios/ipa/, which can cause flutter_tools
# to throw PathNotFoundException when checking build/ios/ipa size after upload succeeds.
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist || true
rm -f flutter_*.log

ARCHIVE_PLIST="build/ios/archive/Runner.xcarchive/Info.plist"
if [[ ! -f "$ARCHIVE_PLIST" ]] || ! grep -q "<key>uploadedBuildNumber</key>" "$ARCHIVE_PLIST"; then
  echo "❌ Error: Archive export / TestFlight upload failed."
  exit 1
fi

UPLOADED_BUILD=$(/usr/libexec/PlistBuddy -c "Print :Distributions:0:uploadedBuildNumber" "$ARCHIVE_PLIST" 2>/dev/null || echo "unknown")
ADAM_ID=$(/usr/libexec/PlistBuddy -c "Print :Distributions:0:adamId" "$ARCHIVE_PLIST" 2>/dev/null || echo "unknown")

echo "=========================================="
echo "✅ Successfully built and uploaded to TestFlight!"
echo "   • App ID (adamId): ${ADAM_ID}"
echo "   • Uploaded Build:  ${UPLOADED_BUILD}"
echo "=========================================="

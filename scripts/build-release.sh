#!/bin/bash

# Moji Slicer Release Build Script
# Usage: ./scripts/build-release.sh

set -e

PROJECT_NAME="Moji Slicer"
SCHEME="Moji Slicer"
CONFIGURATION="Release"
BUILD_DIR="$(pwd)/releases"
APP_NAME="Moji Slicer.app"

echo "🚀 Building ${PROJECT_NAME} for release..."

# Clean build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Build the project
echo "📦 Building ${SCHEME}..."
xcodebuild \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${BUILD_DIR}/DerivedData" \
    -archivePath "${BUILD_DIR}/${PROJECT_NAME}.xcarchive" \
    archive

# Export the app
echo "📤 Exporting app..."
xcodebuild \
    -exportArchive \
    -archivePath "${BUILD_DIR}/${PROJECT_NAME}.xcarchive" \
    -exportPath "${BUILD_DIR}" \
    -exportOptionsPlist "$(pwd)/scripts/ExportOptions.plist"

# Create ZIP for distribution
echo "🗜️ Creating distribution ZIP..."
cd "${BUILD_DIR}"
zip -r "${PROJECT_NAME}-$(date +%Y%m%d).zip" "${APP_NAME}"

echo "✅ Release build complete!"
echo "📁 App location: ${BUILD_DIR}/${APP_NAME}"
echo "📦 ZIP location: ${BUILD_DIR}/${PROJECT_NAME}-$(date +%Y%m%d).zip"

# Open the releases folder
open "${BUILD_DIR}"

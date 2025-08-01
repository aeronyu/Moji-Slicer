#!/bin/bash

# Quick Release Script for Moji Slicer
# Usage: ./scripts/quick-release.sh v1.0.0

set -e

if [ $# -eq 0 ]; then
    echo "❌ Please provide a version tag (e.g., v1.0.0)"
    exit 1
fi

VERSION=$1
REPO_OWNER="YOUR_USERNAME"  # 👈 UPDATE THIS
REPO_NAME="moji-slicer"     # 👈 UPDATE THIS

echo "🚀 Creating release ${VERSION} for ${REPO_OWNER}/${REPO_NAME}"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   brew install gh"
    exit 1
fi

# Build the release
echo "📦 Building release..."
./scripts/build-release.sh

# Create git tag
echo "🏷️ Creating git tag..."
git tag "${VERSION}"
git push origin "${VERSION}"

# Create GitHub release
echo "🚀 Creating GitHub release..."
gh release create "${VERSION}" \
    --title "Moji Slicer ${VERSION}" \
    --notes "🎉 New release of Moji Slicer with enhanced UI and functionality.

## 📥 Installation
1. Download the ZIP file below
2. Unzip and drag \`Moji Slicer.app\` to \`/Applications\`
3. Launch and enjoy!

## 🔧 Requirements
- macOS 15.0 or later

## ✨ Features
- Modern SwiftUI interface
- Grid-based image slicing
- Merged Select & Move tools
- Bottom-left zoom controls
- Icon-only UI with tooltips" \
    releases/Moji\ Slicer-*.zip

echo "✅ Release ${VERSION} created successfully!"
echo "🌐 View at: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${VERSION}"

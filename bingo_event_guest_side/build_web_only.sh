#!/bin/bash
# Flutter Web Build Script - Web Only
# This script builds the Flutter web application with NO extra platforms
# Usage: ./build_web_only.sh (from bingo_event_guest_side directory)

echo "Building Flutter Web Application (Web Only)..."
echo "================================================"

# Clean previous build
echo "Cleaning previous build..."
flutter clean

# Build web only - no android, ios, linux, macos, windows
echo "Building web application..."
flutter build web --release --web-renderer=html

echo "Build complete!"
echo "Web application ready in: build/web/"

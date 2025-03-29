#!/bin/bash

# Install Flutter
curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar -xf flutter.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
flutter --version

# Enable web support
flutter config --enable-web

# Install dependencies
flutter pub get

# Build for web
flutter build web

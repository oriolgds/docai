# Python Integration Setup

## Overview

The app uses `serious_python` to run an embedded Python HTTP server that handles Gradio API calls. Flutter communicates with this server via HTTP streaming.

## Package Python App

### Android
```bash
set SERIOUS_PYTHON_SITE_PACKAGES=%cd%\build\site-packages
dart run serious_python:main package python_app -p Android --requirements -r,python_app/requirements.txt
```

### iOS
```bash
export SERIOUS_PYTHON_SITE_PACKAGES=$(pwd)/build/site-packages
dart run serious_python:main package python_app -p iOS --requirements -r,python_app/requirements.txt
```

### macOS
```bash
dart run serious_python:main package python_app -p macOS --requirements -r,python_app/requirements.txt
```

### Windows
```bash
dart run serious_python:main package python_app -p Windows --requirements -r,python_app/requirements.txt
```

### Linux
```bash
dart run serious_python:main package python_app -p Linux --requirements -r,python_app/requirements.txt
```

This creates `python_app/app.zip` configured as an asset in `pubspec.yaml`.

## How It Works

1. Python HTTP server runs on `127.0.0.1:8765`
2. Flutter sends POST requests with message, history, system prompt, and temperature
3. Python streams responses back via Server-Sent Events (SSE)
4. Flutter displays streaming text in real-time

## After Packaging

Run `flutter pub get` to install dependencies and recognize assets.

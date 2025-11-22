# Stitchanda Multi-Application Flutter Project

This repository contains **three independent Flutter applications**, each developed as part of the Stitchanda ecosystem:

1. **Stitchanda Customer Application**
2. **Stitchanda Tailor Application**
3. **Stitchanda Driver Application**

Each application uses a **different Flutter SDK version**, managed through **FVM (Flutter Version Management)** to ensure consistency and prevent version conflicts across environments.

This document provides a **complete installation and setup guide** for running all three applications on a new system, including manual Flutter installation, Android Studio configuration, FVM setup, and execution steps.

## Table of Contents

- [System Requirements](#system-requirements)
- [Installation Guide](#installation-guide)
- [FVM Setup](#fvm-setup)
- [Running the Applications](#running-the-applications)
- [Important Notes](#important-notes)
- [Troubleshooting](#troubleshooting)

## System Requirements

- **Operating System:** Windows 10 or later
- **RAM:** Minimum 8 GB (16 GB recommended)
- **Disk Space:** 10 GB+
- **Tools Required:**
  - Git
  - Visual Studio Code
  - Android Studio (with SDK + Emulator)
  - Flutter SDK (manual installation)
  - FVM (Flutter Version Manager)

## Installation Guide

The following steps must be completed before running any of the Stitchanda applications.

### 2.1 Install Git

Download and install from: [https://git-scm.com/downloads](https://git-scm.com/downloads)

Use default installation settings.

### 2.2 Install Visual Studio Code

Download from: [https://code.visualstudio.com/](https://code.visualstudio.com/)

After installation, open VS Code and install the following extensions:

- **Flutter**
- **Dart**

### 2.3 Install Android Studio

Download Android Studio: [https://developer.android.com/studio](https://developer.android.com/studio)

During installation, ensure the following components are selected:

- Android SDK
- Android SDK Platform
- Android SDK Build-tools
- Android Virtual Device
- Android SDK Command-line Tools

After installation:

1. Open **Android Studio → More Actions → SDK Manager**
2. Ensure the following are installed:
   - Android API 34 (or latest stable)
   - Android SDK Platform Tools
   - Android SDK Build Tools
   - Android Emulator

### 2.4 Install Flutter SDK

*(This is required even though FVM will manage versions.)*

1. Download Flutter from the official website: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

2. Extract the Flutter SDK to a location such as:
   ```
   C:\src\flutter
   ```

3. Add Flutter to the system PATH:
   - Open **Environment Variables**
   - Select **Path**
   - Add:
     ```
     C:\src\flutter\bin
     ```

4. Restart terminal and verify:
   ```bash
   flutter --version
   ```

### 2.5 Run Flutter Doctor

```bash
flutter doctor
```

Fix any missing items (especially Android toolchain).

## FVM Setup

The Stitchanda project uses multiple Flutter versions. FVM ensures each app uses its correct version automatically.

### 3.1 Install FVM

```bash
dart pub global activate fvm
```

### 3.2 Add FVM to PATH

Add the following path to your system environment variables:

```
C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin
```

Verify installation:

```bash
fvm --version
```

## Running the Applications

Each application is isolated and must be run individually.

### 4.1 Run Stitchanda Customer Application

```bash
cd stitchanda_customer
fvm install
fvm flutter pub get
fvm flutter run
```

### 4.2 Run Stitchanda Tailor Application

```bash
cd stitchanda_tailor
fvm install
fvm flutter pub get
fvm flutter run
```

### 4.3 Run Stitchanda Driver Application

```bash
cd stitchanda_driver
fvm install
fvm flutter pub get
fvm flutter run
```

## Important Notes

### Manual Flutter installation is required

Even though FVM manages SDKs per project, the base Flutter installation is needed for:

- Dart & Flutter toolchain detection
- Android Studio integration
- VS Code Flutter extension support

### FVM reads .fvmrc automatically

FVM installs and uses the correct Flutter version for each app.

### Running in VS Code

Open **each app folder separately** in VS Code. Do *not* open the main root folder containing all apps.

## Troubleshooting

### FVM command not found

Add this path to your environment variables:

```
C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin
```

Restart terminal.

### Emulator not detected

Open Android Studio → Device Manager → Create a new virtual device.

### Build errors

Run:

```bash
fvm flutter clean
fvm flutter pub get
```


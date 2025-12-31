# Carrot 🥕

<p align="center">
  <img src="https://github.com/joehinkle11/carrot/blob/main/Sources/Carrot/Resources/Module.xcassets/carrot.imageset/carrot.png?raw=true" alt="Carrot Logo" width="200"/>
</p>

A simple, cross-platform habit tracker app built with [Skip](https://skip.tools) for iOS and Android.

## Screenshots

<!-- TODO: Add screenshots -->

## Features

- **Track Page** - View all your trackables in a grid. Tap to log an occurrence for the day.
- **Goals/Habits Page** - Create, rename, and delete habits or goals you want to track.
- **History Page** - View your tracking history with day-by-day counts. Export to CSV.

All data is stored locally on your device using SQLite.

## Building

This project is both a stand-alone Swift Package Manager module,
as well as an Xcode project that builds and transpiles the project
into a Kotlin Gradle project for Android using the Skip plugin.

Building the module requires that Skip be installed using
[Homebrew](https://brew.sh) with `brew install skiptools/skip/skip`.

This will also install the necessary transpiler prerequisites:
Kotlin, Gradle, and the Android build tools.

Installation prerequisites can be confirmed by running `skip checkup`.

## Running

Xcode and Android Studio must be downloaded and installed in order to
run the app in the iOS simulator / Android emulator.
An Android emulator must already be running, which can be launched from
Android Studio's Device Manager.

To run both the Swift and Kotlin apps simultaneously,
launch the Carrot target from Xcode.
A build phase runs the "Launch Android APK" script that
will deploy the transpiled app to a running Android emulator or connected device.
Logging output for the iOS app can be viewed in the Xcode console, and in
Android Studio's logcat tab for the transpiled Kotlin app.

## Author

Created by Joseph Hinkle on December 31st, 2025.

## License

This software is licensed under the [GNU General Public License v2.0 or later](https://spdx.org/licenses/GPL-2.0-or-later.html).

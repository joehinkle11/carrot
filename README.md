# Carrot 🥕

<p align="center">
  <img src="https://github.com/joehinkle11/carrot/blob/main/Sources/Carrot/Resources/Module.xcassets/carrot.imageset/carrot.png?raw=true" alt="Carrot Logo" width="200"/>
</p>

A dead-simple habit tracker. Tap a thing, count goes up. That's it.

Built for iOS and Android with [Skip](https://skip.tools).

## Why Carrot?

Other habit trackers want to be your life coach. Streaks! Badges! Reminders! Charts! 📊🏆🔔

Carrot just asks: *How many times did you do the thing today?*

- Drank water? Tap. 💧
- Worked out? Tap. 💪
- Ate junk food? ...Tap. 🍕 *(hey, we don't judge)*

No timestamps. No notes. No guilt. Just counts.

## Download

iOS TestFlight link: https://testflight.apple.com/join/zz62H8P3

APK available on GitHub release: todo

## Features

- 📊 **Track** — Tap to count. Navigate between days.
- 🥕 **Manage** — Add, rename, delete habits.
- 📈 **History** — See your counts. Export to CSV.

All local. All yours. SQLite under the hood.

## The Story

Two days before 2025 ended, I wanted to track some habits for 2026. Every app was overkill. So I vibe-coded this with [Cursor](https://cursor.com) + [Skip](https://skip.tools) in one sitting.

Check `.cursor/rules/milestones.mdc` if you're curious how it was built.

## Run It

```bash
brew install skiptools/skip/skip
skip checkup
```

Then open in Xcode and hit run. Works on iOS and Android.

---

Made by **Joseph Hinkle** • Dec 31, 2025 • [GPL-2.0-or-later](https://spdx.org/licenses/GPL-2.0-or-later.html)

## Change History

### 1.0.0

Basic MVP working:
- 📊 **Track Tab** — Tap habits to log counts for the day
- 📅 **Date Navigation** — Left/right arrows to navigate between days
- ⚙️ **Advanced Mode** — Toggle +/- buttons for precise count control
- 🥕 **Goals Tab** — Add, rename, and delete habits/goals
- 📈 **History Tab** — View 30-day history per trackable
- 📤 **CSV Export** — Export history with copy button
- ℹ️ **App Info** — Info sheet with version and creator
- 💾 **Local SQLite** — All data persisted locally
- 📱 **Cross-Platform** — iOS and Android via Skip

### 1.0.1

- Features
 - Prevent accidentally logging on next day between edge case hours of 12AM to 5AM
 - Allow exporting all trackables into one csv
 - Spanish support
- Bug fixes
 - fixed dark mode icon
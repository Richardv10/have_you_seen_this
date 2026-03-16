# seen_this 📱

A Flutter app that captures and organizes content shared to it from other apps. 

I made this because I overshare content with my friends, or at the wrong times<br>
so my solution was this daily "share bucket". I don't have a lot of mobile app dev experience<br>
so I've been teaching myself dart and the flutter framework, and skeletoned the thing with claude.<br>
Eventually this will be prod ready, but its currently quite bare bones, I've been working on other things, and recently come back to it<br>
The main issue I have is displaying thumbnails consistently given the various urls apps and browsers
can utilize. 

I'm currently looking for testers for the beta if anyone is interested drop me a dm  

## Overview

**seen_this** helps you collect, organize, and manage content shared to you from social media, messaging apps, and browsers. Share anything once and find it organized by date.

## Features

- 📸 Capture text, links, images, and videos shared from other apps
- 📅 Organize content by day
- 🔍 Browse archive of all shared content
- 🔄 Reshare content to chat apps (WhatsApp, Telegram, etc.)
- 🎨 Clean, intuitive Material 3 UI
- 💾 Local storage - your data stays on your device

## Screenshots

| Screen 1 | Screen 2 | Screen 3 |
|----------|----------|----------|
| ![Screenshot 1](assets/screenshots/screenshot_1.png) | ![Screenshot 2](assets/screenshots/screenshot_2.png) | ![Screenshot 3](assets/screenshots/screenshot_3.png) |
| *Today's Content* | *Archive View* | *Settings* |

| Screen 4 | Screen 5 |
|----------|----------|
| ![Screenshot 4](assets/screenshots/screenshot_4.png) | ![Screenshot 5](assets/screenshots/screenshot_5.png) |
| *Share Options* | *Link Preview* |

## Installation

### Requirements
- Flutter SDK 3.10.4+
- Android API level 21+
- iOS 12.0+

### Build

```bash
# Get dependencies
flutter pub get

# Build APK (Android)
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Usage

1. Share any content from another app
2. Select **seen_this** from the share menu
3. Content automatically appears in the "Today" tab
4. View previous shares in the "Archive" tab
5. Long-press any item to reshare or delete

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
├── providers/                   # State management (Provider)
├── screens/                     # UI screens
├── services/                    # Business logic & storage
└── widgets/                     # Reusable components
```

## Tech Stack

- **Framework:** Flutter
- **State Management:** Provider
- **Storage:** SQLite + SharedPreferences
- **Sharing:** share_plus plugin
- **Link Preview:** HTML parsing with http & html packages

## Recent Improvements

✅ Fixed N+1 database query problem (10x faster loading)  
✅ Added image cache limits to prevent memory leaks  
✅ Moved HTML parsing to background thread  
✅ Added error handling for share intents  

## License

MIT License

## Support

For issues, feature requests, or feedback, please open an issue on the repository.

---

**Version:** 1.0.0  
**Last Updated:** January 23, 2026

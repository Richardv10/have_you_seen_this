# seen_this

A Flutter app that captures and organizes content shared to it from other apps.

## Features

- 📱 **Share Intent Handling** - Receive text, links, images, and videos shared from other apps
- 🗂️ **Organize by Date** - Content automatically grouped by the day it was shared
- 🔄 **Reshare to Chat** - Send saved content to WhatsApp, Telegram, Email, and other messaging apps
- 🎨 **Image & Video Previews** - View thumbnails of images and video previews
- 💾 **Persistent Storage** - All content saved locally using SharedPreferences
- 🎯 **Material 3 Design** - Modern, responsive UI with three-tab navigation

## Getting Started

### Prerequisites
- Flutter 3.10+
- Android 10+ (for emulator or physical device)
- iOS support coming soon

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd seen_this
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run -d <device_id>
```

### Build APK

Debug build:
```bash
flutter build apk --debug
```

Release build:
```bash
flutter build apk --release
```

## Usage

### Sharing Content
1. Open any app (WhatsApp, Instagram, Chrome, etc.)
2. Share text, link, image, or video
3. Select **seen_this** from the share menu
4. Content automatically appears in the Today tab

### Managing Content
- **Today Tab** - View today's shares
- **Archive Tab** - View shares from previous days
- **Settings Tab** - Clear all data
- **Long-press** any content card to:
  - Reshare via chat (WhatsApp, Telegram, etc.)
  - Share using system share dialog
  - Delete the item

## Project Structure

```
lib/
├── main.dart                          # App entry point & navigation
├── models/                            # Data models
│   ├── shared_content.dart           # Content model
│   └── daily_collection.dart         # Collection model
├── providers/                         # State management
│   └── collections_notifier.dart     # ChangeNotifier for state
├── screens/                           # UI screens
│   ├── today_screen.dart             # Today's content
│   ├── archive_screen.dart           # Archived content
│   └── settings_screen.dart          # Settings & clear data
├── services/                          # Business logic
│   ├── storage_service.dart          # Local storage (SharedPreferences)
│   ├── share_intent_service.dart     # Share initialization
│   ├── mobile_share_intent_handler.dart  # Android integration
│   └── reshare_service.dart          # Reshare to chat
└── widgets/                           # Reusable widgets
    └── content_card.dart             # Content display card
```

## Architecture

- **State Management**: Provider pattern with ChangeNotifier
- **Storage**: SharedPreferences with JSON serialization
- **Platform Integration**: Method channels for Android share intents
- **UI Framework**: Flutter Material 3

## Dependencies

- `provider` - State management
- `shared_preferences` - Local storage
- `share_plus` - System share integration
- `intl` - Date formatting
- `uuid` - Unique identifiers
- `path_provider` - File paths

## Android Configuration

The app handles share intents from other apps via `AndroidManifest.xml`:
- Listens for `ACTION_SEND` (single share)
- Listens for `ACTION_SEND_MULTIPLE` (multiple files)
- Accepts: text, images, videos, and other files

## Known Limitations

- iOS support not yet implemented
- Media files stored in app cache (consider implementing periodic cleanup)
- No analytics integration
- Test coverage is minimal (placeholder tests present)

## Future Enhancements

- [ ] iOS support with native share handling
- [ ] Advanced search and filtering
- [ ] Tags and categories for content
- [ ] Export functionality
- [ ] Cloud sync
- [ ] Proper test suite with comprehensive coverage
- [ ] Logging framework for production
- [ ] Analytics integration

## Development Status

✅ **Alpha Ready** - Core features complete and tested on Android emulator
- All compilation errors fixed
- Code quality verified (zero warnings)
- Share intent handling working
- Media thumbnails displaying correctly

## License

TBD

## Support

For issues or feature requests, please open an issue on the project repository.

---

**Version**: 1.0.0  
**Last Updated**: January 7, 2026

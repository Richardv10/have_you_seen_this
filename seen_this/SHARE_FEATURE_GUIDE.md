# Share to "seen_this" Feature Guide

## Overview
Users can now share content from Facebook, TikTok, Instagram, and any other app directly to the "seen_this" app using the native Android/iOS share functionality.

## How It Works

### For Users (Android/iOS)
1. **Open any app** (Facebook, TikTok, Instagram, Chrome, etc.)
2. **Find content** you want to save
3. **Tap Share** button
4. **Look for "seen_this"** in the share menu
5. **Tap "seen_this"** → Content is automatically saved to today's collection!

### For Developers (How It's Implemented)

#### Architecture
```
User shares from Facebook/TikTok
        ↓
Android/iOS system share menu
        ↓
ShareIntentService.listenForSharedContent()
        ↓
MobileShareIntentHandler (receives via receive_sharing_intent package)
        ↓
CollectionsNotifier.addContentToday()
        ↓
StorageService (persists to local storage)
        ↓
UI automatically updates with new content
```

#### Key Files

**lib/services/share_intent_service.dart**
- Entry point for share intent functionality
- Initializes listeners for text and media shares
- Called from main.dart during app startup

**lib/services/mobile_share_intent_handler.dart**
- Receives actual share intents from Android/iOS
- Handles both text/links and media (images/videos)
- Processes and passes to CollectionsNotifier

**android/app/src/main/AndroidManifest.xml**
- Registers app in Android share menu
- Configured for: SEND (single item), SEND_MULTIPLE (multiple items)
- MIME types: text/*, image/*, video/*, */*

## Testing on Android Emulator

### Setup Android Emulator
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_name>
# or
emulator -avd <emulator_name>
```

### Build and Run APK
```bash
# Debug build
flutter run

# Release build
flutter build apk --release
flutter install  # Installs on connected device/emulator
```

### Test Share Intent
1. **Open emulator**
2. **Launch "seen_this" app**
3. **Open Chrome browser in emulator**
4. **Find any article/link**
5. **Tap Share → look for "seen_this"**
6. **Tap it → check Today screen in app**

### Simulate Share (Development)
If the share menu isn't available:
1. In Today screen, use "Add Test Content" button
2. Or use "Simulate Screenshot" to test media handling

## Android Manifest Configuration

The app is registered to handle:

```xml
<!-- Single item sharing -->
<intent-filter>
    <action android:name="android.intent.action.SEND"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="text/*"/>
    <data android:mimeType="image/*"/>
    <data android:mimeType="video/*"/>
    <data android:mimeType="*/*"/>
</intent-filter>

<!-- Multiple items sharing -->
<intent-filter>
    <action android:name="android.intent.action.SEND_MULTIPLE"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="image/*"/>
    <data android:mimeType="video/*"/>
    <data android:mimeType="*/*"/>
</intent-filter>
```

## iOS Configuration

iOS uses the same `receive_sharing_intent` package. No additional setup needed beyond Flutter dependency.

## Content Types Recognized

### Text Content
- Regular text → `ContentType.text`
- URLs/links → `ContentType.link`
- Source: "Facebook/TikTok/Share"

### Media Content
- Images (jpg, png, gif, webp) → `ContentType.screenshot`
- Videos (mp4, mov, mkv) → `ContentType.media`
- Other files → `ContentType.media`
- Source: "Facebook/TikTok/Share"

## What Gets Saved

For each share, the app saves:
- **Content Type**: text, link, image, video, etc.
- **Title**: Auto-generated (e.g., "Shared Link", "Shared Image")
- **Description**: The actual shared content (text) or file path (media)
- **Source**: "Facebook/TikTok/Share"
- **Timestamp**: When it was shared
- **Date**: Organized by date in Today/Archive screens

## Logging

When shares are received, check logcat for confirmation:

```bash
# View logs while app is running
flutter logs
```

Look for messages like:
```
✅ Text share listener ready - can receive from Facebook, TikTok, etc.
✅ Media share listener ready - can receive images/videos from Facebook, TikTok, etc.
📸 Received 1 shared media item(s)
✅ Added shared link: https://example.com
```

## Troubleshooting

### App doesn't appear in share menu
- Ensure AndroidManifest.xml has `android:exported="true"` on MainActivity
- Rebuild APK: `flutter clean && flutter build apk`
- Restart emulator/device

### Shares aren't being received
- Check logcat: `flutter logs`
- Verify listeners are initialized: look for "Share intent service initialized"
- Test with "Add Test Content" button first

### App crashes when receiving share
- Check Android Studio logcat for stack trace
- Verify StorageService.init() was called in main.dart
- Ensure CollectionsNotifier is provided in MultiProvider

## Future Enhancements

- [ ] Show notification when content is shared to app
- [ ] Add quick reply option in share menu
- [ ] Support link previews (fetch title/description)
- [ ] Add tag/category support for shared content
- [ ] Backup and sync to cloud
- [ ] Share collections with friends

## References

- **Package**: receive_sharing_intent ^1.4.5
- **Docs**: https://pub.dev/packages/receive_sharing_intent
- **Android Intent Filters**: https://developer.android.com/guide/components/intents-filters

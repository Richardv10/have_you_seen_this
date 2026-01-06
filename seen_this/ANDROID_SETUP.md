# Android Setup & Testing Guide

## Quick Start - Setting Up Android Development Environment

### Option 1: Install Android Studio (Recommended)
1. **Download**: https://developer.android.com/studio
2. **Install** Android Studio
3. **Launch** Android Studio
   - It will prompt to install Android SDK and emulator
   - Follow the setup wizard
4. **Verify**: `flutter doctor` should show Android toolchain as ✓

### Option 2: Use Existing Android Installation
If you already have Android SDK installed:
```bash
flutter config --android-sdk "C:\path\to\Android\sdk"
```

Then run: `flutter doctor` to verify

## Testing on Android Emulator

### Create/Launch Android Emulator
1. **Open Android Studio**
2. **Tools → Device Manager**
3. **Create Virtual Device** or select existing
   - Recommend: Pixel 5 with Android 12 or higher
4. **Launch** emulator

### Build and Run on Emulator
```bash
# Once emulator is running:
flutter run

# Or build APK and install:
flutter build apk --debug
adb install build/app/outputs/apk/debug/app-debug.apk
```

### Test Share Feature

#### Manual Share from Browser:
1. **Open emulator**
2. **Launch "seen_this" app** → Today screen
3. **Open Chrome browser** in emulator
4. **Go to any website**
5. **Select text or tap Share button**
6. **Look for "seen_this"** in share menu
7. **Tap it** → Content should appear in Today screen!

#### Or Use the Test Button:
1. **In Today screen**, tap the **floating action button (+)**
2. **Tap "Add Test Content"**
3. **Select "Link"** and enter a URL
4. **Tap Add** → See it appear immediately

## What to Expect

When share intent is working correctly:

**In App Logs** (flutter logs):
```
✅ Text share listener ready - can receive from Facebook, TikTok, etc.
✅ Media share listener ready - can receive images/videos from Facebook, TikTok, etc.
🚀 Share intent service initialized - app can now receive shares from social media
```

**In Today Screen:**
- New content appears with:
  - Title: "Shared Link" or "Shared Text"
  - Source: "Facebook/TikTok/Share"
  - Timestamp: When it was shared
  - Description: The actual shared content

## File Structure

```
android/app/src/main/
├── AndroidManifest.xml          ← Share intent configuration
└── MainActivity.kt              ← App entry point
```

## Key Implementation Files

The share receiving is implemented in:

1. **lib/services/share_intent_service.dart**
   - Initializes listeners in app startup
   - Called from main.dart → HomeScreen.initState()

2. **lib/services/mobile_share_intent_handler.dart**
   - Receives shares via receive_sharing_intent package
   - Processes text, links, images, videos
   - Adds to CollectionsNotifier

3. **android/app/src/main/AndroidManifest.xml**
   - Registers app in Android share menu
   - Handles SEND and SEND_MULTIPLE intents

## Troubleshooting

### "App doesn't appear in share menu"
```bash
# Rebuild with clean
flutter clean
flutter build apk --debug

# Reinstall
adb uninstall com.example.seen_this
adb install build/app/outputs/apk/debug/app-debug.apk
```

### "Shares aren't being received"
```bash
# View live logs
flutter logs

# Look for:
# ✅ Share intent listeners active
# ℹ️ If not present, check HomeScreen initState()
```

### "App crashes on share"
1. Check Android Logcat in Android Studio
2. Verify HomeScreen initState() calls ShareIntentService.listenForSharedContent()
3. Ensure StorageService.init() was called in main.dart

## Testing Checklist

- [ ] Android SDK is installed (`flutter doctor` shows ✓)
- [ ] Emulator is running
- [ ] `flutter run` launches app without errors
- [ ] Share listeners initialize (check logs)
- [ ] Can share from Chrome browser to app
- [ ] Content appears in Today screen
- [ ] Can share multiple items
- [ ] Shares persist when closing/reopening app
- [ ] Archive screen shows older shares by date

## Package Used

**receive_sharing_intent: ^1.4.5**

This package provides:
- `ReceiveSharingIntent.getTextStream()` - Listen for text shares
- `ReceiveSharingIntent.getMediaStream()` - Listen for media (images/videos)

## Next Steps

After Android is set up:
1. Test on Android Emulator
2. (Optional) Test on iOS Emulator with same setup
3. Test on physical device by:
   - Enabling Developer Mode
   - Connecting phone via USB
   - `flutter run` will detect and install on phone

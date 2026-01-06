# iOS Configuration for seen_this

## Overview

The iOS configuration for share intent handling requires updates to the `Info.plist` file. The app is ready to handle shared content from other iOS apps.

## Configuration Steps

### 1. Update Info.plist

Edit `ios/Runner/Info.plist` and add the following if not already present:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... existing keys ... -->
    
    <!-- Add this for document type handling -->
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Web Link</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.url</string>
                <string>public.plain-text</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Images</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.image</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Video</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.movie</string>
                <string>public.video</string>
            </array>
        </dict>
    </array>
    
    <!-- Add this for URL scheme handling (optional) -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.example.seenthis</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>seenthis</string>
            </array>
        </dict>
    </array>
    
    <!-- ... rest of your existing keys ... -->
</dict>
</plist>
```

### 2. Verify Share Menu Appearance

The app will automatically appear in the iOS share sheet. Users can:
1. Tap the share icon in any app (Notes, Safari, Photos, etc.)
2. Look for "seen_this" in the share options
3. May need to scroll to "More" if it's not immediately visible
4. First time sharing will prompt for confirmation

### 3. Capabilities (Optional for Advanced Features)

If you want to add advanced features later, add to `ios/Runner/Runner.xcodeproj/project.pbxproj`:

```
Capabilities:
- App Groups (for widget support)
- Push Notifications (for share receipts)
- Siri (for voice commands)
```

## Testing Share Intent on iOS

### Using Simulator

1. Open an app that supports sharing (Safari, Notes, etc.)
2. Tap the Share button
3. Scroll in the share sheet to find "seen_this"
4. Tap it
5. App launches and content is added

### Using Real Device

1. Build and install the app:
   ```bash
   flutter build ios
   # Then open in Xcode and run on device
   ```

2. Share content from any app
3. Select "seen_this" from the share menu
4. Verify content appears in Today screen

## Handling Different Share Types

The app handles:

| Type | Handler | Result |
|------|---------|--------|
| URLs | `listenForSharedText()` | Saved as link |
| Text | `listenForSharedText()` | Saved as text |
| Images | `listenForSharedMedia()` | Saved as screenshot |
| Videos | `listenForSharedMedia()` | Saved as media |
| Documents | `listenForSharedMedia()` | Saved as media |

## Troubleshooting iOS Share Intent

### App doesn't appear in share sheet
1. Rebuild and reinstall the app
2. Check that Info.plist changes were saved
3. Restart the device/simulator
4. Check that FlutterViewController is properly initialized

### Content not being saved
1. Check app permissions (File Access)
2. Ensure storage directory exists
3. Check device has sufficient storage
4. Enable app permissions in Settings > Privacy

### Share sheet is empty
1. Update receive_sharing_intent package
2. Verify flutter version compatibility
3. Clean build: `flutter clean && flutter pub get`

## Required iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<!-- File system access -->
<key>NSDocumentUsageDescription</key>
<string>To save shared content to your device</string>

<!-- Photo Library access (if handling media) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>To access shared photos</string>

<!-- Camera (if needed) -->
<key>NSCameraUsageDescription</key>
<string>To capture content for sharing</string>
```

## Advanced iOS Features (Future)

### App Clip Support
```xml
<key>NSAppClips</key>
<array>
    <dict>
        <key>NSAppClipsApplicationBundleIdentifier</key>
        <string>com.example.seenthis.clip</string>
        <key>NSDefaultClipExperienceArgument</key>
        <string>shared-content</string>
    </dict>
</array>
```

### Handoff Support (Continuity)
```xml
<key>NSUserActivityTypes</key>
<array>
    <string>com.example.seenthis.share</string>
</array>
```

## Building for App Store

1. Update version in `pubspec.yaml`
2. Increment build number
3. Update `ios/Runner/Info.plist`:
   - `CFBundleShortVersionString` (version)
   - `CFBundleVersion` (build number)
4. Build release:
   ```bash
   flutter build ios --release
   ```
5. Open in Xcode and submit to App Store

## Performance Optimization

For iOS devices handling large shares:

```dart
// In StorageService init()
// Consider limiting daily items
const maxItemsPerDay = 500;

// Implement pagination if needed
// Load items on demand rather than all at once
```

## Debugging iOS Share Intent

Enable verbose logging:

```bash
flutter run -v
# Look for "ReceiveSharingIntent" logs
```

Use Xcode console to monitor:
```bash
# In Xcode
# Open the debug console (Cmd + Shift + Y)
# Filter by your app name
```

---

**Note:** iOS configuration is mostly handled by the `receive_sharing_intent` package. These manual steps ensure optimal integration with iOS share sheet.

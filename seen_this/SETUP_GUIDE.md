# Setup Guide for seen_this

## iOS Configuration

To enable share intent handling on iOS, you need to add the UNUserNotificationCenter delegation and handle the share intent.

### Steps:

1. **Update Info.plist**
   - Open `ios/Runner/Info.plist`
   - The app is already configured to handle document types for sharing

2. **Optional: Custom App Icon**
   - Replace icon files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Android Configuration

Share intent handling is already configured in `android/app/src/main/AndroidManifest.xml` with:
- `android.intent.action.SEND` - Handle single item shares
- `android.intent.action.SEND_MULTIPLE` - Handle multiple item shares
- Support for text, images, videos, and generic files

## Running the App

### Development
```bash
flutter run
```

### Build Debug APK (Android)
```bash
flutter build apk --debug
```

### Build Release APK (Android)
```bash
flutter build apk --release
```

### Build iOS App
```bash
flutter build ios
```

## Testing Share Functionality

### Android
1. Open any app (Chrome, Instagram, Twitter, etc.)
2. Find a link or content you want to share
3. Select "Share" → Look for "seen_this" in the share options
4. Tap "seen_this" to share the content
5. The content will be added to today's shares

### iOS
1. Open any app with share functionality
2. Tap the share button
3. Look for "seen_this" (may need to scroll or enable in "More" options)
4. Tap "seen_this" to share
5. Content added to today's shares

## Troubleshooting

### Content not appearing
- Make sure the app is fully loaded
- Try switching to the "Today" tab
- The share should appear at the bottom of the list

### Share option not showing
- App may need to be built and installed fresh
- Android: Check AndroidManifest.xml is properly configured
- iOS: May need to enable in system share sheet settings

### Data not persisting
- Make sure device has storage space
- Check app permissions for file access
- Try restarting the app

## Performance Notes

- All data is stored locally on the device
- No cloud syncing is implemented yet
- Large collections may take a moment to load
- Archive view sorts by date automatically

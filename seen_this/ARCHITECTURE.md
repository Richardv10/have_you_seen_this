# seen_this - Content Repository App

A Flutter application that serves as a personal repository for sharable content from social media, links, screenshots, and more.

## Features

✅ **Share to App** - Receive content from other apps via the "Share to" functionality  
✅ **Organize by Date** - Automatic grouping of shared content by date  
✅ **Local Storage** - All data persisted locally on device  
✅ **Easy Management** - Delete, view, and organize your shares  
✅ **Share Manually** - Later share collections with friends  
✅ **Clean UI** - Intuitive bottom navigation with three main screens  

## App Structure

### Screens

1. **Today Screen** - View all content shared today
   - Empty state with helpful message
   - List of today's shares with timestamps
   - Delete individual items
   - Quick access to content actions

2. **Archive Screen** - Browse historical shares
   - Organized by date (newest first)
   - Expandable date sections
   - Bulk delete by date
   - Search through past content

3. **Settings Screen** - App configuration
   - App information
   - Clear all data option
   - Future customization options

### Core Components

#### Models (`lib/models/`)
- **SharedContent** - Individual content item with metadata
  - ID, type (screenshot/link/text/media/other)
  - Title, description, timestamp
  - Source app, content data, MIME type
  
- **DailyCollection** - Collection of shares for a specific date
  - Date, list of items
  - Helper methods for date formatting
  - Add/remove/clear operations

#### Services (`lib/services/`)
- **StorageService** - Local data persistence using SharedPreferences
  - Save/load/delete collections
  - Query by date
  - Get statistics
  
- **ShareIntentService** - Handle incoming shares from other apps
  - Listen for shared text/links
  - Listen for shared media files
  - Automatic content type detection

#### State Management (`lib/providers/`)
- **CollectionsNotifier** - ChangeNotifier for managing app state
  - Load/refresh collections
  - Add content to today
  - Remove/delete collections
  - Provide reactive updates to UI

#### Widgets (`lib/widgets/`)
- **ContentCard** - Display individual shared content
  - Icon indicating content type
  - Title, source, description
  - Timestamp
  - Long-press options (share, copy, delete)

## Data Model

Each shared item includes:
```dart
- id: String (UUID)
- contentType: ContentType enum
- title: String?
- description: String?
- timestamp: DateTime
- source: String? (e.g., "Instagram", "Share Intent")
- contentData: String? (URL, file path, or text content)
- mimeType: String?
```

## Technical Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Share Intent**: receive_sharing_intent
- **Date/Time**: intl
- **ID Generation**: uuid

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Platform Requirements

### Android
- Minimum SDK: API 21
- Share intent filters configured in AndroidManifest.xml
- Handles: SEND, SEND_MULTIPLE intents

### iOS
- iOS 11.0+
- Share intent configuration needed in Info.plist

## Future Enhancements

- 📸 Display thumbnails for images
- 🔗 Preview links before sharing
- 🏷️ Add tags/categories to content
- 📊 Analytics and statistics
- ☁️ Cloud backup option
- 🔍 Full-text search
- 👥 Social sharing features
- 📱 Widget for quick access
- 🎨 Theme customization
- 📤 Export collections

## License

Private Project

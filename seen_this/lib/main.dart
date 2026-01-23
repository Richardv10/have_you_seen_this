import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/share_intent_service.dart';
import 'services/tag_suggestion_service.dart';
import 'services/share_group_service.dart';
import 'services/share_history_service.dart';
import 'providers/collections_notifier.dart';
import 'providers/theme_notifier.dart';
import 'providers/share_group_notifier.dart';
import 'screens/today_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/share_groups_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure image cache to prevent memory leaks
  imageCache.maximumSize = 50;        // Max 50 images in cache
  imageCache.maximumSizeBytes = 100 * 1024 * 1024;  // Max 100 MB
  
  // Initialize database service
  final databaseService = DatabaseService();
  await databaseService.init();
  
  // Initialize tag suggestion service
  final tagSuggestionService = TagSuggestionService(databaseService);
  await tagSuggestionService.init();
  
  // Initialize share group service
  final shareGroupService = ShareGroupService();
  await shareGroupService.init();
  
  // Initialize share history service
  final shareHistoryService = ShareHistoryService();
  await shareHistoryService.init();
  
  runApp(MyApp(
    databaseService: databaseService,
    tagSuggestionService: tagSuggestionService,
    shareGroupService: shareGroupService,
    shareHistoryService: shareHistoryService,
  ));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;
  final TagSuggestionService tagSuggestionService;
  final ShareGroupService shareGroupService;
  final ShareHistoryService shareHistoryService;

  const MyApp({
    super.key,
    required this.databaseService,
    required this.tagSuggestionService,
    required this.shareGroupService,
    required this.shareHistoryService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CollectionsNotifier(databaseService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShareGroupNotifier(shareGroupService)..init(),
        ),
        Provider(
          create: (_) => tagSuggestionService,
        ),
        Provider(
          create: (_) => shareHistoryService,
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp(
            title: 'seen_this',
            theme: themeNotifier.getThemeData(),
            home: HomeScreen(databaseService: databaseService),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const HomeScreen({
    super.key,
    required this.databaseService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showWelcome = false;
  bool _initialized = false;
  bool _showSplash = true;

  static const List<Widget> _screens = <Widget>[
    TodayScreen(),
    ArchiveScreen(),
    ShareGroupsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Show splash screen for 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _showSplash = false;
      });
    });
    _checkWelcomeStatus();
    // Listen for shared content from other apps
    final collectionsNotifier =
        context.read<CollectionsNotifier>();
    ShareIntentService.listenForSharedContent(
      context,
      collectionsNotifier,
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding shared content: $error'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  Future<void> _checkWelcomeStatus() async {
    final hasSeenWelcome = await widget.databaseService.hasSeenWelcome();
    setState(() {
      _showWelcome = !hasSeenWelcome;
      _initialized = true;
    });
  }

  void _dismissWelcome() async {
    await widget.databaseService.setWelcomeShown();
    setState(() {
      _showWelcome = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showWelcome) {
      return WelcomeScreen(onDismiss: _dismissWelcome);
    }

    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Archive',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


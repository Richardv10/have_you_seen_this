import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/share_intent_service.dart';
import 'providers/collections_notifier.dart';
import 'providers/theme_notifier.dart';
import 'screens/today_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database service
  final databaseService = DatabaseService();
  await databaseService.init();
  
  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MyApp({
    super.key,
    required this.databaseService,
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
    ShareIntentService.listenForSharedContent(context, collectionsNotifier);
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


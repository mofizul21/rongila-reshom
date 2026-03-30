import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'providers/providers.dart';
import 'services/auth_service.dart';
import 'widgets/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Don't call ensureDefaultAdmin here - it interferes with auth persistence
  // final authService = AuthService();
  // await authService.ensureDefaultAdmin();

  final authService = AuthService();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(MyApp(settingsProvider: settingsProvider, authService: authService));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final AuthService authService;

  const MyApp({super.key, required this.settingsProvider, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: authService)),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: settingsProvider.storeName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            home: AuthenticationWrapper(authService: authService),
          );
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  final AuthService authService;

  const AuthenticationWrapper({super.key, required this.authService});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isCheckingAuth = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndListen();
  }

  Future<void> _checkAuthAndListen() async {
    // Check current user from Firebase Auth cache
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    debugPrint('[AuthWrapper] Firebase.currentUser: ${user?.uid ?? "null"}');
    
    setState(() {
      _isLoggedIn = user != null;
      _isCheckingAuth = false;
    });

    // Also listen to auth state changes for future login/logout
    widget.authService.authStateChanges.listen((firebaseUser) {
      debugPrint('[AuthWrapper] authStateChanges: ${firebaseUser?.uid ?? "null"}');
      if (mounted) {
        setState(() {
          _isLoggedIn = firebaseUser != null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    debugPrint('[AuthWrapper] build: _isLoggedIn=$_isLoggedIn');
    
    if (_isLoggedIn) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}

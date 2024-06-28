import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/book_form_screen.dart';
import 'screens/collection_screen.dart';
import 'blocs/auth_bloc.dart';
import 'services/theme_provider.dart';
import 'services/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: "assets/.env");
  runApp(MyApp(googleBooksApiKey: dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? ''));
}

class MyApp extends StatefulWidget {
  final String googleBooksApiKey;
  const MyApp({super.key, required this.googleBooksApiKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      isDarkMode: _isDarkMode,
      toggleTheme: _toggleTheme,
      child: BlocProvider(
        create: (context) => AuthBloc(),
        child: MaterialApp(
          title: 'Flutter Home Library',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: _buildRoutes(context),
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes(BuildContext context) {
    return {
      '/': (context) => const AuthScreen(),
      '/login': (context) => const AuthScreen(),
      '/home': (context) => HomeScreen(),
      '/addBook': (context) => BookFormScreen(
            collectionId: _getCollectionId(context),
            googleBooksApiKey: widget.googleBooksApiKey,
            mode: FormMode.add,
          ),
      '/collection': (context) => CollectionScreen(
            collectionId: _getCollectionId(context),
            googleBooksApiKey: widget.googleBooksApiKey,
          ),
    };
  }

  String _getCollectionId(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }
}
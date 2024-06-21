import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/firebase_options.dart';
import '../screens/authScreen.dart';
import '../screens/homeScreen.dart';
import '../screens/addBookScreen.dart';
import '../screens/collectionScreen.dart';  
import '../blocs/authBloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/appTheme.dart'; 

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
  const MyApp({Key? key, required this.googleBooksApiKey}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
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
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        title: 'Flutter Home Library',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        routes: _buildRoutes(context),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes(BuildContext context) {
    return {
      '/': (context) => AuthScreen(isDarkMode: _isDarkMode, onThemeToggle: _toggleTheme),
      '/home': (context) => HomeScreen(isDarkMode: _isDarkMode, onThemeToggle: _toggleTheme),
      '/addBook': (context) => AddBookScreen(
            collectionId: _getCollectionId(context),
            googleBooksApiKey: widget.googleBooksApiKey,
            isDarkMode: _isDarkMode,
            onThemeToggle: _toggleTheme,
          ),
      '/collection': (context) => CollectionScreen(
            collectionId: _getCollectionId(context),
            googleBooksApiKey: widget.googleBooksApiKey,
            isDarkMode: _isDarkMode,
            onThemeToggle: _toggleTheme,
          ),
    };
  }

  String _getCollectionId(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }
}
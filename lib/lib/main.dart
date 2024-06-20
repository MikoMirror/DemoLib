import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/firebase_options.dart';
import '../screens/authScreen.dart'; 
import '../screens/homeScreen.dart'; 
import '../screens/addBookScreen.dart'; 
import '../screens/addCollectionScreen.dart'; 
import '../screens/collectionScreen.dart';  
import '../blocs/authBloc.dart'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/services.dart' show rootBundle;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: "assets/.env");

  runApp(MyApp(googleBooksApiKey: dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? ''));
}

class MyApp extends StatelessWidget {
  final String googleBooksApiKey;

  const MyApp({Key? key, required this.googleBooksApiKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        title: 'Flutter Home Library',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: _buildRoutes(context),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes(BuildContext context) {
    return {
      '/': (context) => AuthScreen(),
      '/home': (context) => HomeScreen(),
      '/addCollection': (context) => AddCollectionScreen(),
      '/addBook': (context) => AddBookScreen(
            collectionId: _getCollectionId(context),
            googleBooksApiKey: googleBooksApiKey,
          ),
      '/collection': (context) => CollectionScreen(
            collectionId: _getCollectionId(context),
            googleBooksApiKey: googleBooksApiKey,
          ),
    };
  }

  String _getCollectionId(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/authScreen.dart'; 
import 'screens/homeScreen.dart'; 
import 'screens/addBookScreen.dart'; 
import 'screens/addCollectionScreen.dart'; 
import 'screens/collectionScreen.dart';  
import 'blocs/authBloc.dart'; 
import 'services/firestoreService.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
  await dotenv.load(fileName: ".env");
} catch (e) {
  print('Error loading .env file: $e');
}
  String googleBooksApiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? ''; 

  runApp(MyApp(googleBooksApiKey: googleBooksApiKey));
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
        routes: {
          '/': (context) => AuthScreen(),
          '/home': (context) => HomeScreen(),
          '/addCollection': (context) => AddCollectionScreen(),
          '/addBook': (context) => AddBookScreen(
                collectionId: ModalRoute.of(context)!.settings.arguments as String? ?? '',
                googleBooksApiKey: googleBooksApiKey, 
              ),
          '/collection': (context) => CollectionScreen(
                collectionId: ModalRoute.of(context)!.settings.arguments as String? ?? '',
                googleBooksApiKey: googleBooksApiKey, // Pass API key here
              ),
        },
      ),
    );
  }
}
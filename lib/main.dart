import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/authScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/addBookScreen.dart'; 
import 'screens/addCollectionScreen.dart'; 
import 'screens/collectionScreen.dart';
import 'blocs/authBloc.dart'; 
import 'services/firestoreService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
          ),
          '/collection': (context) => CollectionScreen(
            collectionId: ModalRoute.of(context)!.settings.arguments as String? ?? '', 
          ),
        },
      ),
    );
  }
}
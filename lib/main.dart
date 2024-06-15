import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/AuthScreen.dart'; 
import 'screens/homeScreen.dart';
import 'blocs/authBloc.dart';

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
      create: (context) => AuthBloc(), // Provide the AuthBloc
      child: MaterialApp(
        title: 'Flutter Home Library',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Define routes for navigation
        routes: {
          '/': (context) => AuthScreen(), // Initial route
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}
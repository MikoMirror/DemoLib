import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'authEvent.dart'; 
import 'authState.dart'; 

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    // Listen for authentication state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        add(AuthUserLoggedIn(user: user)); 
      } else {
        add(AuthUserLoggedOut()); 
      }
    });

    // Handle login requests
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthAuthenticated(user: userCredential.user!)); 
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    // Handle registration requests
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _firebaseAuth
            .createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthAuthenticated(user: userCredential.user!));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: _getErrorMessage(e.code)));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    // Handle logout requests
    on<AuthLogoutRequested>((event, emit) async {
      await _firebaseAuth.signOut();
      // No need to emit a new state here, as authStateChanges will trigger AuthUserLoggedOut
    });

    // Handle user logged in
    on<AuthUserLoggedIn>((event, emit) {
      emit(AuthAuthenticated(user: event.user));
    });

    // Handle user logged out
    on<AuthUserLoggedOut>((event, emit) {
      emit(AuthInitial());
    });
  }

  // Helper function for FirebaseAuth error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred. Please try again later.';
    }
  }
}
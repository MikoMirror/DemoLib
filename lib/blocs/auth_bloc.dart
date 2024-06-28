import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart'; 
import 'auth_state.dart'; 

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        add(AuthUserLoggedIn(user: user));
      } else {
        add(AuthUserLoggedOut());
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthAuthenticated(user: userCredential.user!));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: _getSignInErrorMessage(e.code)));
      } catch (e) {
        emit(AuthError(message: 'An unexpected error occurred. Please try again.'));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
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
    on<AuthLogoutRequested>((event, emit) async {
      await _firebaseAuth.signOut();
    });

    on<AuthUserLoggedIn>((event, emit) {
      emit(AuthAuthenticated(user: event.user));
    });

    on<AuthUserLoggedOut>((event, emit) {
      emit(AuthInitial());
    });
  }

  String _getSignInErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many unsuccessful login attempts. Please try again later.';
      default:
        return 'An error occurred during sign in. Please try again.';
    }
  }

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
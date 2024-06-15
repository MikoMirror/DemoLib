import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'authEvent.dart';
import 'authState.dart';

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
      } catch (e) {
        emit(AuthError(message: e.toString()));
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
        String errorMessage = 'An error occurred. Please try again later.';

        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } 
        emit(AuthError(message: errorMessage));
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
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/authBloc.dart';
import '../blocs/authEvent.dart';
import '../blocs/authState.dart';
import 'registrationScreen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocListener<AuthBloc, AuthState>( 
        listener: (context, state) {
          if (state is AuthAuthenticated) {
      
            Navigator.pushReplacementNamed(context, '/home'); 
          } else if (state is AuthError) {
      
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  if (state is AuthLoading) 
                    const CircularProgressIndicator()
                  else 
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                _emailController.text,
                                _passwordController.text,
                              ),
                            );
                          },
                          child: const Text('Login'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => RegistrationScreen()),
                            );
                          },
                          child: const Text('Don\'t have an account? Register'),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
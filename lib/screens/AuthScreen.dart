import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/authBloc.dart';
import '../blocs/authEvent.dart';
import '../blocs/authState.dart';
import 'registrationScreen.dart';
import '../widgets/StylizedTextField.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/stylizedButton.dart';

class AuthScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AuthScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}


class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Login',
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
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
        child: _buildLoginForm(context),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor, 
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: Column(
            children: [
              StylizedTextField(
                controller: _emailController,
                labelText: 'Email',
              ),
              const SizedBox(height: 20),
              StylizedTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _buildLoginButton(context, state),
              _buildRegistrationLink(),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildLoginButton(BuildContext context, AuthState state) {
  return state is AuthLoading
      ? const CircularProgressIndicator(color: Colors.white)
      : StylizedButton(
          onPressed: () {
            context.read<AuthBloc>().add(
                  AuthLoginRequested(
                    _emailController.text,
                    _passwordController.text,
                  ),
                );
          },
          text: 'Login',
        );
}

Widget _buildRegistrationLink() {
  return TextButton(
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RegistrationScreen(
            isDarkMode: widget.isDarkMode,
            onThemeToggle: widget.onThemeToggle,
          ),
        ),
      );
    },
    child: Text(
      'Don\'t have an account? Register',
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
    ),
  );
}
}
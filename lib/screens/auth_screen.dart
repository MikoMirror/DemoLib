import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import 'registration_screen.dart';
import '../widgets/stylized_text_field.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/stylized_button.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
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
        child: _LoginForm(),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
Widget build(BuildContext context) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      return SingleChildScrollView(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img/open-book.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Home Lib",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
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
                const SizedBox(height: 30),
                _buildLoginButton(context, state),
                const SizedBox(height: 15),
                _buildRegistrationLink(context),
              ],
            ),
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

  Widget _buildRegistrationLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const RegistrationScreen(),
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
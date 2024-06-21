import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/authBloc.dart';
import '../blocs/authEvent.dart';
import '../blocs/authState.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/StylizedTextField.dart';
import '../widgets/StylizedButton.dart';

class RegistrationScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const RegistrationScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Register',
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 24),
                    _buildRegisterButton(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return StylizedTextField(
      controller: _emailController,
      labelText: 'Email',
      validator: (value) => value == null || value.isEmpty
          ? 'Please enter an email'
          : null,
    );
  }

  Widget _buildPasswordField() {
    return StylizedTextField(
      controller: _passwordController,
      labelText: 'Password',
      obscureText: true,
      validator: (value) => value == null || value.isEmpty
          ? 'Please enter a password'
          : null,
    );
  }

  Widget _buildConfirmPasswordField() {
    return StylizedTextField(
      controller: _confirmPasswordController,
      labelText: 'Confirm Password',
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        } else if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(AuthState state) {
    return state is AuthLoading
        ? const CircularProgressIndicator()
        : StylizedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<AuthBloc>().add(
                      AuthRegisterRequested(
                        _emailController.text,
                        _passwordController.text,
                      ),
                    );
              }
            },
            text: 'Register',
          );
  }
}
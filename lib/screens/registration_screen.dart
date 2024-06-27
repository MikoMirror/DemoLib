import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/stylized_text_field.dart';
import '../widgets/stylized_button.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Register'),
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
          return _RegistrationForm(state: state);
        },
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  final AuthState state;

  const _RegistrationForm({required this.state});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
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
              _buildRegisterButton(),
            ],
          ),
        ),
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

  Widget _buildRegisterButton() {
    return widget.state is AuthLoading
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
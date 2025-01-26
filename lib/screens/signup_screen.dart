import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/auth/auth_exceptions.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<AuthProvider>(context, listen: false).signup(
          username: _usernameController.text,
          password: _passwordController.text,
          email: _emailController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Please log in.'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context); // Go back to login
      } catch (e) {
        String errorMessage = 'An unexpected error occurred';
        
        if (e is AuthException) {
          switch (e.code) {
            case 'email_exists':
              errorMessage = 'This email is already registered. Please use a different email.';
              break;
            case 'username_exists':
              errorMessage = 'This username is already taken. Please choose another one.';
              break;
            case 'invalid_email':
              errorMessage = 'Please enter a valid email address.';
              break;
            case 'weak_password':
              errorMessage = 'Password is too weak. Please use a stronger password.';
              break;
            case 'network_error':
              errorMessage = 'Network error. Please check your internet connection.';
              break;
            case 'invalid_credentials':
              errorMessage = 'Invalid username or password. Please check your credentials.';
              break;
            case 'unauthorized':
              errorMessage = 'Invalid username or password. Please try again.';
              break;
            default:
              errorMessage = 'Something went wrong. Please try again later.';
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 4),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _usernameController,
                labelText: 'Username',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter username' : null,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter email' : null,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter password' : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text('Signup'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

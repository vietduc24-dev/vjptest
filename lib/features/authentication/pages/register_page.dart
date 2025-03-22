import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_router.dart';
import '../../../common/widgets/toast.dart';
import '../cubit/register/register_cubit.dart';
import '../cubit/register/register_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _packageTypeController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _companyNameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _packageTypeController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegisterCubit>().register(
            username: _usernameController.text,
            password: _passwordController.text,
            fullName: _fullNameController.text,
            companyName: _companyNameController.text.isNotEmpty
                ? _companyNameController.text
                : null,
            phone: _phoneController.text.isNotEmpty
                ? _phoneController.text
                : null,
            nationality: _nationalityController.text.isNotEmpty
                ? _nationalityController.text
                : null,
            packageType: _packageTypeController.text.isNotEmpty
                ? _packageTypeController.text
                : null,
          );
    }
  }

  void _navigateToLogin() {
    AppRouter.goToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.error) {
            Toast.show(
              context,
              state.errorMessage ?? 'An error occurred',
              type: ToastType.error,
            );
          } else if (state.status == RegisterStatus.success) {
            Toast.show(
              context,
              'Registration successful',
              type: ToastType.success,
            );
            AppRouter.goToLogin(context);
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      onChanged: (value) =>
                          context.read<RegisterCubit>().updateUsername(value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                      onChanged: (value) =>
                          context.read<RegisterCubit>().updateFullName(value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      onChanged: (value) =>
                          context.read<RegisterCubit>().updateCompanyName(value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) =>
                          context.read<RegisterCubit>().updatePhone(value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nationalityController,
                      decoration: const InputDecoration(
                        labelText: 'Nationality',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      onChanged: (value) =>
                          context.read<RegisterCubit>().updateNationality(value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _packageTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Package Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.card_membership),
                      ),
                      onChanged: (value) =>
                          context.read<RegisterCubit>().updatePackageType(value),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.status == RegisterStatus.loading
                          ? null
                          : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state.status == RegisterStatus.loading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Register',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 
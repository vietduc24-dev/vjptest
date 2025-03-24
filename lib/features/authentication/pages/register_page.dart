import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_router.dart';
import '../../../common/widgets/toast.dart';
import '../cubit/register/register_cubit.dart';
import '../cubit/register/register_state.dart';
import '../../../common/colors.dart';
import '../../../common/texts/format_language_login_register.dart';
import '../cubit/language/language_cubit.dart';
import '../widgets/auth_widgets.dart';

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
    return BlocProvider(
      create: (context) => LanguageCubit(),
      child: Scaffold(
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
            return BlocBuilder<LanguageCubit, String>(
              builder: (context, language) {
                return SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [UIColors.white, UIColors.whiteSmoke],
                      ),
                    ),
                    child: Column(
                      children: [
                        LanguageSelector(
                          currentLanguage: language,
                          onLanguageChanged: (lang) => context
                              .read<LanguageCubit>()
                              .changeLanguage(lang),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 40),
                                  Text(
                                    FormatLanguage.getLabel(
                                        language, 'registerTitle'),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: UIColors.boldText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    FormatLanguage.getLabel(
                                        language, 'registerSubtitle'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: UIColors.grayText,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  AuthTextField(
                                    controller: _usernameController,
                                    label: FormatLanguage.getLabel(
                                        language, 'email'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return FormatLanguage.getLabel(
                                            language, 'emailRequired');
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _passwordController,
                                    label: FormatLanguage.getLabel(
                                        language, 'password'),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return FormatLanguage.getLabel(
                                            language, 'passwordRequired');
                                      }
                                      if (value.length < 6) {
                                        return FormatLanguage.getLabel(
                                            language, 'passwordTooShort');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _fullNameController,
                                    label: FormatLanguage.getLabel(
                                        language, 'fullName'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return FormatLanguage.getLabel(
                                            language, 'fillAllFields');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _companyNameController,
                                    label: FormatLanguage.getLabel(
                                        language, 'company'),
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _phoneController,
                                    label: FormatLanguage.getLabel(
                                        language, 'phone'),
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _nationalityController,
                                    label: FormatLanguage.getLabel(
                                        language, 'entity'),
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _packageTypeController,
                                    label: FormatLanguage.getLabel(
                                        language, 'package'),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state.status ==
                                              RegisterStatus.loading
                                          ? null
                                          : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: UIColors.redLight,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: state.status ==
                                              RegisterStatus.loading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              FormatLanguage.getLabel(
                                                  language,
                                                  'registerButton'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AuthBottomContainer(
                          welcomeText: FormatLanguage.getLabel(language, 'welcome'),
                          switchText: FormatLanguage.getLabel(
                              language, 'switchToLogin'),
                          buttonText: FormatLanguage.getLabel(
                              language, 'loginButton'),
                          onButtonPressed: _navigateToLogin,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_router.dart';
import '../../../common/widgets/toast.dart';
import '../cubit/login/login_cubit.dart';
import '../cubit/login/login_state.dart';
import '../../../common/bloc_status.dart';
import '../../../common/colors.dart';
import '../../../common/texts/format_language_login_register.dart';
import '../cubit/language/language_cubit.dart';
import '../widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().login(
            username: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  void _navigateToRegister() {
    AppRouter.goToRegister(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageCubit(),
      child: Scaffold(
        body: BlocConsumer<LoginCubit, LoginState>(
          listenWhen: (previous, current) => 
            previous.status != current.status && 
            (current.status == BlocStatus.success || current.status == BlocStatus.failure),
          listener: (context, state) {
            if (state.status == BlocStatus.loading) {
              _loadingController.repeat();
            } else {
              _loadingController.stop();
            }

            if (state.status == BlocStatus.failure) {
              Toast.show(
                context,
                state.errorMessage ?? 'An error occurred',
                type: ToastType.error,
              );
            } else if (state.status == BlocStatus.success) {
              Toast.show(
                context,
                'Login successful',
                type: ToastType.success,
              );
              AppRouter.goToHome(context);
            }
          },
          buildWhen: (previous, current) => 
            previous.status != current.status,
          builder: (context, state) {
            return BlocBuilder<LanguageCubit, String>(
              builder: (context, language) {
                return CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [UIColors.white, UIColors.whiteSmoke],
                          ),
                        ),
                        child: Column(
                          children: [
                            RepaintBoundary(
                              child: LanguageSelector(
                                currentLanguage: language,
                                onLanguageChanged: (lang) => context
                                    .read<LanguageCubit>()
                                    .changeLanguage(lang),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 40),
                                      Text(
                                        FormatLanguage.getLabel(
                                            language, 'loginTitle'),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: UIColors.boldText,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        FormatLanguage.getLabel(
                                            language, 'loginSubtitle'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: UIColors.grayText,
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      AuthTextField(
                                        controller: _emailController,
                                        label: FormatLanguage.getLabel(
                                            language, 'email'),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return FormatLanguage.getLabel(
                                                language, 'emailRequired');
                                          }
                                          return null;
                                        },
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
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: state.status ==
                                                  BlocStatus.loading
                                              ? null
                                              : _handleLogin,
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
                                                  BlocStatus.loading
                                              ? RotationTransition(
                                                  turns: _loadingController,
                                                  child: const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(Colors.white),
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  FormatLanguage.getLabel(
                                                      language, 'loginButton'),
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
                                  language, 'switchToRegister'),
                              buttonText: FormatLanguage.getLabel(
                                  language, 'registerButton'),
                              onButtonPressed: _navigateToRegister,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

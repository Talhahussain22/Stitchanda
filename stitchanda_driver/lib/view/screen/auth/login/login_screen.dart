import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:stichanda_driver/helper/validation_helper.dart';
import 'package:stichanda_driver/view/base/custom_button.dart';
import 'package:stichanda_driver/view/base/custom_text_field.dart';
import 'package:stichanda_driver/view/screen/auth/signup/signup_screen.dart';
import 'package:stichanda_driver/view/screen/dashboard/dashboard_screen.dart';
import 'package:stichanda_driver/view/screen/auth/pending_status_screen.dart';

import '../../../../controller/authCubit.dart';
import '../forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialSnack;

  const LoginScreen({super.key, this.initialSnack});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
    super.initState();
    if (widget.initialSnack != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.initialSnack!)),
        );
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<AuthCubit>().clearError();
        }
        // Navigate after successful login based on verification status
        if (state.isAuthenticated && state.profile != null) {
          final status = state.profile!.verificationStatus;
          if (status == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
              (route) => false,
            );
          } else if (status == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PendingStatusScreen()),
              (route) => false,
            );
          } else if (status == 2) {
            context.read<AuthCubit>().logout();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Your account has been rejected.')),
            );
          }
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state.isLoading,
            color: Theme.of(context).primaryColor,
            child: Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 28),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 56),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top content fills available space
                                FadeTransition(
                                  opacity: _fade,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 24),
                                      Center(
                                        child: Hero(
                                          tag: 'app_logo',
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                            child: Image.asset('assets/images/splash_logo.png', width: 56),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Welcome back',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Please enter your details to sign in',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 24),
                                      CustomTextField(
                                        label: 'Email',
                                        hintText: 'Enter your email',
                                        controller: emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: ValidationHelper.validateEmail,
                                        prefixIcon: const Icon(Icons.email_outlined),
                                      ),
                                      CustomTextField(
                                        label: 'Password',
                                        hintText: 'Enter your password',
                                        obscureText: true,
                                        controller: passwordController,
                                        keyboardType: TextInputType.visiblePassword,
                                        validator: ValidationHelper.validatePassword,
                                        prefixIcon: const Icon(Icons.lock_outline),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                                          },
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      CustomButton(
                                        buttonText: 'Login',
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).colorScheme.primary,
                                            Theme.of(context).colorScheme.primaryContainer,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            context.read<AuthCubit>().login(
                                                  email: emailController.text.trim(),
                                                  password: passwordController.text.trim(),
                                                );
                                          }
                                        },
                                        height: 52,
                                        radius: 18,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),
                                // Bottom sign-up row anchored to bottom via spaceBetween
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ), // end Scaffold
          ); // end ModalProgressHUD
        },
      ), // end BlocBuilder
    ); // end BlocListener
  }
}

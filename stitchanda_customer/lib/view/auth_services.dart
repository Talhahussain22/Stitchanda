import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controller/auth_cubit.dart';
import 'screen/login_page.dart';
import 'screen/email_verification_page.dart';
import 'base/bottom_nav_scaffold.dart';

/// AuthServices acts as a simple session gate.
/// - If authenticated, shows the app shell (BottomNavScaffold).
/// - If not authenticated, shows the LoginPage.
/// - While loading/initializing, shows a splash/progress indicator.
class AuthServices extends StatelessWidget {
  const AuthServices({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          // Simple splash while we check auth
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          // Go straight to home shell
          return const BottomNavScaffold(initialIndex: 2);
        }

        if (state is AuthEmailNotVerified) {
          // User exists but email not verified - show verification page
          return EmailVerificationPage(email: state.email);
        }

        // Unauthenticated or error -> Login page
        return const LoginPage();
      },
    );
  }
}


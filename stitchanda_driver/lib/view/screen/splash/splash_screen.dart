import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/controller/authCubit.dart';
import 'package:stichanda_driver/view/screen/auth/login/login_screen.dart';
import 'package:stichanda_driver/view/screen/auth/pending_status_screen.dart';
import 'package:stichanda_driver/view/screen/dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _navigated = false;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  void _navigateOnce(Widget page, {Duration? delay}) {
    if (_navigated || !mounted) return;
    _navigated = true;
    final d = const Duration(milliseconds: 2500);
    Future.delayed(d, () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => page),
        (route) => false,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AuthCubit>().state;
      if (state.isLoading) return;
      if (state.isAuthenticated && state.profile != null) {
        final status = state.profile!.verificationStatus;
        if (status == 0) {
          _navigateOnce(const PendingStatusScreen(), delay: const Duration(milliseconds: 500));
        } else if (status == 1) {
          _navigateOnce(DashboardScreen());
        } else if (status == 2) {
          context.read<AuthCubit>().logout();
          _navigateOnce(const LoginScreen(initialSnack: 'Your account has been rejected.'), delay: const Duration(milliseconds: 500));
        } else {
          _navigateOnce(const LoginScreen(), delay: const Duration(milliseconds: 500));
        }
      } else {
        _navigateOnce(const LoginScreen(), delay: const Duration(milliseconds: 500));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, next) => prev.isLoading != next.isLoading || prev.isAuthenticated != next.isAuthenticated || prev.profile != next.profile,
      listener: (context, state) {
        if (state.isLoading) return;
        if (state.isAuthenticated && state.profile != null) {
          final status = state.profile!.verificationStatus;
          if (status == 0) {
            _navigateOnce(const PendingStatusScreen(), delay: const Duration(milliseconds: 500));
          } else if (status == 1) {
            _navigateOnce(DashboardScreen());
          } else if (status == 2) {
            context.read<AuthCubit>().logout();
            _navigateOnce(const LoginScreen(initialSnack: 'Your account has been rejected.'), delay: const Duration(milliseconds: 500));
          } else {
            _navigateOnce(const LoginScreen(), delay: const Duration(milliseconds: 500));
          }
        } else {
          _navigateOnce(const LoginScreen(), delay: const Duration(milliseconds: 400));
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.75),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/splash_logo.png',
                        width: MediaQuery.of(context).size.width * 0.55,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      Text(
                        'Stichanda Driver',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Deliver excellence. Drive your growth.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                FadeTransition(
                  opacity: _fade,
                  child: SizedBox(
                    width: 54,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

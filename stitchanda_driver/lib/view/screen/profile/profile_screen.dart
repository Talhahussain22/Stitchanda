import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stichanda_driver/view/screen/auth/login/login_screen.dart';
import 'package:stichanda_driver/view/screen/profile/update_profile_screen.dart';

import '../../../controller/authCubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<String> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return '—';
    }
  }

  String _verificationText(int status) {
    switch (status) {
      case 1: return 'Verified';
      case 2: return 'Rejected';
      default: return 'Pending';
    }
  }

  Color _verificationColor(BuildContext context, int status) {
    switch (status) {
      case 1: return Colors.green;
      case 2: return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final profile = state.profile;
            if (state.isLoading && profile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (profile == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No profile found. Please login again.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                        );
                      },
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Avatar
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 3,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: (profile.profileImagePath.isNotEmpty
                            ? Image.network(profile.profileImagePath, height: 100, width: 100, fit: BoxFit.cover)
                            : null) ??
                            Container(
                              height: 100,
                              width: 100,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                              child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.primary),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name + Verification badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.name.isEmpty ? '—' : profile.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_verificationText(profile.verificationStatus)),
                        backgroundColor:
                        _verificationColor(context, profile.verificationStatus).withValues(alpha: 0.12),
                        labelStyle: TextStyle(
                          color: _verificationColor(context, profile.verificationStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Basic info card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      children: [
                        _infoTile(context, icon: Icons.phone, title: 'Phone', value: profile.phone, onTap: () async {
                          final uri = Uri.parse('tel:${profile.phone}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      children: [
                        _buildProfileButton(
                          context,
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const UpdateProfileScreen())),
                        ),
                        _divider(context),
                        _buildProfileButton(
                          context,
                          icon: Icons.lock_reset,
                          title: 'Change Password',
                          onTap: () async {
                            try {
                              await context.read<AuthCubit>().sendPasswordResetEmail(profile.email);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                            }
                          },
                        ),
                        _divider(context),
                        _buildProfileButton(
                          context,
                          icon: Icons.logout_outlined,
                          title: 'Logout',
                          iconColor: Colors.red,
                          onTap: () async {
                            await context.read<AuthCubit>().logout();
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LoginScreen()), (route)=>false);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  FutureBuilder<String>(
                    future: _appVersion(),
                    builder: (context, snap) {
                      final version = snap.data ?? '—';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text('Version: $version',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Generic Button Builder (kept)
  Widget _buildProfileButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        bool isToggle = false,
        bool isActive = false,
        Color? iconColor,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).colorScheme.primaryContainer).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  size: 20, color: iconColor ?? Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
    );
  }

  Widget _infoTile(BuildContext context, {required IconData icon, required String title, required String value, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(value.isEmpty ? '—' : value),
      trailing: trailing,
    );
  }
}
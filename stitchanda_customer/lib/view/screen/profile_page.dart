import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../base/bottom_nav_scaffold.dart';
import '../../data/models/customer_model.dart';
import '../../controller/auth_cubit.dart';
import '../auth_services.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import '../../helper/upload_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    final inShell = context.findAncestorWidgetOfExactType<BottomNavScaffold>() != null;
    if (!inShell) {
      return const BottomNavScaffold(initialIndex: 1);
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthUnauthenticated || state is AuthError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            body: const Center(child: Text('No customer logged in')),
          );
        }

        final accent = const Color(0xFFD29356);
        final customer = (state as AuthAuthenticated).customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(customer: customer),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header with Picture
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withValues(alpha: 0.1),
                        Colors.white,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: customer.profileImagePath.isNotEmpty
                                  ? Image.network(
                                      customer.profileImagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildAvatarInitials(customer),
                                    )
                                  : _buildAvatarInitials(customer),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingImage ? null : _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isUploadingImage ? Colors.grey : accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: _isUploadingImage
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Customer Name
                      Text(
                        customer.name.isNotEmpty ? customer.name : customer.email,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Details Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      _buildInfoCard(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: customer.name,
                        iconColor: accent,
                      ),
                      const SizedBox(height: 12),

                      // Phone Number
                      _buildInfoCard(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        value: customer.phone.isNotEmpty ? customer.phone : 'Not provided',
                        iconColor: accent,
                      ),
                      const SizedBox(height: 12),

                      // Email
                      _buildInfoCard(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: customer.email,
                        iconColor: accent,
                      ),
                      const SizedBox(height: 12),

                      // Gender
                      _buildInfoCard(
                        icon: _getGenderIcon(customer.gender),
                        label: 'Gender',
                        value: customer.gender.isNotEmpty ? customer.gender : 'Not specified',
                        iconColor: accent,
                      ),
                      const SizedBox(height: 12),

                      // Address
                      _buildInfoCard(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: customer.address.fullAddress.isNotEmpty ? customer.address.fullAddress : 'Not provided',
                        iconColor: accent,
                        isMultiline: true,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildActionButton(
                        icon: Icons.lock_outline,
                        label: 'Change Password',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildActionButton(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification settings coming soon!'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildActionButton(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help & Support coming soon!'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildActionButton(
                        icon: Icons.info_outline,
                        label: 'About',
                        onTap: () {
                          _showAboutDialog();
                        },
                      ),
                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showLogoutDialog(context);
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarInitials(CustomerModel customer) {
    return Container(
      color: const Color(0xFFF5E6D7),
      child: Center(
        child: Text(
          _computeInitials(customer.name.isNotEmpty ? customer.name : customer.email),
           style: const TextStyle(
             fontSize: 40,
             fontWeight: FontWeight.bold,
             color: Color(0xFFD29356),
           ),
         ),
      ),
    );
  }

  String _computeInitials(String source) {
    final parts = source.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  IconData _getGenderIcon(String? gender) {
    if (gender == null) return Icons.person_outline;
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.person_outline;
    }
  }

  void _showLogoutDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthCubit>().logout();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully!'),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate through the auth gate to ensure proper session routing
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthServices()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Stitchanda'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stitchanda Customer App',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Connect with skilled tailors and get your clothes stitched to perfection.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show options to select image from gallery or camera
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Profile Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFD29356)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFD29356)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Pick image from the selected source and upload to Supabase, then persist URL in Firestore
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // Resolve current user id
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('You must be logged in to update your profile photo.');
      }
      final uid = authState.customer.customerId;

      // Upload to Supabase and obtain public URL
      final publicUrl = await uploadImageToSupabase(
        role: 'customer',
        uid: uid,
        type: 'profile',
        file: pickedFile,
      );

      if (publicUrl == null || publicUrl.isEmpty) {
        throw Exception('Failed to upload image.');
      }



      await context.read<AuthCubit>().updateProfile(
        profileImagePath: publicUrl,
      );

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

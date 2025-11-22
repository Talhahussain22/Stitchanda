import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stichanda_driver/controller/authCubit.dart';
import 'package:stichanda_driver/view/base/custom_app_bar.dart';
import 'package:stichanda_driver/helper/upload_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtl;
  late TextEditingController _phoneCtl;
  XFile? _picked;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthCubit>().state.profile;
    _nameCtl = TextEditingController(text: profile?.name ?? '');
    _phoneCtl = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() { _picked = file; });
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 3) return 'Enter at least 3 characters';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required';
    // Pakistan phone validation (basic): 03XXXXXXXXX or +92XXXXXXXXXX
    final pk = RegExp(r'^(?:\+92|0)?3[0-9]{9}$');
    if (!pk.hasMatch(v.trim())) return 'Enter a valid Pakistani phone number';
    return null;
  }

  Future<String?> _uploadImageReturningUrl(XFile file) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      return await uploadImageToSupabase(role: 'driver', uid: uid, type: 'profile', file: file);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtl.text.trim();
    final phone = _phoneCtl.text.trim();

    String? imageUrl;
    if (_picked != null) {
      imageUrl = await _uploadImageReturningUrl(_picked!);
      if (imageUrl == null || imageUrl.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile image. Please try again.')),
        );
        return; // do not proceed with saving
      }
    }

    await context.read<AuthCubit>().updateProfile(
      name: name,
      phone: phone,
      imagePath: imageUrl,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AuthCubit>().state.profile;
    final currentImage = profile?.profileImagePath ?? '';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Update Profile'),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final loading = state.isLoading;
          return AbsorbPointer(
            absorbing: loading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                            backgroundImage: _picked != null
                                ? FileImage(File(_picked!.path))
                                : (currentImage.isNotEmpty ? NetworkImage(currentImage) as ImageProvider : null),
                            child: (currentImage.isEmpty && _picked == null)
                                ? const Icon(Icons.person, size: 48)
                                : null,
                          ),
                          IconButton(
                            tooltip: 'Change photo',
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            onPressed: _pickImage,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameCtl,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      textInputAction: TextInputAction.next,
                      validator: _validateName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtl,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _save,
                        child: loading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save Changes'),
                      ),
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

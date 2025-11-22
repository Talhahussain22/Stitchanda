import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:stichanda_driver/helper/upload_image.dart';
import 'package:stichanda_driver/helper/validation_helper.dart';
import 'package:stichanda_driver/view/base/custom_button.dart';
import 'package:stichanda_driver/view/base/custom_text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stichanda_driver/view/screen/dashboard/dashboard_screen.dart';
import 'package:stichanda_driver/view/screen/auth/pending_status_screen.dart';

import '../../../../controller/authCubit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController fnameController;
  late TextEditingController lnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  XFile? image;

  @override
  void initState() {
    fnameController = TextEditingController();
    lnameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.initState();
  }

  dispose() {
    fnameController.dispose();
    lnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  int page = 0;

  void changePage(int p) {
    setState(() {
      page = p;
    });
  }

  void pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = selectedImage;
    });
  }



  void cancelImage() {
    setState(() {
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: page == 0
          ? PreferredSize(preferredSize: Size(0, 0), child: SizedBox())
          : AppBar(
              leading: IconButton(
                onPressed: () {
                  if (page == 0) {
                    Navigator.pop(context);
                  }
                  if (page == 1) {
                    changePage(0);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
              ),
            ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<AuthCubit>().clearError();
          } else if (state.isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up successful!')),
            );
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const PendingStatusScreen()), (Route<dynamic> route) => false);
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state.isLoading,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (page == 0) ...[
                      Stack(
                        children: [
                          Image.asset('assets/images/authphoto.png'),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    weight: 40,
                                    size: 35,
                                  )),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                child: const Text(
                                    'Join the Network, Deliver Fashion and Earn Rewards',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hintText: 'First Name',
                              controller: fnameController,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your first name'
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: CustomTextField(
                              hintText: 'Last Name',
                              controller: lnameController,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your last name'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: 'Email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: ValidationHelper.validateEmail,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: 'Phone Number',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: ValidationHelper.validatePakistanPhoneNumber,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: 'Password',
                        controller: passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: ValidationHelper.validatePassword,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: 'Confirm Password',
                        controller: confirmPasswordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 80,
                      )
                    ] else
                      ...[
                        Text(
                          'Upload Your CNIC',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 27, vertical: 8),
                          child: Text(
                            'Please upload a clear picture of your CNIC for verification. Ensure all details are visiblle',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        UploadCard(
                          title: 'Upload CNIC',
                          subtitle: 'Tap to upload your CNIC',
                          image: image,
                          onUpload: () {
                            pickImage();
                          },
                          onClose: () => cancelImage(),
                        )
                      ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: CustomButton(

          buttonText: page == 0 ? 'Next' : 'Sign Up',
          onPressed: () {
            if (page == 0) {
              if (_formKey.currentState!.validate()) {
                changePage(1);
              }
            } else if (page == 1) {
              if (image != null) {
                context.read<AuthCubit>().signUp(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      fname: fnameController.text.trim(),
                      lname: lnameController.text.trim(),
                      phone: phoneController.text.trim(),
                      cnicImage: image,
                    );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please upload your CNIC image.')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class UploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onUpload;
  final VoidCallback onClose;
  XFile? image;

  UploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onUpload,
    required this.image,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DottedBorder(
        color: Colors.grey.shade400,
        strokeWidth: 1,
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 4],
        child: Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          // padding: const EdgeInsets.all(16),
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: CustomButton(
                            buttonText: 'Upload', onPressed: onUpload),
                      ),
                    ])
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                    ),
                    Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: onClose,
                          icon: Icon(
                            Icons.close,
                            color: Colors.red,
                            weight: 40,
                            size: 30,
                          ),
                        )),
                  ],
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/tailor_model.dart';
import 'package:stichanda_customer/modules/chat/cubit/chat_cubit.dart';
import 'package:stichanda_customer/modules/chat/screens/chat_screen.dart';
import 'create_order_page.dart';

class TailorDetailsPage extends StatelessWidget {
  final Tailor tailor;

  const TailorDetailsPage({super.key, required this.tailor});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD29356);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tailor Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Profile
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Picture/Initials
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF5E6D7),
                      border: Border.all(color: accent, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: tailor.image_path != null && tailor.image_path!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              tailor.image_path!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  tailor.initials,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              tailor.initials,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    tailor.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tailor.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating & Experience
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (tailor.review != null) ...[
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          tailor.review!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (tailor.experience != null) ...[
                        Icon(Icons.work_outline, color: accent, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${tailor.experience} years exp.',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Verification Badge
                  if (tailor.is_verified == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, color: Colors.blue, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Tailor',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  if (tailor.phone != null && tailor.phone!.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: tailor.phone!,
                      iconColor: accent,
                    ),
                  if (tailor.phone != null && tailor.phone!.isNotEmpty)
                    const SizedBox(height: 12),

                  // Email
                  if (tailor.email != null && tailor.email!.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: tailor.email!,
                      iconColor: accent,
                    ),
                  if (tailor.email != null && tailor.email!.isNotEmpty)
                    const SizedBox(height: 12),

                  // Address
                  if (tailor.area.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: tailor.area,
                      iconColor: accent,
                      isMultiline: true,
                    ),

                  const SizedBox(height: 24),

                  // Availability Status
                  if (tailor.availability_status != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tailor.availability_status == true
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tailor.availability_status == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tailor.availability_status == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: tailor.availability_status == true
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            tailor.availability_status == true
                                ? 'Currently Available'
                                : 'Currently Unavailable',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: tailor.availability_status == true
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      // Chat Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final me = FirebaseAuth.instance.currentUser?.uid;
                            if (me == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Not authenticated')),
                              );
                              return;
                            }
                            try {
                              final conv = await context.read<ChatCubit>().startConversation(me, tailor.id);
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ChatCubit>(),
                                    child: ChatScreen(conversation: conv),
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to open chat: $e')),
                              );
                            }
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Place Order Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateOrderPage(preSelectedTailor: tailor),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}


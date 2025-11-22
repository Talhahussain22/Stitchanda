import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/tailor_cubit.dart';
import 'create_order_page.dart';
import 'tailor_details_page.dart';
import '../base/bottom_nav_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stichanda_customer/modules/chat/cubit/chat_cubit.dart';
import 'package:stichanda_customer/modules/chat/screens/chat_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAllTailors = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inShell = context.findAncestorWidgetOfExactType<BottomNavScaffold>() != null;
    if (!inShell) {
      return const BottomNavScaffold(initialIndex: 2);
    }

    final theme = Theme.of(context);
    final accent = const Color(0xFFD29356);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text(
          'Stichanda',
          style: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) {
                          context.read<TailorCubit>().searchTailors(v);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search tailors...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Featured heading
              BlocBuilder<TailorCubit, TailorState>(
                builder: (context, state) {
                  final showButton = state is TailorLoaded && state.filteredTailors.length > 3;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Tailors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showButton)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllTailors = !_showAllTailors;
                            });
                          },
                          child: Text(
                            _showAllTailors ? 'Show less' : 'See all',
                            style: const TextStyle(color: Color(0xFFD29356)),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // Tailor cards with BlocBuilder
              BlocBuilder<TailorCubit, TailorState>(
                builder: (context, state) {
                  if (state is TailorLoading || state is TailorInitial) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD29356)),
                        ),
                      ),
                    );
                  }

                  if (state is TailorError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Color(0xFFD32F2F)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<TailorCubit>().loadTailors();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is TailorLoaded) {
                    final allTailors = state.filteredTailors;

                    if (allTailors.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No tailors found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                      );
                    }

                    // Limit to 3 tailors if _showAllTailors is false
                    final tailors = _showAllTailors
                        ? allTailors
                        : allTailors.take(3).toList();

                    return Column(
                      children: tailors.map((t) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TailorDetailsPage(tailor: t),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // initials box
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5E6D7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          t.initials,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // name and details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.name,
                                            style: const TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Area: ${t.area}',
                                            style: const TextStyle(
                                              color: Color(0xFF616161),
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Category: ${t.category}',
                                            style: const TextStyle(
                                              color: Color(0xFF616161),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Chat button
                                    ElevatedButton(
                                      onPressed: () async {
                                        final me = FirebaseAuth.instance.currentUser?.uid;
                                        if (me == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
                                          return;
                                        }
                                        // Create or fetch conversation
                                        try {
                                          final conv = await context.read<ChatCubit>().startConversation(me, t.id);
                                          if (!mounted) return;
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
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accent,
                                        foregroundColor: const Color(0xFFFFFFFF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      child: const Text('Chat'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 20),

              // Create Order button

            ],

          ),
        ),

      ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateOrderPage()),
              );
            },
            icon: const Icon(Icons.add_circle_outline, size: 22),
            label: const Text(
              'Create Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

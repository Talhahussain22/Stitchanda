import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/controller/OrderCubit.dart';
import 'package:stichanda_driver/controller/authCubit.dart';
import 'package:stichanda_driver/controller/dashboard_index_cubit.dart';
import 'package:stichanda_driver/data/repository/auth_repo.dart';
import 'package:stichanda_driver/data/repository/order_repo.dart';
import 'package:stichanda_driver/modules/chat/cubit/chat_cubit.dart';
import 'package:stichanda_driver/modules/chat/repository/chat_repository.dart';
import 'package:stichanda_driver/services/location_service.dart';
import 'package:stichanda_driver/theme/light_theme.dart';
import 'package:stichanda_driver/view/screen/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

// class _LifecycleHandler extends WidgetsBindingObserver {
//   final AuthCubit authCubit;
//   _LifecycleHandler(this.authCubit);
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // When app goes to background or detached, set availability offline
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached ||
//         state == AppLifecycleState.inactive) {
//       authCubit.updateActiveStatus(0);
//     }
//   }
// }

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://rzkrwgexdqksrudynxvp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6a3J3Z2V4ZHFrc3J1ZHlueHZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3MTUxNjAsImV4cCI6MjA3NzI5MTE2MH0.bQytv6utSf9ArstDr6nu1K5L66XuFj5vTBYiWSR-xRw',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // _LifecycleHandler? _lifecycleHandler;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(
            authRepo: AuthRepo(),
            locationService: LocationService(),
          ),
        ),
        BlocProvider(
          create: (_) => ChatCubit(ChatRepository()),
        ),
        BlocProvider(
            create: (context) =>
                OrderCubit(orderRepository: DriverOrderRepository())),
        BlocProvider(
          create: (_) => DashboardIndexCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Attach lifecycle observer once AuthCubit is available
          // _lifecycleHandler ??= _LifecycleHandler(context.read<AuthCubit>());
          // WidgetsBinding.instance.addObserver(_lifecycleHandler!);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

//   @override
//   void dispose() {
//     if (_lifecycleHandler != null) {
//       WidgetsBinding.instance.removeObserver(_lifecycleHandler!);
//     }
//     super.dispose();
//   }
}

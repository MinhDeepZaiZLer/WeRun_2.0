import 'package:dacs4_werun_2_0/core/di/injection.dart';
import 'package:dacs4_werun_2_0/presentation/navigation/app_router.dart';
import 'package:dacs4_werun_2_0/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:dacs4_werun_2_0/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();

  final authBloc = getIt<AuthBloc>();
  final appRouter = AppRouter(authBloc);

  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WeRun',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

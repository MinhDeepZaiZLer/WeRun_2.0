// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // <-- Thêm
import 'firebase_options.dart'; 
import 'core/di/injection.dart'; 
import 'presentation/navigation/app_router.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/auth/bloc/auth_bloc.dart'; // <-- Thêm

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies(); 
   await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // *** BỌC ỨNG DỤNG BẰNG BLOCPROVIDER ***
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(), // Lấy AuthBloc từ DI
      child: MaterialApp.router(
        title: 'WeRun Flutter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, 
        
        // Lấy router từ AppRouter, nhưng KHÔNG LẤY _authBloc
        // vì chúng ta đã cung cấp ở trên
        routerConfig: AppRouter.router,
      ),
    );
  }
  
}
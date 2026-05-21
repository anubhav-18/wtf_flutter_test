import 'package:flutter/material.dart';
import 'package:wtf_shared/wtf_shared.dart';

import '../screens/guru_splash_screen.dart';

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guru App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.guruPrimary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const GuruSplashScreen(),
    );
  }
}

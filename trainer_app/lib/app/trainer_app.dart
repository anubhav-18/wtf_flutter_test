import 'package:flutter/material.dart';
import 'package:wtf_shared/wtf_shared.dart';

import '../screens/trainer_splash_screen.dart';

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.trainerPrimary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const TrainerSplashScreen(),
    );
  }
}

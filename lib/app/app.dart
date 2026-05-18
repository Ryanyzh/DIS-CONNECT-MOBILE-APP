import 'package:flutter/material.dart';
import 'router.dart';
import '../core/theme/app_theme.dart';

class DisConnectApp extends StatelessWidget {
  const DisConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'dis-connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
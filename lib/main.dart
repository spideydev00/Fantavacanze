import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey: AppSecrets.supabaseKey,
    url: AppSecrets.supabaseUrl,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantavacanze',
      home: const SocialLoginPage(),
      theme: AppTheme.getDarkTheme(context),
      debugShowCheckedModeBanner: false,
    );
  }
}

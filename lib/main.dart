import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final serverClientId =
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ??
      'TODO_INSERT_YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  final androidClientId = dotenv.env['GOOGLE_ANDROID_CLIENT_ID'];
  await GoogleSignIn.instance.initialize(
    clientId: androidClientId,
    serverClientId: serverClientId,
  );

  runApp(const ProviderScope(child: CSBouiraApp()));
}

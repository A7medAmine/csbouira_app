import 'package:flutter/material.dart';import 'package:flutter_dotenv/flutter_dotenv.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';import 'package:google_sign_in/google_sign_in.dart';import 'package:supabase_flutter/supabase_flutter.dart';import 'app.dart';String _requireEnv(String key) {
  final value = dotenv.env[key];
  if (value == null) {
    throw Exception('Missing required environment variable: $key. Check your .env file.');
  }
  return value;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: _requireEnv('SUPABASE_URL'),
    publishableKey: _requireEnv('SUPABASE_ANON_KEY'),
  );    final rawClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
  final serverClientId = (rawClientId != null &&
          rawClientId != 'TODO_INSERT_YOUR_WEB_CLIENT_ID.apps.googleusercontent.com')
      ? rawClientId
      : null;  final androidClientId = dotenv.env['GOOGLE_ANDROID_CLIENT_ID'];  await GoogleSignIn.instance.initialize(    clientId: androidClientId,    serverClientId: serverClientId,  );  runApp(const ProviderScope(child: CSBouiraApp()));}
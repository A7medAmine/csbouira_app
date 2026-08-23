import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';

/// Maps a raw exception (network/database/auth failure) to a user-friendly,
/// localized message instead of surfacing raw exception text like
/// `PostgrestException(message: ..., code: 23505, ...)`.
String friendlyErrorMessage(Object error, AppLocalizations l10n) {
  if (error is SocketException || error is HandshakeException) {
    return l10n.authErrorNetwork;
  }
  if (error is TimeoutException) {
    return l10n.authErrorNetwork;
  }
  if (error is AuthException) {
    return error.message;
  }
  if (error is PostgrestException || error is StorageException) {
    return l10n.authErrorGeneric;
  }
  return l10n.authErrorGeneric;
}

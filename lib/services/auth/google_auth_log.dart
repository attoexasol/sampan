import 'dart:convert';

import 'package:flutter/foundation.dart';

/// JWTs are long; Android logcat / IDE consoles often **truncate or wrap** a single
/// `debugPrint` line, so two logs of the "same" token can **look** different.
/// Use [logGoogleAuthJwtSnapshot] to compare the same token across steps.
void logGoogleAuthJwtSnapshot(String label, String token) {
  if (token.isEmpty) {
    debugPrint('[GOOGLE_AUTH] $label: <empty>');
    return;
  }
  final n = token.length;
  const edge = 28;
  final head = n <= edge ? token : token.substring(0, edge);
  final tail = n <= edge ? '' : token.substring(n - edge);
  debugPrint('[GOOGLE_AUTH] $label jwt_len=$n head=$head... tail=...$tail');
}

/// Confirms [jsonEncode] of `{"token": idToken}` embeds the exact same string (no truncation in wire).
void logGoogleAuthPostBodyContainsToken(String idToken) {
  final body = <String, dynamic>{'token': idToken};
  final wire = jsonEncode(body);
  final contains = wire.contains(idToken);
  debugPrint(
    '[GOOGLE_AUTH] POST json wire_len=${wire.length} body_embeds_token_verbatim=$contains',
  );
}

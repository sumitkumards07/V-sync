import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GmailOtpService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '767383683310-uq2u9u0menoa8pl1pqkhtrv32s564jlj.apps.googleusercontent.com',
    scopes: ['https://www.googleapis.com/auth/gmail.readonly'],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      return null;
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<String?> fetchLatestOtp() async {
    try {
      GoogleSignInAccount? account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();

      if (account == null) return null;

      final auth = await account.authentication;
      final token = auth.accessToken;

      if (token == null) return null;

      final url = Uri.parse(
          'https://gmail.googleapis.com/gmail/v1/users/me/messages?q="from:info1@vitap.ac.in subject:VTOP Login OTP newer_than:1h"&maxResults=5');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final messages = data['messages'] as List<dynamic>?;

      if (messages == null || messages.isEmpty) return null;

      final messageId = messages.first['id'];
      final msgUrl = Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId?format=full');
      final msgResponse = await http.get(msgUrl, headers: {'Authorization': 'Bearer $token'});

      if (msgResponse.statusCode != 200) return null;

      final msgData = jsonDecode(msgResponse.body);
      final String internalDateStr = msgData['internalDate'];
      final int internalDateMs = int.parse(internalDateStr);
      final DateTime internalDate = DateTime.fromMillisecondsSinceEpoch(internalDateMs);

      if (DateTime.now().difference(internalDate).inMinutes > 3) {
        return null; // Reject if older than 3 minutes
      }

      final body = _extractBody(msgData['payload']);
      if (body == null) return null;

      return _extractOtp(body);
    } catch (e) {
      return null;
    }
  }

  String? _extractBody(Map<String, dynamic> payload) {
    if (payload['mimeType'] == 'text/plain' || payload['mimeType'] == 'text/html') {
      final data = payload['body']['data'] as String?;
      if (data != null) {
        final decoded = utf8.decode(base64Decode(data.replaceAll('-', '+').replaceAll('_', '/')));
        return decoded;
      }
    }

    final parts = payload['parts'] as List<dynamic>?;
    if (parts != null) {
      String? htmlBody;
      for (var part in parts) {
        if (part['mimeType'] == 'text/plain') {
          final data = part['body']['data'] as String?;
          if (data != null) {
            return utf8.decode(base64Decode(data.replaceAll('-', '+').replaceAll('_', '/')));
          }
        } else if (part['mimeType'] == 'text/html') {
          final data = part['body']['data'] as String?;
          if (data != null) {
            htmlBody = utf8.decode(base64Decode(data.replaceAll('-', '+').replaceAll('_', '/')));
          }
        } else if (part['mimeType'] == 'multipart/alternative' || part['mimeType'] == 'multipart/mixed') {
          final nestedBody = _extractBody(part);
          if (nestedBody != null) return nestedBody;
        }
      }
      return htmlBody;
    }
    return null;
  }

  String? _extractOtp(String body) {
    // Spacer digits like 4 0 7 7 5 8
    final spacedPattern = RegExp(r'\b(\d\s){5}\d\b');
    final matchSpaced = spacedPattern.firstMatch(body);
    if (matchSpaced != null) {
      return matchSpaced.group(0)!.replaceAll(' ', '');
    }

    final labeledPattern = RegExp(r'(?:one.time.password|otp)[^\d]*(\d{6})', caseSensitive: false);
    final matchLabeled = labeledPattern.firstMatch(body);
    if (matchLabeled != null) {
      return matchLabeled.group(1);
    }

    final fallbackPattern = RegExp(r'\b(\d{6})\b');
    final matchFallback = fallbackPattern.firstMatch(body);
    if (matchFallback != null) {
      return matchFallback.group(1);
    }

    return null;
  }
}

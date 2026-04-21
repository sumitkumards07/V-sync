import 'dart:async';
import 'package:enough_mail/enough_mail.dart';

class OtpMailService {
  /// Connects to the student's mailbox via IMAP and fetches the latest OTP
  /// sent by info1@vitap.ac.in within the last [withinMinutes] minutes.
  ///
  /// [email]    – student's full email, e.g. 22bce7777@vitap.ac.in
  /// [password] – their email / app password
  static Future<String?> fetchLatestOtp({
    required String email,
    required String password,
    int withinMinutes = 5,
  }) async {
    final client = ImapClient(isLogEnabled: false);

    try {
      // ── 1. Connect ────────────────────────────────────────────────────
      // VIT-AP uses Microsoft 365 → IMAP on outlook.office365.com:993
      await client.connectToServer(
        'outlook.office365.com',
        993,
        isSecure: true,
      );

      // ── 2. Login ──────────────────────────────────────────────────────
      final loginResponse = await client.login(email, password);
      if (!loginResponse.isOkStatus) {
        throw Exception('Login failed: ${loginResponse.details}');
      }

      // ── 3. Select INBOX ───────────────────────────────────────────────
      await client.selectInbox();

      // ── 4. Search for emails from the VIT-AP OTP sender ───────────────
      final searchResult = await client.searchMessages(
        SearchQueryBuilder.from(
          'info1@vitap.ac.in',
          SearchQueryType.fromOrTo,
        ),
      );

      if (searchResult.matchingSequence == null ||
          searchResult.matchingSequence!.isEmpty) {
        return null; // No emails found
      }

      // ── 5. Fetch the latest matching message ──────────────────────────
      final sequence = searchResult.matchingSequence!;
      final latestUid = sequence.last; // highest UID = newest

      final fetchResult = await client.fetchMessage(
        MessageSequence.fromId(latestUid, isUid: false),
        'BODY[TEXT] INTERNALDATE',
      );

      if (fetchResult.messages.isEmpty) return null;

      final message = fetchResult.messages.first;

      // ── 6. Check recency (within [withinMinutes]) ─────────────────────
      final internalDate = message.envelope?.date ?? DateTime.now();
      final age = DateTime.now().difference(internalDate);
      if (age.inMinutes > withinMinutes) {
        return null; // OTP email is too old
      }

      // ── 7. Extract OTP via regex ──────────────────────────────────────
      final body = message.decodeTextPlainPart() ??
          message.decodeTextHtmlPart() ??
          '';

      return _extractOtp(body);
    } catch (e) {
      // Surface the error to the caller; don't silently swallow it
      rethrow;
    } finally {
      await client.logout();
    }
  }

  /// Extracts a 4–8 digit OTP from email body text.
  static String? _extractOtp(String body) {
    // Common OTP patterns: "OTP is 123456", "Your OTP: 4567", plain digits
    final patterns = [
      RegExp(r'OTP[^\d]*(\d{4,8})', caseSensitive: false),
      RegExp(r'one.time.password[^\d]*(\d{4,8})', caseSensitive: false),
      RegExp(r'verification code[^\d]*(\d{4,8})', caseSensitive: false),
      RegExp(r'\b(\d{4,8})\b'), // fallback: any 4–8 digit number
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) return match.group(1);
    }
    return null;
  }
}

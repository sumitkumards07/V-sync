import 'package:flutter/material.dart';
import '../services/otp_mail_service.dart';

class OtpLoginScreen extends StatefulWidget {
  final String email;
  final String emailPassword; // <-- pass from login screen

  const OtpLoginScreen({
    super.key,
    required this.email,
    required this.emailPassword,
  });

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _otpController = TextEditingController();
  bool _isFetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-fetch as soon as screen opens (after a small delay for the email
    // to arrive)
    Future.delayed(const Duration(seconds: 3), _autoFetchOtp);
  }

  Future<void> _autoFetchOtp() async {
    setState(() {
      _isFetching = true;
      _error = null;
    });

    try {
      final otp = await OtpMailService.fetchLatestOtp(
        email: widget.email,
        password: widget.emailPassword,
      );

      if (otp != null && mounted) {
        setState(() => _otpController.text = otp);
        // Optionally auto-submit if you trust it completely:
        // _submitOtp();
      } else if (mounted) {
        setState(() => _error = 'OTP not found in inbox. Enter manually.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not read email: $e');
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'OTP sent to ${widget.email} by info1@vitap.ac.in',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'OTP',
                suffixIcon: _isFetching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Re-fetch OTP from email',
                        onPressed: _autoFetchOtp,
                      ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitOtp,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitOtp() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return;
    // TODO: call your Supabase / VTOP OTP verification logic here
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}

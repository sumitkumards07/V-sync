import 'dart:async';
import 'package:flutter/material.dart';
import '../services/gmail_otp_service.dart';

class OtpLoginScreen extends StatefulWidget {
  final String email;

  const OtpLoginScreen({super.key, required this.email});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final GmailOtpService _gmailOtpService = GmailOtpService();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isSignedIn = false;
  String? _signedInEmail;
  bool _isFetching = false;
  String? _statusText;
  bool _statusIsError = false;
  
  Timer? _countdownTimer;
  int _secondsRemaining = 180; // 3 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
    _attemptSilentSignIn();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _attemptSilentSignIn() async {
    try {
      final account = await _gmailOtpService.signInSilently();
      if (account != null && mounted) {
        setState(() {
          _isSignedIn = true;
          _signedInEmail = account.email;
        });
        
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) _fetchOtp();
        });
      }
    } catch (e) {
      // Ignore silent sign-in errors
    }
  }

  Future<void> _handleSignIn() async {
    try {
      final account = await _gmailOtpService.signIn();
      if (account != null && mounted) {
        setState(() {
          _isSignedIn = true;
          _signedInEmail = account.email;
          _statusText = 'Signed in successfully.';
          _statusIsError = false;
        });
        _fetchOtp();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Failed to sign in.';
          _statusIsError = true;
        });
      }
    }
  }

  Future<void> _handleSwitchAccount() async {
    await _gmailOtpService.signOut();
    if (mounted) {
      setState(() {
        _isSignedIn = false;
        _signedInEmail = null;
      });
      _handleSignIn();
    }
  }

  Future<void> _fetchOtp() async {
    if (!mounted) return;
    setState(() {
      _isFetching = true;
      _statusText = 'Fetching OTP from Gmail...';
      _statusIsError = false;
    });

    try {
      final otp = await _gmailOtpService.fetchLatestOtp();
      if (!mounted) return;

      if (otp != null) {
        setState(() {
          _otpController.text = otp;
          _statusText = 'OTP fetched successfully.';
          _statusIsError = false;
        });
      } else {
        setState(() {
          _statusText = 'No recent OTP found in Gmail. Try again.';
          _statusIsError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Failed to read email: $e';
          _statusIsError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() {
        _statusText = 'Enter a 6-digit OTP.';
        _statusIsError = true;
      });
      return;
    }
    
    // TODO: Pass the verified OTP to the existing Rust scraper / VTOP login flow
    // Hook into Supabase auth session
    
    setState(() {
      _statusText = 'Verifying...';
      _statusIsError = false;
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'OTP sent to ${widget.email} by info1@vitap.ac.in',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            if (!_isSignedIn)
              OutlinedButton.icon(
                onPressed: _handleSignIn,
                icon: const Icon(Icons.email),
                label: const Text('Sign in with Google to auto-fetch OTP'),
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _signedInEmail ?? 'Signed in',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _handleSwitchAccount,
                    child: const Text('Switch account'),
                  ),
                ],
              ),
              
            const SizedBox(height: 32),
            
            Text(
              _formattedTime,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _secondsRemaining < 60 ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                letterSpacing: 14,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'OTP',
                counterText: '',
                suffixIcon: _isFetching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Re-fetch OTP',
                        onPressed: _isSignedIn ? _fetchOtp : null,
                      ),
              ),
            ),
            
            if (_statusText != null) ...[
              const SizedBox(height: 16),
              Text(
                _statusText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _statusIsError ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _secondsRemaining > 0 ? _verifyOtp : null,
                child: const Text('Verify OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

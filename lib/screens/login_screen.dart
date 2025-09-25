import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthServiceApi auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _run(Future<void> Function() fn) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await fn();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'SPORTLINK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign up to see on-going sport events, photos &\nvideos from your friends',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7A7A7A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),
                _FaintInput(
                    hint: 'Phone number, email, or username',
                    borderRadius: borderRadius,
                    controller: _emailCtrl),
                const SizedBox(height: 16),
                _FaintInput(
                    hint: 'Password',
                    obscure: true,
                    borderRadius: borderRadius,
                    controller: _passCtrl),
                const SizedBox(height: 28),
                _GreyButton(
                  label: _loading ? 'Please wait...' : 'LOG IN',
                  borderRadius: borderRadius,
                  onPressed: _loading
                      ? null
                      : () => _run(() => widget.auth.loginWithEmail(
                          _emailCtrl.text.trim(), _passCtrl.text)),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                ],
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),
                _SocialButton(
                  label: 'Continue with Google',
                  icon: Image.asset('assets/google_logo.jpg',
                      width: 20, height: 20),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  borderColor: const Color(0xFFE0E0E0),
                  onPressed: _loading
                      ? null
                      : () => _run(() => widget.auth.signInWithGoogle()),
                ),
                const SizedBox(height: 12),
                _SocialButton(
                  label: 'Continue with Apple',
                  icon: SvgPicture.asset('assets/apple_logo.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn)),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  borderColor: Colors.black,
                  onPressed: _loading
                      ? null
                      : () => _run(() => widget.auth.signInWithApple()),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: _loading
                            ? null
                            : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            SignUpScreen(auth: widget.auth)));
                              },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaintInput extends StatelessWidget {
  final String hint;
  final bool obscure;
  final BorderRadius borderRadius;
  final TextEditingController? controller;

  const _FaintInput({
    required this.hint,
    required this.borderRadius,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
        ),
      ),
    );
  }
}

class _GreyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;

  const _GreyButton({
    required this.label,
    required this.onPressed,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD9D9D9),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}

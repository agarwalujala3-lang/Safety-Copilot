import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/animated_safety_hero.dart';
import '../widgets/security_backdrop.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _registerMode = false;
  String? _localError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState state) async {
    FocusScope.of(context).unfocus();
    setState(() => _localError = null);

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passCtrl.text;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (_registerMode && name.length < 2) {
      setState(() => _localError = 'Name must be at least 2 characters.');
      return;
    }
    if (cleanPhone.length < 10) {
      setState(() => _localError = 'Enter a valid phone number.');
      return;
    }
    if (password.length < 6) {
      setState(() => _localError = 'Password must be at least 6 characters.');
      return;
    }

    if (_registerMode) {
      await state.register(name: name, phone: cleanPhone, password: password);
    } else {
      await state.login(phone: cleanPhone, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final shownError = _localError ?? state.error;

    return Scaffold(
      body: SecurityBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  children: [
                    const AnimatedSafetyHero(),
                    const SizedBox(height: 12),
                    Text(
                      'SAFETY COPILOT',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Adaptive travel defense for trusted circles.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms, duration: 450.ms),
                    const SizedBox(height: 18),
                    _GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _registerMode
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.fingerprint_rounded,
                                color: const Color(0xFF95F7E5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _registerMode
                                    ? 'Create secured account'
                                    : 'Welcome back, operator',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_registerMode) ...[
                            TextField(
                              controller: _nameCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_android_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passCtrl,
                            obscureText: true,
                            onSubmitted: (_) => state.busy ? null : _submit(state),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF00E6B4),
                                    Color(0xFF2AB6FF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x6600E6B4),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: const Color(0xFF052116),
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: state.busy ? null : () => _submit(state),
                                child: Text(
                                  state.busy
                                      ? 'Securing session...'
                                      : _registerMode
                                          ? 'Create Account'
                                          : 'Unlock Dashboard',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: state.busy
                                ? null
                                : () => setState(() => _registerMode = !_registerMode),
                            child: Text(
                              _registerMode
                                  ? 'Have an account? Login'
                                  : 'New here? Create account',
                            ),
                          ),
                          if (shownError != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0x40FF5F5F),
                                border: Border.all(color: const Color(0x88FF7E7E)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Color(0xFFFFC3C3)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      shownError,
                                      style: const TextStyle(
                                        color: Color(0xFFFFD8D8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).moveY(begin: 10, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x77467E97)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xC8112738),
            Color(0xB4091B2B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x5200D9FF),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

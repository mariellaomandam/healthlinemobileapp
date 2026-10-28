
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  static const Color _background = Color(0xFF101010);
  static const Color _surface = Color(0xFF1C1A1A);
  static const Color _mauve = Color(0xFF806666);
  static const Color _accent = Color(0xFFFF454D);
  static const Color _muted = Color(0xFFAAAAAA);
  static const Color _lightMauve = Color(0xFFE6CACA);

  bool _obscurePassword = true;
  bool _googleInitialized = false;
  bool _isLoading = false;

  StreamSubscription<GoogleSignInAuthenticationEvent>?
      _googleSubscription;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      _googleSubscription =
          googleSignIn.authenticationEvents.listen(
        (event) {
          if (!mounted) return;

          if (event is GoogleSignInAuthenticationEventSignIn) {
            _openDashboard();
          }
        },
        onError: (Object error) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Google sign-in failed. Please try again.',
              ),
              backgroundColor: _mauve,
            ),
          );
        },
      );

      if (mounted) {
        setState(() => _googleInitialized = true);
      }
    } catch (error) {
      debugPrint(
        'Google Sign-In initialization error: $error',
      );
    }
  }

  void _openDashboard() {
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard',
      (route) => false,
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email and password.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password,
      );
      final user = credential.user!;
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await userRef.get();
      if (snapshot.exists && snapshot.data()?['role'] != 'patient') {
        await FirebaseAuth.instance.signOut();
        throw FirebaseAuthException(
          code: 'wrong-role',
          message: 'This account is not registered as a patient.',
        );
      }
      await userRef.set({
        'uid': user.uid,
        'role': 'patient',
        'displayName': user.displayName ?? '',
        'email': user.email ?? email,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) _openDashboard();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = error.code == 'wrong-role'
          ? (error.message ?? 'This account has a different role.')
          : error.code == 'user-not-found' || error.code == 'wrong-password' || error.code == 'invalid-credential'
              ? 'Incorrect email or password.'
              : error.message ?? 'Unable to sign in.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: _mauve),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $error'), backgroundColor: _mauve),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!_googleInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google sign-in is still initializing.',
          ),
          backgroundColor: _mauve,
        ),
      );
      return;
    }

    // The web button handles Google sign-in on web.
    if (kIsWeb) return;

    try {
      await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google sign-in failed: '
            '${error.description ?? error.code.name}',
          ),
          backgroundColor: _mauve,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sign in with Google.'),
          backgroundColor: _mauve,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _googleSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  Container(
                    width: 76,
                    height: 76,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _mauve.withAlpha(65),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFFB5B5),
                      size: 39,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'HealthLine PH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Your health, our priority.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 38),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withAlpha(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Log in to your patient account',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 28),

                        _buildLabel(
                          'Email or phone number',
                        ),

                        const SizedBox(height: 9),

                        TextField(
                          controller: _emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: _inputDecoration(
                            hint: 'Enter your email or phone',
                            icon: Icons.person_outline_rounded,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildLabel('Password'),

                        const SizedBox(height: 9),

                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: _inputDecoration(
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: _muted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _accent.withAlpha(100),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: _mauve,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: _mauve,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        if (kIsWeb)
                          buildGoogleSignInButton()
                        else
                          SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _signInWithGoogle,
                              icon: const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      Colors.white.withAlpha(35),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 18),

OutlinedButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, '/organization-login');
  },
  icon: const Icon(
    Icons.local_hospital_outlined,
    color: Color(0xFFE6CACA),
    size: 21,
  ),
  label: const Text(
    'Sign in as a Clinic or Hospital',
    style: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    side: BorderSide(
      color: Colors.white.withAlpha(35),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
),

const SizedBox(height: 8),

                        
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'HealthLine PH  •  Your health matters',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _lightMauve,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        color: _lightMauve,
        size: 20,
      ),
      filled: true,
      fillColor: _background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.white.withAlpha(18),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _mauve,
          width: 1.4,
        ),
      ),
    );
  }
}

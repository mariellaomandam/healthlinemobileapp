import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationLoginScreen extends StatefulWidget {
  const OrganizationLoginScreen({super.key});

  @override
  State<OrganizationLoginScreen> createState() =>
      _OrganizationLoginScreenState();
}

class _OrganizationLoginScreenState extends State<OrganizationLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const Color _background = Color(0xFF101010);
  static const Color _surface = Color(0xFF1C1A1A);
  static const Color _mauve = Color(0xFF806666);
  static const Color _accent = Color(0xFFFF454D);
  static const Color _muted = Color(0xFFAAAAAA);

  bool _obscurePassword = true;

  @override
  void dispose() {
    _organizationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = credential.user!;
      final users = FirebaseFirestore.instance.collection('users');
      final userRef = users.doc(user.uid);
      final snapshot = await userRef.get();
      if (snapshot.exists && snapshot.data()?['role'] != 'clinic') {
        await FirebaseAuth.instance.signOut();
        throw FirebaseAuthException(
          code: 'wrong-role',
          message: 'This account is not registered as a clinic.',
        );
      }
      await userRef.set({
        'uid': user.uid,
        'role': 'clinic',
        'displayName': _organizationController.text.trim(),
        'email': user.email ?? _emailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context, '/organization-dashboard', (route) => false,
      );
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

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFE6CACA), size: 20),
      filled: true,
      fillColor: _background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withAlpha(18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _mauve, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Organization Sign In'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(18)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.local_hospital_outlined,
                        color: Color(0xFFE6CACA),
                        size: 54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Clinic or Hospital Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to manage patient appointment requests '
                        'and scheduling.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Organization name',
                        style: TextStyle(color: Color(0xFFE6CACA)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _organizationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration(
                          hint: 'Clinic or hospital name',
                          icon: Icons.business_outlined,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter your organization name'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Work email',
                        style: TextStyle(color: Color(0xFFE6CACA)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration(
                          hint: 'name@clinic.com',
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your work email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Password',
                        style: TextStyle(color: Color(0xFFE6CACA)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration(
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: _muted,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Enter your password'
                                : null,
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: const Icon(Icons.login_rounded),
                          label: Text(_isLoading ? 'Signing in…' : 'Sign In'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back to patient login',
                          style: TextStyle(color: Color(0xFFE6CACA)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

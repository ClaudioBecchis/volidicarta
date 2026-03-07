import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _OAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _OAuthButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onTap,
        icon: Icon(icon, color: color, size: 22),
        label: Text(label, style: TextStyle(color: color, fontSize: 14)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _oauthLoading = false;
  String? _error;

  Future<void> _oauthLogin(OAuthProvider provider) async {
    setState(() { _oauthLoading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.Voli di Carta://login-callback/',
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('not enabled') ||
          e.message.toLowerCase().contains('unsupported provider')) {
        if (mounted) {
          setState(() { _error = null; });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Accesso social non ancora attivo. Usa email e password.'),
            backgroundColor: Color(0xFF1A5276),
          ));
        }
      } else {
        if (mounted) setState(() => _error = e.message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Accesso social non ancora attivo. Usa email e password.'),
          backgroundColor: Color(0xFF1A5276),
        ));
      }
    }
    if (mounted) setState(() => _oauthLoading = false);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final err = await AuthService().login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _error = err; });
    } else {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ascolta il login OAuth completato
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          size: 64, color: Color(0xFF1A5276)),
                      const SizedBox(height: 12),
                      Text('Accedi',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: const Color(0xFF1A5276),
                                  fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Voli di Carta Community',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Campo obbligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo obbligatorio' : null,
                        onFieldSubmitted: (_) => _login(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(_error!,
                                      style:
                                          const TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Accedi',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen())),
                        child: const Text(
                            'Non hai un account? Registrati',
                            style: TextStyle(color: Color(0xFF1A5276))),
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

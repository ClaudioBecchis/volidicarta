import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import '../config/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  bool _notConfirmed = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; _notConfirmed = false; });
    final err = await AuthService().login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        if (err == 'account_non_confermato') {
          _notConfirmed = true;
          _error = 'Account non ancora confermato. Controlla la tua email.';
        } else {
          _error = err;
        }
      });
    } else {
      await AuthService().refreshAdminStatus();
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _loading = true);
    final err = await AuthService().resendConfirmation(_emailCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email di conferma inviata. Controlla la tua casella.'),
          backgroundColor: Color(0xFF1A5276),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 64, color: Color(0xFF1A5276)),
                      const SizedBox(height: 12),
                      Text('Accedi',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF1A5276), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Voli di Carta Community',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
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
                            color: _notConfirmed
                                ? Colors.orange.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _notConfirmed
                                  ? Colors.orange.shade300
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _notConfirmed
                                        ? Icons.mark_email_unread_outlined
                                        : Icons.error_outline,
                                    color: _notConfirmed ? Colors.orange : Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: _notConfirmed ? Colors.orange.shade800 : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_notConfirmed) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.send, size: 16),
                                    label: const Text('Rinvia email di conferma'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.orange.shade800,
                                      side: BorderSide(color: Colors.orange.shade300),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    onPressed: _loading ? null : _resendEmail,
                                  ),
                                ),
                              ],
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
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Accedi', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('Non hai un account? Registrati',
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

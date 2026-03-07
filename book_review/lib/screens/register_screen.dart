import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final err = await AuthService().register(
        _usernameCtrl.text, _emailCtrl.text, _passCtrl.text);
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
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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
                      Text('Crea Account',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: const Color(0xFF1A5276),
                                  fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obbligatorio';
                          if (v.trim().length < 3) return 'Min 3 caratteri';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obbligatorio';
                          if (!RegExp(r'^[\w.]+@[\w.]+\.\w+$').hasMatch(v.trim())) {
                            return 'Email non valida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure1,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure1
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure1 = !_obscure1),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obbligatorio';
                          if (v.length < 6) return 'Min 6 caratteri';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscure2,
                        decoration: InputDecoration(
                          labelText: 'Conferma Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure2
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure2 = !_obscure2),
                          ),
                        ),
                        validator: (v) {
                          if (v != _passCtrl.text) return 'Le password non coincidono';
                          return null;
                        },
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
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Registrati',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen())),
                        child: const Text('Hai gia un account? Accedi',
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

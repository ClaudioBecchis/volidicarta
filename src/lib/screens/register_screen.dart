import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  late final TapGestureRecognizer _privacyTapRec;
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _privacyAccepted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _privacyTapRec = TapGestureRecognizer()..onTap = _showPrivacyDialog;
  }

  @override
  void dispose() {
    _privacyTapRec.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_privacyAccepted) {
      setState(() => _error = 'Devi accettare l\'informativa sulla privacy per continuare.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await AuthService().register(
        _usernameCtrl.text, _emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _error = err; });
    } else {
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        setState(() => _loading = false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Registrazione completata!'),
            content: const Text(
                'Controlla la tua email e clicca sul link di conferma per attivare l\'account.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Informativa Privacy'),
        content: const SingleChildScrollView(
          child: Text(
            'I dati inseriti (username, email, password e recensioni) vengono '
            'salvati esclusivamente sui server cloud di Supabase (supabase.com), '
            'situati nell\'Unione Europea.\n\n'
            'NESSUN dato viene conservato localmente sul dispositivo in uso '
            'o su altri sistemi informatici privati.\n\n'
            'I tuoi dati sono protetti secondo il GDPR e le policy di Supabase. '
            'Puoi richiedere la cancellazione del tuo account in qualsiasi momento '
            'contattando il supporto.\n\n'
            'Le recensioni che condividi nella sezione Community sono visibili '
            'pubblicamente a tutti gli utenti dell\'app.\n\n'
            'Sviluppato da Claudio Becchis · polariscore.it',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _privacyAccepted = true);
              Navigator.pop(context);
            },
            child: const Text('Accetto'),
          ),
        ],
      ),
    );
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
                      const SizedBox(height: 4),
                      Text('Voli di Carta Community',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
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
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                            return 'Solo lettere, numeri e _';
                          }
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
                      const SizedBox(height: 16),

                      // Avviso cloud + privacy
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A5276).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF1A5276).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.cloud_outlined,
                                color: Color(0xFF1A5276), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'I tuoi dati sono salvati sui server cloud (Supabase EU). '
                                'Nessun dato viene conservato localmente su questo dispositivo '
                                'o su altri sistemi informatici.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Checkbox privacy
                      Row(
                        children: [
                          Checkbox(
                            value: _privacyAccepted,
                            onChanged: (v) =>
                                setState(() => _privacyAccepted = v ?? false),
                            activeColor: const Color(0xFF1A5276),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 12),
                                children: [
                                  const TextSpan(text: 'Ho letto e accetto l\''),
                                  TextSpan(
                                    text: 'informativa privacy',
                                    style: const TextStyle(
                                        color: Color(0xFF1A5276),
                                        decoration: TextDecoration.underline),
                                    recognizer: _privacyTapRec,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                        child: const Text('Hai già un account? Accedi',
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

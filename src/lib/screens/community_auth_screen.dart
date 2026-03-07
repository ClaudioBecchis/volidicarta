import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class CommunityAuthScreen extends StatefulWidget {
  const CommunityAuthScreen({super.key});

  @override
  State<CommunityAuthScreen> createState() => _CommunityAuthScreenState();
}

class _CommunityAuthScreenState extends State<CommunityAuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _loginFormKey = GlobalKey<FormState>();
  final _regFormKey = GlobalKey<FormState>();

  final _emailLogin = TextEditingController();
  final _passLogin = TextEditingController();
  final _usernameReg = TextEditingController();
  final _emailReg = TextEditingController();
  final _passReg = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailLogin.dispose();
    _passLogin.dispose();
    _usernameReg.dispose();
    _emailReg.dispose();
    _passReg.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final err = await SupabaseService().signIn(_emailLogin.text.trim(), _passLogin.text);
    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _error = err; });
    } else {
      Navigator.pop(context, true);
    }
  }

  Future<void> _register() async {
    if (!_regFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final err = await SupabaseService().signUp(
      _usernameReg.text.trim(),
      _emailReg.text.trim(),
      _passReg.text,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _error = err; });
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FB),
      appBar: AppBar(title: const Text('Accedi alla Community')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  const Icon(Icons.people_rounded, size: 56, color: Color(0xFF1A5276)),
                  const SizedBox(height: 8),
                  const Text('Voli di Carta Community',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5276))),
                  const SizedBox(height: 4),
                  Text('Condividi le tue recensioni con il mondo',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabs,
                    tabs: const [Tab(text: 'Accedi'), Tab(text: 'Registrati')],
                    indicatorColor: const Color(0xFF1A5276),
                    labelColor: const Color(0xFF1A5276),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedBuilder(
                      animation: _tabs,
                      builder: (_, __) => _tabs.index == 0
                          ? _loginForm()
                          : _registerForm(),
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

  Widget _loginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailLogin,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Obbligatorio' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passLogin,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Obbligatorio' : null,
          ),
          if (_error != null) _errorBox(_error!),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Accedi', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Form(
      key: _regFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameReg,
            decoration: const InputDecoration(
              labelText: 'Username community',
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
            controller: _emailReg,
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
            controller: _passReg,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Obbligatorio';
              if (v.length < 6) return 'Min 6 caratteri';
              return null;
            },
          ),
          if (_error != null) _errorBox(_error!),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Crea account', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}

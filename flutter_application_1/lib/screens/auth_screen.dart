import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/app_state.dart';
import '../widgets/auth/auth_form_card.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isSubmitting = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? _errorMessage;
  UserRole _selectedRole = UserRole.user;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    final appState = context.read<AppState>();

    if (_isLogin) {
      final result = await appState.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (!result.success) {
        setState(() {
          _errorMessage = 'Неверный email или пароль';
          _isSubmitting = false;
        });
        return;
      }

      if (mounted && result.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message!)));
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      return;
    }

    final success = await appState.register(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      _nameCtrl.text.trim(),
      role: _selectedRole,
    );

    if (!success) {
      setState(() {
        _errorMessage = 'Пользователь с таким email уже существует';
        _isSubmitting = false;
      });
      return;
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6FFFA), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: AuthFormCard(
                  isLogin: _isLogin,
                  isSubmitting: _isSubmitting,
                  formKey: _formKey,
                  nameCtrl: _nameCtrl,
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  selectedRole: _selectedRole,
                  onRoleChanged: (role) => setState(() => _selectedRole = role),
                  onSubmit: _submit,
                  onToggleMode: () => setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                  }),
                  errorMessage: _errorMessage,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}

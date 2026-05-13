import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/app_state.dart';

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
    bool success;

    if (_isLogin) {
      success = await appState.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (!success) {
        setState(() {
          _errorMessage = 'Неверный email или пароль';
          _isSubmitting = false;
        });
      }
      return;
    }

    success = await appState.register(
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
      appBar: AppBar(title: Text(_isLogin ? 'Вход' : 'Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isLogin)
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? 'Введите имя' : null,
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (val) => val!.contains('@') ? null : 'Некорректный email',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                validator: (val) => val!.length < 6 ? 'Минимум 6 символов' : null,
              ),
              if (!_isLogin) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Роль', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: UserRole.user, child: Text('Обычный пользователь')),
                    DropdownMenuItem(value: UserRole.admin, child: Text('Администратор')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedRole = value);
                  },
                ),
              ],
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
              ),
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        }),
                child: Text(_isLogin ? 'Нет аккаунта? Зарегистрироваться' : 'Уже есть аккаунт? Войти'),
              )
            ],
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

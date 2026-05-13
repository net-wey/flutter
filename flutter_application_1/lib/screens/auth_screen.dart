import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  String? _errorMessage;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      
      bool success;
      
      if (_isLogin) {
        // Вход
        success = context.read<AppState>().login(
          _emailCtrl.text,
          _passCtrl.text,
        );
        
        if (!success) {
          setState(() {
            _errorMessage = 'Неверный email или пароль';
          });
          return;
        }
      } else {
        // Регистрация
        success = context.read<AppState>().register(
          _emailCtrl.text,
          _passCtrl.text,
          _nameCtrl.text,
        );
        
        if (!success) {
          setState(() {
            _errorMessage = 'Пользователь с таким email уже существует';
          });
          return;
        }
      }
      
      // Успешный вход/регистрация
      Navigator.pushReplacementNamed(context, '/home');
    }
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
                  decoration: const InputDecoration(
                    labelText: 'Имя', 
                    border: OutlineInputBorder()
                  ),
                  validator: (val) => val!.isEmpty ? 'Введите имя' : null,
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email', 
                  border: OutlineInputBorder()
                ),
                validator: (val) => val!.contains('@') ? null : 'Некорректный email',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль', 
                  border: OutlineInputBorder()
                ),
                validator: (val) => val!.length < 6 ? 'Минимум 6 символов' : null,
              ),
              const SizedBox(height: 20),
              
              // Сообщение об ошибке
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _errorMessage = null; // Очищаем ошибку при переключении
                }),
                child: Text(_isLogin 
                  ? 'Нет аккаунта? Зарегистрироваться' 
                  : 'Уже есть аккаунт? Войти'
                ),
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
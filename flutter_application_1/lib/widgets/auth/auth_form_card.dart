import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../common/app_text_field.dart';
import '../common/primary_button.dart';
import '../common/section_card.dart';
import 'role_selector.dart';

class AuthFormCard extends StatelessWidget {
  final bool isLogin;
  final bool isSubmitting;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;
  final String? errorMessage;

  const AuthFormCard({
    super.key,
    required this.isLogin,
    required this.isSubmitting,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onSubmit,
    required this.onToggleMode,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isLogin ? 'С возвращением' : 'Создание аккаунта',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              isLogin ? 'Войди, чтобы управлять товарами на складе' : 'Заполни данные для регистрации',
            ),
            const SizedBox(height: 18),
            if (!isLogin) ...[
              AppTextField(
                controller: nameCtrl,
                label: 'Имя',
                validator: (val) => val!.isEmpty ? 'Введите имя' : null,
              ),
              const SizedBox(height: 10),
            ],
            AppTextField(
              controller: emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val!.contains('@') ? null : 'Некорректный email',
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: passCtrl,
              label: 'Пароль',
              obscureText: true,
              validator: (val) => val!.length < 6 ? 'Минимум 6 символов' : null,
            ),
            if (!isLogin) ...[
              const SizedBox(height: 10),
              RoleSelector(selectedRole: selectedRole, onChanged: onRoleChanged),
            ],
            const SizedBox(height: 14),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            PrimaryButton(
              onPressed: onSubmit,
              isLoading: isSubmitting,
              label: isLogin ? 'Войти' : 'Зарегистрироваться',
              icon: isLogin ? Icons.login : Icons.person_add,
            ),
            TextButton(
              onPressed: isSubmitting ? null : onToggleMode,
              child: Text(isLogin ? 'Нет аккаунта? Регистрация' : 'Уже есть аккаунт? Вход'),
            ),
          ],
        ),
      ),
    );
  }
}

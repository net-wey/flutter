import 'package:flutter/material.dart';

import '../../models/user.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UserRole>(
      initialValue: selectedRole,
      decoration: const InputDecoration(labelText: 'Роль'),
      items: const [
        DropdownMenuItem(value: UserRole.user, child: Text('Обычный пользователь')),
        DropdownMenuItem(value: UserRole.admin, child: Text('Администратор')),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

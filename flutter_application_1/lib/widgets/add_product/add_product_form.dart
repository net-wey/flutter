import 'dart:io';

import 'package:flutter/material.dart';

import '../common/app_text_field.dart';
import '../common/primary_button.dart';
import '../common/section_card.dart';

class AddProductForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final String? selectedImagePath;
  final bool isLoading;
  final VoidCallback onPickImage;
  final VoidCallback onSave;

  const AddProductForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.descCtrl,
    required this.selectedImagePath,
    required this.isLoading,
    required this.onPickImage,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            AppTextField(
              controller: nameCtrl,
              label: 'Название',
              validator: (val) => val!.isEmpty ? 'Заполните поле' : null,
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: descCtrl,
              label: 'Описание',
              validator: (val) => val!.isEmpty ? 'Заполните поле' : null,
            ),
            const SizedBox(height: 12),
            PrimaryButton(onPressed: onPickImage, label: 'Выбрать изображение', icon: Icons.photo_library),
            if (selectedImagePath != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(selectedImagePath!),
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            PrimaryButton(
              onPressed: onSave,
              isLoading: isLoading,
              label: 'Сохранить и сгенерировать QR',
              icon: Icons.qr_code_2,
            ),
          ],
        ),
      ),
    );
  }
}

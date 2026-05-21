import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/add_product/add_product_form.dart';
import '../widgets/add_product/image_picker_sheet.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedImagePath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    await showImagePickerSheet(
      context,
      onCamera: _getImageFromCamera,
      onGallery: _getImageFromGallery,
    );
  }

  Future<void> _getImageFromCamera() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        _showOpenSettingsDialog('камеры');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нужен доступ к камере')));
      }
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  Future<void> _getImageFromGallery() async {
    if (Platform.isAndroid) {
      await _requestAndroidGalleryPermission();
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  Future<void> _requestAndroidGalleryPermission() async {
    final photosStatus = await Permission.photos.request();
    if (photosStatus.isGranted || photosStatus.isLimited) return;

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) return;

    if (photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Полный доступ к фото отключен'),
          action: SnackBarAction(label: 'Настройки', onPressed: openAppSettings),
        ),
      );
    }
  }

  void _showOpenSettingsDialog(String type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Доступ к $type заблокирован'),
        content: const Text('Разрешите доступ в настройках телефона'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Открыть настройки'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, выберите изображение')));
      return;
    }

    setState(() => _isLoading = true);

    await context.read<AppState>().addProduct(
          _nameCtrl.text.trim(),
          _descCtrl.text.trim(),
          _selectedImagePath!,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить товар')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AddProductForm(
          formKey: _formKey,
          nameCtrl: _nameCtrl,
          descCtrl: _descCtrl,
          selectedImagePath: _selectedImagePath,
          isLoading: _isLoading,
          onPickImage: _pickImage,
          onSave: _save,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}

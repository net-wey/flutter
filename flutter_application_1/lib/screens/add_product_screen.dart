import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Сделать фото'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Выбрать из галереи'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
    if (photosStatus.isGranted || photosStatus.isLimited) {
      return;
    }

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите изображение')),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Заполните поле' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Заполните поле' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Выбрать изображение'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
              if (_selectedImagePath != null) ...[
                const SizedBox(height: 20),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Сохранить и сгенерировать QR'),
              ),
            ],
          ),
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

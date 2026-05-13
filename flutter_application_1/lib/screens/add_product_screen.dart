import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../providers/app_state.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedImagePath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Метод для выбора изображения (камера или галерея)
  Future<void> _pickImage() async {
    // Показываем диалог выбора
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

  // Получить фото с камеры
  Future<void> _getImageFromCamera() async {
    // Проверяем разрешение для камеры
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog('камеры');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Нужен доступ к камере')));
      }
      return;
    }

    // Запрашиваем фото
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  // Выбрать из галереи
  Future<void> _getImageFromGallery() async {
    if (Platform.isAndroid) {
      await _requestAndroidGalleryPermission();
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  // Android: пробуем запросить права, но не блокируем системный пикер.
  // На Android 13+ он может работать без выдачи полного разрешения.
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
          action: SnackBarAction(
            label: 'Настройки',
            onPressed: openAppSettings,
          ),
        ),
      );
    }
  }

  void _showOpenSettingsDialog(String type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Доступ к $type заблокирован'),
        content: Text('Разрешите доступ в настройках телефона'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
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

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, выберите изображение')),
        );
        return;
      }

      setState(() => _isLoading = true);

      context.read<AppState>().addProduct(
        _nameCtrl.text,
        _descCtrl.text,
        _selectedImagePath!,
      );

      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
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
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Заполните поле' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Заполните поле' : null,
              ),
              const SizedBox(height: 20),

              // Кнопка выбора изображения (та же самая)
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Выбрать изображение'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              // Превью (без изменений)
              if (_selectedImagePath != null) ...[
                const SizedBox(height: 20),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(
                    File(_selectedImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Кнопка сохранения (без изменений)
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить и сгенерировать QR'),
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

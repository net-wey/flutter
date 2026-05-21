import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/scanner/camera_permission_block.dart';
import '../widgets/scanner/scanner_overlay.dart';
import 'product_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  bool _hasCameraPermission = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      setState(() => _hasCameraPermission = true);
      return;
    }

    setState(() => _hasCameraPermission = false);
    if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog();
    } else {
      _showPermissionDeniedSnackBar();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    String? code;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw != null && raw.isNotEmpty) {
        code = raw;
        break;
      }
    }

    if (code != null) _handleScannedCode(code);
  }

  Future<void> _handleScannedCode(String code) async {
    _isProcessing = true;
    setState(() => _lastScannedCode = code);

    await _scannerController.stop();
    if (!mounted) return;

    final result = await context.read<AppState>().processQrScan(code);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.success && result.product != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: result.product!)),
      );
    }

    _isProcessing = false;
    await _restartScanner();
  }

  Future<void> _restartScanner() async {
    if (!mounted || !_hasCameraPermission) return;
    await _scannerController.start();
  }

  void _showPermissionDeniedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Нужен доступ к камере для сканирования'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(label: 'Настройки', onPressed: () => openAppSettings()),
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Доступ к камере заблокирован'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканер QR')),
      body: _hasCameraPermission
          ? Stack(
              children: [
                MobileScanner(controller: _scannerController, onDetect: _onDetect),
                ScannerOverlay(lastCode: _lastScannedCode),
              ],
            )
          : CameraPermissionBlock(onRequest: _requestCameraPermission),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}

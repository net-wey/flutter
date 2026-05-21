import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/cloud_repository.dart';
import 'firebase_options.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/catalog_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/common/loading_spinner_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState(
    cloudRepositoryLoader: () async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      return CloudRepository(FirebaseFirestore.instance);
    },
  );

  appState.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const WarehouseApp(),
    ),
  );
}

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Складской учет',
      theme: AppTheme.light(),
      home: Consumer<AppState>(
        builder: (context, state, child) {
          if (!state.isInitialized) {
            return LoadingSpinnerView(
              fullscreen: true,
              caption: state.isFirebaseConnecting ? 'Подключение к Firebase...' : 'Загрузка...',
            );
          }
          return state.isAuthenticated ? const CatalogScreen() : const AuthScreen();
        },
      ),
    );
  }
}

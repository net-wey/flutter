import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/cloud_repository.dart';
import 'firebase_options.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/catalog_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CloudRepository? cloudRepository;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    cloudRepository = CloudRepository(FirebaseFirestore.instance);
  } catch (_) {
    cloudRepository = null;
  }

  final appState = AppState(cloudRepository: cloudRepository);
  await appState.init();

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
      title: 'Складской учет',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: Consumer<AppState>(
        builder: (context, state, child) {
          if (!state.isInitialized) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return state.isAuthenticated ? const CatalogScreen() : const AuthScreen();
        },
      ),
    );
  }
}

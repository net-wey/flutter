import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/catalog_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
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
          return state.isAuthenticated ? CatalogScreen() : AuthScreen();
        },
      ),
    );
  }
}

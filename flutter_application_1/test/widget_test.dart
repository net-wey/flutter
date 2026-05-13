import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/providers/app_state.dart';

void main() {
  testWidgets('Auth screen is shown for guest', (WidgetTester tester) async {
    final state = AppState();
    await state.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const WarehouseApp(),
      ),
    );

    expect(find.text('Вход'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
  });
}

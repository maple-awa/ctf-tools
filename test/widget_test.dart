import 'package:ctf_tools/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('CTF Tools 控制台'), findsOneWidget);
    expect(find.text('常用流程'), findsOneWidget);
    expect(find.text('设置'), findsWidgets);
  });
}

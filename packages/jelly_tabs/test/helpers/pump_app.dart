import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestApp extends StatelessWidget {
  const _TestApp(this.child, {this.theme});

  final Widget child;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: Center(child: child)),
    );
  }
}

extension PumpApp on WidgetTester {
  Future<void> pumpAppWidget(
    Widget widget, {
    ThemeData? theme,
  }) async {
    await pumpWidget(_TestApp(widget, theme: theme));
    await pump();
  }
}

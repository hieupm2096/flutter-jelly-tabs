import 'package:example/app/theme/app_theme.dart';
import 'package:example/home/home.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import 'app.dart';

void main() => runApp(const HParkEnforceApp());

class HParkEnforceApp extends StatelessWidget {
  const HParkEnforceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPark Enforce',
      debugShowCheckedModeBanner: false,
      theme: HParkTheme.dark,
      home: const EnforceRoot(),
    );
  }
}

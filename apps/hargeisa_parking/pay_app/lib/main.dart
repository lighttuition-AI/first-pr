import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import 'app.dart';

void main() => runApp(const HParkPayApp());

class HParkPayApp extends StatelessWidget {
  const HParkPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPark Pay',
      debugShowCheckedModeBanner: false,
      theme: HParkTheme.dark,
      home: const PayRoot(),
    );
  }
}

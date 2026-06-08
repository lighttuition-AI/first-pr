import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import 'shell/command_shell.dart';

void main() => runApp(const HParkCommandApp());

class HParkCommandApp extends StatelessWidget {
  const HParkCommandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPark Command',
      debugShowCheckedModeBanner: false,
      theme: HParkTheme.dark,
      home: const CommandShell(),
    );
  }
}

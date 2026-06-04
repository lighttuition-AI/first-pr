import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/gif_service.dart';
import 'services/image_service.dart';
import 'services/vo_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final prefs = await SharedPreferences.getInstance();

  final vo = VoService(prefs);
  final images = ImageService(prefs);
  final gifs = GifService(prefs);
  final app = AppState(prefs);
  final fx = FxController();

  await vo.init();
  await images.init();
  await gifs.init();
  app.vo = vo;
  vo.setEnabled(app.sound);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: app),
        ChangeNotifierProvider.value(value: vo),
        ChangeNotifierProvider.value(value: images),
        ChangeNotifierProvider.value(value: gifs),
        ChangeNotifierProvider.value(value: fx),
      ],
      child: const HnlApp(),
    ),
  );
}

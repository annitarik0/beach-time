import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/ai_service.dart';
import 'services/location_service.dart';
import 'services/open_meteo_service.dart';
import 'services/storage_service.dart';
import 'state/beach_controller.dart';
import 'theme/palette.dart';
import 'theme/typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  final storage = await StorageService.create();
  final controller = BeachController(
    api: OpenMeteoService(),
    storage: storage,
    location: LocationService(),
    ai: AiService(),
  );
  controller.init();
  runApp(ChangeNotifierProvider.value(value: controller, child: const BeachTimeApp()));
}

class BeachTimeApp extends StatelessWidget {
  const BeachTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Palette.sea,
        primary: Palette.sea,
        surface: Palette.paper,
        onSurface: Palette.ink,
      ),
      scaffoldBackgroundColor: Palette.paper,
      splashFactory: InkSparkle.splashFactory,
    );
    return MaterialApp(
      title: 'Beach Time',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.apply(
          fontFamily: AppText.body_,
          bodyColor: Palette.ink,
          displayColor: Palette.ink,
        ),
        iconTheme: const IconThemeData(color: Palette.ink),
      ),
      home: const HomeScreen(),
    );
  }
}

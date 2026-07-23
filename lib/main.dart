import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await AppDependencies.bootstrap();
  runApp(HanziToolApp(deps: deps));
}

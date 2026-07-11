import 'package:flutter/widgets.dart';

import 'app.dart';
import 'services/audio_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioEngine.instance.init();
  runApp(const EarTrainingApp());
}

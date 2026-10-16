import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.instance.initialize();
  runApp(const App());
}

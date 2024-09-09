import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rosedine/auth.dart';
import 'notification_service.dart';
import 'onboarding_screen.dart';

final container = ProviderContainer();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Always load .env file from assets, even for mobile platforms
  await dotenv.load(fileName: "assets/.env");

  if (!kIsWeb) {
    print('Requesting SCHEDULE_EXACT_ALARM permission...');
    await Permission.scheduleExactAlarm.request();
    print('Initializing AndroidAlarmManager...');
    await AndroidAlarmManager.initialize();
  }

  runApp(UncontrolledProviderScope(container: container, child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Scheduling notification service after the first frame...');
      NotificationService.scheduleNotificationService(ref);
    });

    return MaterialApp(
      title: 'RoseDine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFAB8532),
        scaffoldBackgroundColor: Colors.blueGrey[300],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(
          fillColor: const Color(0xFFAB8532),
          selectedBorderColor: const Color(0xFFAB8532),
          selectedColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/auth': (context) => const AuthScreen(),
        '/onboarding': (context) => OnboardingScreen(),
      },
    );
  }
}

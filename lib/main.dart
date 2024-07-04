import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:krp/controllers/quote_controller.dart';
import 'package:krp/services/local_notifications_services.dart';
import 'package:krp/views/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotificationsService.requestPermission();
  await LocalNotificationsService.start();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    LocalNotificationsService.showScheduledNotification();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => QuoteController())
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeScreen(
            currentIndex: 0,
          ),
        );
      },
    );
  }
}

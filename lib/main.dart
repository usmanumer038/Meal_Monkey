import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/locator.dart';
import 'package:food_delivery/view/login/welcome_view.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:food_delivery/view/on_boarding/startup_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common/globs.dart';

SharedPreferences? prefs;

Future<void> _initSupabase() async {
  // Replace with your actual URL and anon key, or keep env-based if you prefer.
  await Supabase.initialize(
    url: 'https://bnjsobwbolnytncquuif.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJuanNvYndib2xueXRuY3F1dWlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5Mzg5MjIsImV4cCI6MjA4MDUxNDkyMn0.IlZjzY-3ZblupQowbyywwFj7_PnIuH5Tnf9Bk5xv2cM',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpLocator();
  await _initSupabase();
  prefs = await SharedPreferences.getInstance();

  if (Globs.udValueBool(Globs.userLogin)) {
    Globs.userPayloadCache = Globs.udValue(Globs.userPayload);
  }

  runApp(const MyApp(defaultHome: StartupView()));
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 5.0
    ..progressColor = TColor.primaryText
    ..backgroundColor = TColor.primary
    ..indicatorColor = Colors.yellow
    ..textColor = TColor.primaryText
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  final Widget defaultHome;
  const MyApp({super.key, this.defaultHome = const StartupView()}); // default provided

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: widget.defaultHome,
      navigatorKey: locator<NavigationService>().navigatorKey,
      builder: (context, child) => FlutterEasyLoading(child: child),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "welcome":
            return MaterialPageRoute(builder: (_) => const WelcomeView());
          case "Home":
            return MaterialPageRoute(builder: (_) => const MainTabView());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text("No path for ${settings.name}")),
              ),
            );
        }
      },
    );
  }
}
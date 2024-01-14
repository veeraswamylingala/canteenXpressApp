import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_order_app/notifiers/cartNotifier.dart';
import 'package:online_food_order_app/views/landingScreen.dart';


import 'notifiers/authNotifier.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CanteeXpress',
      theme: ThemeData(
          fontFamily: 'Montserrat',
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: Color.fromRGBO(255, 63, 111, 1),),
          primaryColor: const Color.fromRGBO(255, 63, 111, 1),
          secondaryHeaderColor: Colors.red),
      home:  LandingPage(),
    );
  }
}

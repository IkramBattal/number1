import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_appointment/constants.dart';
import 'Screens/splash_view.dart';

Future<void> main() async {



  //test
  //test2dbchufiwachtl3lik
  //test3
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: kPrimaryLightdark));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CareMate',
        theme: ThemeData(
            primarySwatch: Colors.indigo,
            appBarTheme: AppBarTheme(color: Color(0xFFFFFFFF))),



        home: SplashView());
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hospital_appointment/constants.dart';
import '../services/shared_preferences_service.dart';
import 'home/patient_home_page.dart';
import 'home/doctor_home_page.dart';
import 'login/loginas.dart';

class SplashView extends StatefulWidget {
  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> {
  final PrefService _prefService = PrefService();

  @override
  void initState() {
    _prefService.readCache("password").then((value) {
      if (value == 2) {
        return Timer(Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => HomePage(),
            ),
                (route) => false,
          );
        });
      } else if (value == 1) {
        return Timer(
          Duration(seconds: 2),
              () => Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => DocHomePage()),
                  (route) => false),
        );
      } else {
        return Timer(Duration(seconds: 2), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => Loginas()));
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Image.asset(
                "assets/images/Splash.png",
                width:500,
                height:500,
              ),
            ),
            Text(
              "CareMate",
              style: TextStyle(
                fontSize: 35,
                color: Color(0xFF4CA6A8),
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
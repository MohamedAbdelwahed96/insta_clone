import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/presentation/screens/login_screen.dart';
import '/presentation/widgets/navigation_bot_bar.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData ()async{
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) return const NavigationBotBar();
          return LoginScreen();
        }),
      )),);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      body: Center(
        child: Image.asset(
            "assets/images/Logo.png",
            width: MediaQuery.of(context).size.width * 0.56,
            color: theme.primary),
      ),
    );
  }
}

import 'package:ezphotoupload/styles.dart';
import 'package:ezphotoupload/ui/screens/home.dart';
import 'package:ezphotoupload/ui/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Futura',
        accentColor: AppColors.accent,
        primaryColor: AppColors.primary,
      ),
      home: StreamBuilder<FirebaseUser>(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (context, snapshot) {
            final user = snapshot.data;

            return user == null ? LoginScreen() : Home();
          }),
    );
  }
}

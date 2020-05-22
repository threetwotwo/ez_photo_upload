import 'package:ezphotoupload/services/auth.dart';
import 'package:ezphotoupload/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      onRecoverPassword: (e) => Auth.recoverPassword(e),
      onLogin: (data) => Auth.loginWithEmail(data.name, data.password),
      onSignup: (data) => Auth.signUpWithEmail(data.name, data.password),
      title: 'EZ Photo',
      theme: LoginTheme(
        primaryColor: AppColors.primary,
      ),
    );
  }
}

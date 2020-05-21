import 'package:ezphotoupload/services.dart';
import 'package:ezphotoupload/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      onRecoverPassword: (e) {},
      onLogin: (data) {
        return Auth.loginWithEmail(data.name, data.password);
      },
      onSignup: (data) {
        final email = data.name;
        final password = data.password;

        print('LoginScreen.build $email');

        return Auth.signUpWithEmail(email, password);
      },
      title: 'EZ Photo',
      theme: LoginTheme(
        primaryColor: AppColors.primary,
      ),
    );
  }
}

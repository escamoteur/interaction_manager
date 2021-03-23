import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class UserCredentials {
  final String userName;
  final String password;

  const UserCredentials({required this.userName, required this.password});
}

class LoginDialogConfig {
  final String? title;
  final String? message;
  final String? userNamePrefill;
  final String userNameLabel;
  final String passwordLabel;
  final String okButtonText;
  final String? cancelButtonText;
  final String? Function(String password)? usernameValidator;
  final String? Function(String password)? passwordValidator;

  LoginDialogConfig({
    this.title,
    this.message,
    required this.userNameLabel,
    required this.passwordLabel,
    required this.okButtonText,
    this.cancelButtonText,
    this.userNamePrefill,
    this.usernameValidator,
    this.passwordValidator,
  });
}

class LoginDialog {
  static const String dialogId = 'Login';
  static Widget build(BuildContext context, LoginDialogConfig? config) =>
      LoginWidget(
        dialogConfig: config!,
      );
}

class LoginWidget extends StatefulWidget {
  final LoginDialogConfig dialogConfig;
  const LoginWidget({Key? key, required this.dialogConfig}) : super(key: key);

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  late TextEditingController userNameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    userNameController =
        TextEditingController(text: widget.dialogConfig.userNamePrefill);
    passwordController = TextEditingController();
    super.initState();
  }

  String? passwordErrorText;
  String? userNameErrorText;

  @override
  Widget build(BuildContext context) {
    final dlgConfig = widget.dialogConfig;

    void onOk() {
      final passwordValidator = dlgConfig.passwordValidator ??
          (s) => s.isEmpty ? 'Password is mandatory!' : null;
      passwordErrorText = passwordValidator(passwordController.text);

      final UserNameValidator = dlgConfig.usernameValidator ??
          (s) => s.isEmpty ? 'User name is mandatory!' : null;
      userNameErrorText = UserNameValidator(userNameController.text);

      if (passwordErrorText != null || userNameErrorText != null) {
        setState(() {});
      } else {
        Navigator.of(context).pop(UserCredentials(
            userName: userNameController.text.trim(),
            password: passwordController.text));
      }
    }

    var content = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (dlgConfig.message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(dlgConfig.message!),
            ),
          Text(dlgConfig.userNameLabel),
          PlatformTextField(
            keyboardType: TextInputType.emailAddress,
            controller: userNameController,
            material: (_, __) => MaterialTextFieldData(
                decoration: InputDecoration(errorText: userNameErrorText)),
          ),
          const SizedBox(height: 16.0),
          Text(dlgConfig.passwordLabel),
          TextField(
            keyboardType: TextInputType.text,
            controller: passwordController,
            decoration: InputDecoration(errorText: passwordErrorText),
            obscureText: true,
            onSubmitted: (_) => onOk(),
          ),
        ],
      ),
    );
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(dlgConfig.title ?? ''),
        content: content,
        actions: <Widget>[
          if (dlgConfig.cancelButtonText != null)
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(dlgConfig.cancelButtonText!),
            ),
          FlatButton(
            onPressed: onOk,
            child: Text(dlgConfig.okButtonText),
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: Text(dlgConfig.title ?? ''),
        content: content,
        actions: <Widget>[
          if (dlgConfig.cancelButtonText != null)
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(dlgConfig.cancelButtonText!),
            ),
          FlatButton(
            onPressed: onOk,
            child: Text(dlgConfig.okButtonText),
          ),
        ],
      );
    }
  }
}

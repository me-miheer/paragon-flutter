import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, String buttonText) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: buttonText,
      onPressed: () {

      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

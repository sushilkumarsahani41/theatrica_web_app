import 'package:flutter/material.dart';

class ButtonAll extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget buttonText;
  const ButtonAll({super.key, this.onPressed, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 3,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      child: buttonText,
    );
  }
}

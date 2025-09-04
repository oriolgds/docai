import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String text;
  final bool isOutlined;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      );
    }
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
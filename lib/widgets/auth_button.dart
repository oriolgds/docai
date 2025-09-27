import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;
  final bool isOutlined;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.isOutlined = false,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(
            color: isDisabled 
                ? Colors.grey.shade300 
                : backgroundColor ?? Colors.black,
          ),
        ),
        child: _buildButtonContent(),
      );
    }
    
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined 
                    ? (textColor ?? Colors.black) 
                    : (textColor ?? Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isOutlined 
                  ? (textColor ?? Colors.black) 
                  : (textColor ?? Colors.white),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon, 
          size: 20,
          color: isOutlined 
              ? (textColor ?? Colors.black) 
              : (textColor ?? Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isOutlined 
                ? (textColor ?? Colors.black) 
                : (textColor ?? Colors.white),
          ),
        ),
      ],
    );
  }
}
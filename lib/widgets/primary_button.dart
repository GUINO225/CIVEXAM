import 'package:flutter/material.dart';

/// A reusable primary button that uses the app's [ElevatedButtonTheme].
///
/// This widget avoids button style duplication across screens.
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const PrimaryButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

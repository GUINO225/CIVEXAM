import 'package:flutter/material.dart';

Future<void> showComingSoonDialog(
  BuildContext context,
  String title, {
  String? message,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message ?? 'Bientôt disponible.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

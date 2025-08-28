import 'package:flutter/material.dart';

import '../widgets/primary_button.dart';

/// Basic home screen derived from design mocks.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: PrimaryButton(
          onPressed: () {},
          child: const Text('Start Quiz'),
        ),
      ),
    );
  }
}

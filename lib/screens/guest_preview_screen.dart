import 'package:flutter/material.dart';

import 'play_screen.dart';

class GuestPreviewScreen extends StatelessWidget {
  const GuestPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlayScreen(guestMode: true);
  }
}

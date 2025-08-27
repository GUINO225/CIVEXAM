// lib/services/design_bus.dart
// Bus de diffusion en temps réel des changements de design.
import 'package:flutter/foundation.dart';
import '../models/design_config.dart';

class DesignBus {
  static final ValueNotifier<DesignConfig> notifier =
      ValueNotifier<DesignConfig>(const DesignConfig());

  static void push(DesignConfig cfg) {
    notifier.value = cfg;
  }
}

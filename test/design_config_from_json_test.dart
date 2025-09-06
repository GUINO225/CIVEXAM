import 'package:flutter_test/flutter_test.dart';
import 'package:civexam_app/models/design_config.dart';

void main() {
  test('fromJson ignores non-bool values', () {
    final cfg = DesignConfig.fromJson({
      'waveEnabled': 'false',
      'bgGradient': 'false',
      'tileCenter': 'false',
      'darkMode': 'true',
      'useMono': 'true',
    });

    expect(cfg.waveEnabled, true);
    expect(cfg.bgGradient, true);
    expect(cfg.tileCenter, true);
    expect(cfg.darkMode, false);
    expect(cfg.useMono, false);
  });
}

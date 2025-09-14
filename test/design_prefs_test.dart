import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civexam_pro/services/design_prefs.dart';
import 'package:civexam_pro/models/design_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load reads tile preferences', () async {
    SharedPreferences.setMockInitialValues({
      'design_tileIconSize': 80.0,
      'design_tileCenter': false,
    });

    final cfg = await DesignPrefs.load();
    expect(cfg.tileIconSize, 80.0);
    expect(cfg.tileCenter, false);
  });

  test('save writes tile preferences', () async {
    SharedPreferences.setMockInitialValues({});
    const cfg = DesignConfig(tileIconSize: 90.0, tileCenter: false);

    await DesignPrefs.save(cfg);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('design_tileIconSize'), 90.0);
    expect(prefs.getBool('design_tileCenter'), false);
  });
}

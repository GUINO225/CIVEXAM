import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:civexam_app/firebase_options.dart';
import 'package:civexam_app/services/auth_service.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  final service = AuthService();

  test('returns message for network-request-failed', () {
    expect(service.messageFromCodeForTest('network-request-failed'),
        'Problème de connexion réseau');
  });

  test('returns message for too-many-requests', () {
    expect(service.messageFromCodeForTest('too-many-requests'),
        'Trop de tentatives, réessayez plus tard');
  });

  test('returns message for operation-not-allowed', () {
    expect(service.messageFromCodeForTest('operation-not-allowed'),
        'Opération non autorisée');
  });

  test('returns message for requires-recent-login', () {
    expect(service.messageFromCodeForTest('requires-recent-login'),
        'Veuillez vous reconnecter pour continuer');
  });

  test('returns message for internal-error with CONFIGURATION_NOT_FOUND', () {
    expect(
        service.messageFromCodeForTest(
            'internal-error', 'Some CONFIGURATION_NOT_FOUND error'),
        'Configuration d’authentification invalide – reCAPTCHA manquant.');
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Exception lancée lors d'un échec de paiement Mobile Money.
class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => 'PaymentException: $message';
}

/// Service de paiement Mobile Money.
///
/// Cette classe fournit une méthode simple pour initier un paiement via
/// une API REST de Mobile Money. L'URL de l'API et la clé d'authentification
/// sont injectées afin que le service puisse être facilement configuré et
/// testé.
class MobileMoneyPaymentService {
  final String apiUrl;
  final String apiKey;
  final http.Client _client;

  MobileMoneyPaymentService({
    required this.apiUrl,
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Lance un paiement Mobile Money.
  ///
  /// Retourne `true` si l'API répond avec un statut `success`.
  Future<bool> makePayment({
    required String phoneNumber,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$apiUrl/payments'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'phoneNumber': phoneNumber,
              'amount': amount,
              'currency': currency,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['status'] is String) {
          return decoded['status'] == 'success';
        }
        throw const FormatException('Réponse JSON invalide');
      }
      return false;
    } on SocketException catch (e) {
      throw PaymentException('Erreur réseau: ${e.message}');
    } on http.ClientException catch (e) {
      throw PaymentException('Erreur HTTP: ${e.message}');
    } on FormatException catch (e) {
      throw PaymentException('Format de réponse invalide: ${e.message}');
    } on TimeoutException {
      throw PaymentException('Délai d\'attente dépassé');
    }
  }

  /// Ferme le client HTTP sous-jacent.
  void dispose() {
    _client.close();
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

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
    final response = await _client.post(
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
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['status'] == 'success';
    }
    return false;
  }
}

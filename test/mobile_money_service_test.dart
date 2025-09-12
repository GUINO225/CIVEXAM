import 'dart:convert';

import 'package:civexam_app/services/mobile_money_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('makePayment returns true on success', () async {
    final service = MobileMoneyPaymentService(
      apiUrl: 'https://example.com',
      apiKey: 'token',
      client: MockClient((request) async {
        expect(request.url.toString(), 'https://example.com/payments');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['phoneNumber'], '0123456789');
        expect(body['amount'], 10.0);
        return http.Response(jsonEncode({'status': 'success'}), 200);
      }),
    );

    final ok = await service.makePayment(
      phoneNumber: '0123456789',
      amount: 10.0,
      currency: 'XOF',
    );

    expect(ok, isTrue);

    service.dispose();
  });

  test('makePayment throws PaymentException on 4xx response', () async {
    final service = MobileMoneyPaymentService(
      apiUrl: 'https://example.com',
      apiKey: 'token',
      client: MockClient((request) async {
        return http.Response('Bad Request', 400);
      }),
    );

    await expectLater(
      service.makePayment(
        phoneNumber: '0123456789',
        amount: 10.0,
        currency: 'XOF',
      ),
      throwsA(
        isA<PaymentException>().having(
          (e) => e.message,
          'message',
          contains('code 400'),
        ),
      ),
    );

    service.dispose();
  });

  test('makePayment throws PaymentException on 5xx response', () async {
    final service = MobileMoneyPaymentService(
      apiUrl: 'https://example.com',
      apiKey: 'token',
      client: MockClient((request) async {
        return http.Response('Server Error', 500);
      }),
    );

    await expectLater(
      service.makePayment(
        phoneNumber: '0123456789',
        amount: 10.0,
        currency: 'XOF',
      ),
      throwsA(
        isA<PaymentException>().having(
          (e) => e.message,
          'message',
          contains('code 500'),
        ),
      ),
    );

    service.dispose();
  });

  test('makePayment throws PaymentException on timeout', () async {
    final service = MobileMoneyPaymentService(
      apiUrl: 'https://example.com',
      apiKey: 'token',
      client: MockClient((request) async {
        await Future.delayed(const Duration(seconds: 10));
        return http.Response(jsonEncode({'status': 'success'}), 200);
      }),
    );

    await expectLater(
      service.makePayment(
        phoneNumber: '0123456789',
        amount: 10.0,
        currency: 'XOF',
      ),
      throwsA(isA<PaymentException>()),
    );

    service.dispose();
  });

  test('makePayment throws PaymentException on invalid JSON', () async {
    final service = MobileMoneyPaymentService(
      apiUrl: 'https://example.com',
      apiKey: 'token',
      client: MockClient((request) async {
        return http.Response('not json', 200);
      }),
    );

    await expectLater(
      service.makePayment(
        phoneNumber: '0123456789',
        amount: 10.0,
        currency: 'XOF',
      ),
      throwsA(isA<PaymentException>()),
    );

    service.dispose();
  });
}

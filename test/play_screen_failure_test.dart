import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civexam_pro/screens/play_screen.dart';

class _MockNavigatorObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
    super.didPop(route, previousRoute);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel firebaseCoreChannel = MethodChannel('plugins.flutter.io/firebase_core');
  const MethodChannel firebaseAuthChannel = MethodChannel('plugins.flutter.io/firebase_auth');

  setUpAll(() async {
    firebaseCoreChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          return <Map<String, Object?>>[];
        case 'Firebase#initializeApp':
          final Map<Object?, Object?> app = methodCall.arguments['app'] as Map<Object?, Object?>;
          return <Map<String, Object?>>[
            <String, Object?>{
              'name': app['name'],
              'options': <String, Object?>{},
              'pluginConstants': <String, Object?>{},
            },
          ];
        case 'Firebase#appNamed':
          final String name = methodCall.arguments['appName'] as String;
          return <String, Object?>{
            'name': name,
            'options': <String, Object?>{},
            'pluginConstants': <String, Object?>{},
          };
        case 'Firebase#apps':
          return <Map<String, Object?>>[];
      }
      return null;
    });

    firebaseAuthChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Auth#initialize':
        case 'Auth#registerIdTokenListener':
        case 'Auth#registerAuthStateListener':
        case 'Auth#signOut':
        case 'Auth#setLanguageCode':
        case 'Auth#useAppLanguage':
        case 'Auth#setSettings':
          return null;
        case 'Auth#currentUser':
          return <String, Object?>{'user': null};
      }
      return null;
    });

    await Firebase.initializeApp();
  });

  tearDown(() {
    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(SystemChannels.assets.name, null);
  });

  testWidgets('shows snackbar and keeps PlayScreen when ENA load fails', (WidgetTester tester) async {
    final BinaryMessenger messenger = ServicesBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(SystemChannels.assets.name, (ByteData? message) async {
      throw Exception('asset-load-failure');
    });

    addTearDown(() {
      messenger.setMockMessageHandler(SystemChannels.assets.name, null);
    });

    final _MockNavigatorObserver observer = _MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: const PlayScreen(),
        navigatorObservers: <NavigatorObserver>[observer],
      ),
    );

    expect(find.byType(PlayScreen), findsOneWidget);

    await tester.tap(find.text('Compétition'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Unable to load question bank'), findsOneWidget);
    expect(observer.popCount, 0);
    expect(find.byType(PlayScreen), findsOneWidget);
  });
}

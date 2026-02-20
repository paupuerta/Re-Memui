import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mem_ui/features/home/presentation/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('should display app title and welcome message',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('ReMem'), findsOneWidget);
      expect(find.text('Welcome to ReMem'), findsOneWidget);
      expect(
        find.text('Your language learning companion'),
        findsOneWidget,
      );
      expect(find.text('Try Demo Review'), findsOneWidget);
    });
  });
}

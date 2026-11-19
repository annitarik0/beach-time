import 'package:beach_time/widgets/score_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ScoreRing counts up to the score', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: ScoreRing(score: 87, color: Colors.teal))),
    ));
    expect(find.text('0'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('87'), findsOneWidget);
    expect(find.text('out of 100'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hacker_news_app/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const HackerNewsApp());
    expect(find.text('Hacker News'), findsOneWidget);
  });
}

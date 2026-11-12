
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_mawar_aprilia_putri_lestari_23053013/main.dart';

void main() {
  testWidgets('RouteFinder app berhasil ditampilkan', (
    WidgetTester tester,
  ) async {
    // Menampilkan aplikasi RouteFinder.
    await tester.pumpWidget(const RouteFinderApp());

    // Memastikan aplikasi berhasil dibuat.
    expect(find.byType(RouteFinderApp), findsOneWidget);
  });
}

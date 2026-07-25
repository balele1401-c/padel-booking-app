import 'package:flutter_test/flutter_test.dart';
import 'package:padel_booking_app/main.dart';

void main() {
  testWidgets('PadelBookingApp smoke test', (WidgetTester tester) async {
    // Verify PadelBookingApp instantiates without throwing errors
    expect(const PadelBookingApp(), isNotNull);
  });
}

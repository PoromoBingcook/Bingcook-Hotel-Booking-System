import 'package:bingcook/app/routes/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('host roles use the staff portal', () {
    expect(usesStaffPortal('Host'), isTrue);
    expect(usesStaffPortal(' host '), isTrue);
    expect(usesStaffPortal('HOST'), isTrue);
  });

  test('customer roles stay in the customer application', () {
    expect(usesStaffPortal('Customer'), isFalse);
    expect(usesStaffPortal(null), isFalse);
  });
}

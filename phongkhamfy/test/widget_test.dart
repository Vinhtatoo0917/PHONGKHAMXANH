// Test cơ bản cho ứng dụng Flutter
import 'package:flutter_test/flutter_test.dart';
import 'package:phongkhamfy/main.dart';

void main() {
  testWidgets('App khởi động thành công', (WidgetTester tester) async {
    // Build ứng dụng và trigger một frame
    await tester.pumpWidget(const UngDungPhongKham());

    // Kiểm tra logo phòng khám có hiển thị
    expect(find.text('PHÒNG KHÁM XANH'), findsOneWidget);
  });
}

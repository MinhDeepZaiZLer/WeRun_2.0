import 'package:dacs4_werun_2_0/presentation/navigation/app_router.dart';
import 'package:dacs4_werun_2_0/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dacs4_werun_2_0/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // ✅ Tạo AuthBloc trước
    final authBloc = AuthBloc(); // nếu bloc của bạn cần repo, truyền repo vào đây
    
    // ✅ Truyền vào AppRouter
    final appRouter = AppRouter(authBloc);

    // ✅ Chạy app
    await tester.pumpWidget(MyApp(appRouter: appRouter));

    // Các bước test mặc định
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

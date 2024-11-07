import 'package:flutter/material.dart';
import 'package:witsy/models/history.dart';
import 'package:witsy/screens/chat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final History history = History(conversations: []);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _getTheme(context, false),
      darkTheme: _getTheme(context, true),
      themeMode: ThemeMode.system,
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: ChatPage(
          title: 'Witsy',
          history: history,
        ),
      ),
    );
  }

  _getTheme(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final Color seedColor = isDark ? Colors.black : Colors.white;
    final Color bgColor = seedColor;
    final Color fgColor = isDark ? Colors.white : Colors.black;
    final int surfaceHighGray = isDark ? 32 : 240;
    final int surfaceLowGray = isDark ? 40 : 225;
    final int onSurfaceGray = isDark ? 255 : 16;

    Color gray(int gray) => Color.fromARGB(255, gray, gray, gray);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor).copyWith(
        surface: bgColor,
        surfaceContainerHigh: gray(surfaceHighGray),
        surfaceContainerLow: gray(surfaceLowGray),
        inverseSurface: fgColor,
        onInverseSurface: bgColor,
        onSurface: gray(onSurfaceGray),
      ),
      appBarTheme: AppBarTheme.of(context).copyWith(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
      ),
      textTheme: theme.textTheme.copyWith(
        bodyMedium: theme.textTheme.bodyMedium?.copyWith(
          color: fgColor,
          fontSize: 16,
        ),
      ),
      useMaterial3: true,
    );
  }
}

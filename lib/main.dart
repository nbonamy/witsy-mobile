import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witsy/models/history.dart';
import 'package:witsy/models/preferences.dart';
import 'package:witsy/screens/chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Preferences>(
          create: (_) => Preferences(),
        ),
        ChangeNotifierProvider<History>(
          create: (_) => History(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: _getTheme(context, false),
        darkTheme: _getTheme(context, true),
        themeMode: ThemeMode.system,
        home: const Directionality(
          textDirection: TextDirection.ltr,
          child: ChatPage(),
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
        primary: Colors.black.withOpacity(0.45),
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

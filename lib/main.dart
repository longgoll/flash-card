import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/database_helper.dart';
import 'features/dashboard/providers/deck_provider.dart';
import 'features/dashboard/pages/dashboard_page.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database early
  await DatabaseHelper.instance.database;

  runApp(const FlashDeskApp());

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1024, 768);
    win.minSize = const Size(800, 600);
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "FlashDesk - Premium Flashcard App";
    win.show();
  });
}

class FlashDeskApp extends StatelessWidget {
  const FlashDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeckProvider()..loadDecks()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'FlashDesk',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: WindowBorder(
                color: themeProvider.isDarkMode
                    ? const Color(0xFF2D2D44)
                    : const Color(0xFFE0E0E0),
                width: 1,
                child: Row(
                  children: [
                    // Placeholder for Side Menu if needed (future expansion)
                    Expanded(
                      child: Column(
                        children: [
                          WindowTitleBarBox(
                            child: Row(
                              children: [
                                Expanded(child: MoveWindow()),
                                WindowButtons(),
                              ],
                            ),
                          ),
                          Expanded(child: DashboardPage()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: windowButtonColors),
        MaximizeWindowButton(colors: windowButtonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

final windowButtonColors = WindowButtonColors(
  iconNormal: const Color(0xFFC0C0C0),
  mouseOver: const Color(0xFF3D3D5C),
  mouseDown: const Color(0xFF2D2D44),
  iconMouseOver: Colors.white,
  iconMouseDown: Colors.white,
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: const Color(0xFFC0C0C0),
  iconMouseOver: Colors.white,
);

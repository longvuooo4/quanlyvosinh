import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../features/club/data/club_repository.dart';
import '../features/club/presentation/club_shell.dart';
import '../features/club/presentation/club_view_model.dart';

class KarateApp extends StatefulWidget {
  const KarateApp({super.key, this.repository});

  final ClubRepository? repository;

  @override
  State<KarateApp> createState() => _KarateAppState();
}

class _KarateAppState extends State<KarateApp> {
  late final ClubViewModel _model;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _model = ClubViewModel(widget.repository ?? LocalClubRepository())..load();
    _router = GoRouter(
      initialLocation: '/overview',
      routes: [
        for (final route in ClubShell.routes)
          GoRoute(
            path: '/$route',
            builder: (_, _) => ClubShell(model: _model, section: route),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Karate Manager',
    debugShowCheckedModeBanner: false,
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xffb3261e),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xfff7f7f9),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff171717),
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xffffdad6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffdedde2)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xffe6e4e9)),
        ),
      ),
    ),
    routerConfig: _router,
  );
}

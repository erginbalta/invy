import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../features/onboarding/screens/onboarding_screen.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';
import 'inventory_controller.dart';

class InvyApp extends StatelessWidget {
  const InvyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryController()..initialize(),
      child: Consumer<InventoryController>(
        builder: (context, controller, _) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: controller.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale?.languageCode == 'tr') return const Locale('tr');
              return const Locale('en');
            },
            home: const AppGate(),
          );
        },
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!controller.setup.isComplete) {
          return const OnboardingScreen();
        }

        return const AppShell();
      },
    );
  }
}

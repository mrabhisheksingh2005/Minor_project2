import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'core/services/history_service.dart';
import 'core/services/prediction_service.dart';

import 'features/profile/providers/app_provider.dart';
import 'features/history/providers/history_provider.dart';
import 'features/scan/providers/scan_provider.dart';
import 'features/assistant/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final HistoryService historyService = HistoryService(sharedPreferences);
  final DiseasePredictionService predictionService = TFLitePredictionService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(
          create: (context) => AppProvider(sharedPreferences),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (context) => HistoryProvider(historyService),
        ),
        ChangeNotifierProvider<ScanProvider>(
          create: (context) => ScanProvider(predictionService),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
        ),
      ],
      child: const AgriVisionApp(),
    ),
  );
}

class AgriVisionApp extends StatelessWidget {
  const AgriVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final router = AppRouter.getRouter(appProvider);

    return MaterialApp.router(
      title: 'AgriVision AI',
      debugShowCheckedModeBanner: false,
      themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

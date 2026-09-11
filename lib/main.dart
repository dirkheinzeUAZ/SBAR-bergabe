import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'screens/bed_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();
  runApp(SbarUebergabeApp(storageService: storageService));
}

class SbarUebergabeApp extends StatelessWidget {
  final StorageService storageService;

  const SbarUebergabeApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SBAR Übergabe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: BedListScreen(storageService: storageService),
    );
  }
}

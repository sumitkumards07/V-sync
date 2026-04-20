import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/services/service_layer.dart';
import 'package:vsync/core/router/router.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/services/campus_supabase.dart';
import 'package:vsync/core/utils/general_utils.dart';
import 'package:vsync/core/widgets/app_backdrop.dart';
import 'package:vsync/features/background/controller.dart';
import 'package:vsync/features/background/sync.dart';
import 'package:vsync/services/update_service.dart';
import 'package:vsync/src/api/vtop/vtop_errors.dart';
import 'package:vsync/src/frb_generated.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make content go edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  Workmanager().initialize(callbackDispatcher);
  await RustLib.init();
  await CampusSupabase.initialize();
  final services = await AppServices.create();
  FlutterError.onError = (details) {
    services.logger.error(
      'flutter',
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    services.logger.error(
      'platform',
      error.toString(),
      error: error,
      stackTrace: stack,
    );
    if (error is VtopError) {
      return true;
    }
    return false;
  };
  fileDownloaderConfig();
  runApp(
    ProviderScope(
      overrides: [
        appServicesProvider.overrideWith((ref) async => services),
        appLoggerProvider.overrideWith((ref) async => services.logger),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);
    useEffect(() {
      Future(() async {
        ref.read(backgroundSyncProvider);
        await Future.delayed(Duration(milliseconds: 500));

        UpdateService.checkForFlexibleUpdate();
      });
      return null;
    }, []);

    final fTheme = ref.watch(fThemeProvider);
    final materialTheme = ref.watch(materialThemeProvider);

    return MaterialApp.router(
      theme: materialTheme,
      routeInformationProvider: goRouter.routeInformationProvider,
      routeInformationParser: goRouter.routeInformationParser,
      routerDelegate: goRouter.routerDelegate,
      builder: (context, child) => AppBackdrop(
        child: FTheme(
          data: fTheme,
          child: FToaster(child: child!),
        ),
      ),
    );
  }
}

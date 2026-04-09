import "dart:async";
import "dart:isolate";
import "dart:ui";

import "package:dsp_base/advertisements.dart";
import "package:dsp_base/app_localize.dart";
import "package:dsp_base/convenience_imports.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:get/get.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

class CommApp extends StatefulWidget {
  const CommApp({
    super.key,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.title = "",
    this.onGenerateTitle,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.customTransition,
    this.color,
    this.translationsKeys,
    this.translations,
    this.textDirection,
    this.locale,
    this.fallbackLocale = const Locale("en", "US"),
    this.localizationsDelegates = const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = CommLocalize.supportedLocales,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.scrollBehavior,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.actions,
    this.debugShowMaterialGrid = false,
    this.routingCallback,
    this.defaultTransition,
    this.opaqueRoute,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.enableLog,
    this.logWriterCallback,
    this.popGesture,
    this.smartManagement = SmartManagement.full,
    this.initialBinding,
    this.transitionDuration,
    this.defaultGlobalState,
    this.getPages,
    this.unknownRoute,
    this.useInheritedMediaQuery = false,
    this.designSize = const Size(360, 800),
  });

  // Default params for GetMaterialApp
  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final RouteFactory? onUnknownRoute;
  final List<NavigatorObserver> navigatorObservers;
  final TransitionBuilder? builder;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final CustomTransition? customTransition;
  final Color? color;
  final Map<String, Map<String, String>>? translationsKeys;
  final Translations? translations;
  final TextDirection? textDirection;
  final Locale? locale;
  final Locale? fallbackLocale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<LogicalKeySet, Intent>? shortcuts;
  final ScrollBehavior? scrollBehavior;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;
  final Map<Type, Action<Intent>>? actions;
  final bool debugShowMaterialGrid;
  final ValueChanged<Routing?>? routingCallback;
  final Transition? defaultTransition;
  final bool? opaqueRoute;
  final VoidCallback? onInit;
  final VoidCallback? onReady;
  final VoidCallback? onDispose;
  final bool? enableLog;
  final LogWriterCallback? logWriterCallback;
  final bool? popGesture;
  final SmartManagement smartManagement;
  final Bindings? initialBinding;
  final Duration? transitionDuration;
  final bool? defaultGlobalState;
  final List<GetPage<dynamic>>? getPages;
  final GetPage<dynamic>? unknownRoute;
  final bool useInheritedMediaQuery;

  // Custom params for CommApp
  final Size designSize;

  static int lastVersionCode = 0;
  static int startupTimeInSeconds = MixedUtils.currentTimeSeconds();
  static int foregroundTimeInSeconds = MixedUtils.currentTimeSeconds();

  @override
  State<CommApp> createState() => _CommAppState();
}

class _CommAppState extends State<CommApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);

    if (locales != null && locales.isNotEmpty) {
      CommLocalize.deviceChangeLocale(locales.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.3,
        );

        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: scale),
          child: GetMaterialApp(
            navigatorKey: widget.navigatorKey,
            scaffoldMessengerKey: widget.scaffoldMessengerKey,
            home: widget.home,
            routes: widget.routes,
            initialRoute: widget.initialRoute,
            onGenerateRoute: widget.onGenerateRoute,
            onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
            onUnknownRoute: widget.onUnknownRoute,
            navigatorObservers: widget.navigatorObservers,
            builder: widget.builder,
            title: widget.title,
            onGenerateTitle: widget.onGenerateTitle,
            theme: widget.theme,
            darkTheme: widget.darkTheme,
            themeMode: widget.themeMode,
            customTransition: widget.customTransition,
            color: widget.color,
            translationsKeys: widget.translationsKeys,
            translations: widget.translations,
            textDirection: widget.textDirection,
            locale: widget.locale,
            fallbackLocale: widget.fallbackLocale,
            localizationsDelegates: widget.localizationsDelegates,
            localeListResolutionCallback: widget.localeListResolutionCallback,
            localeResolutionCallback: widget.localeResolutionCallback,
            supportedLocales: widget.supportedLocales,
            showPerformanceOverlay: widget.showPerformanceOverlay,
            checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
            showSemanticsDebugger: widget.showSemanticsDebugger,
            debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
            shortcuts: widget.shortcuts,
            scrollBehavior: widget.scrollBehavior,
            highContrastTheme: widget.highContrastTheme,
            highContrastDarkTheme: widget.highContrastDarkTheme,
            actions: widget.actions,
            debugShowMaterialGrid: widget.debugShowMaterialGrid,
            routingCallback: widget.routingCallback,
            defaultTransition: widget.defaultTransition,
            opaqueRoute: widget.opaqueRoute,
            onInit: widget.onInit,
            onReady: widget.onReady,
            onDispose: widget.onDispose,
            enableLog: widget.enableLog,
            logWriterCallback: widget.logWriterCallback,
            popGesture: widget.popGesture,
            smartManagement: widget.smartManagement,
            initialBinding: widget.initialBinding,
            transitionDuration: widget.transitionDuration,
            defaultGlobalState: widget.defaultGlobalState,
            getPages: widget.getPages,
            unknownRoute: widget.unknownRoute,
            // routeInformationProvider: widget.routeInformationProvider,
            // routeInformationParser: widget.routeInformationParser,
            // routerDelegate: widget.routerDelegate,
            // backButtonDispatcher: widget.backButtonDispatcher,
            useInheritedMediaQuery: widget.useInheritedMediaQuery,
          ),
        );
      },
    );
  }
}

/// Khá»Ÿi cháº¡y app. Sá»­ dá»¥ng thay tháº¿ cho `runApp()` máº·c Ä‘á»‹nh cá»§a Flutter.
///
///
/// CÃ¡c tham sá»‘:
///
/// * `app`: LÃ  `Widget` hoáº·c `Widget Function()`. Táº¡i sao láº¡i cÃ³ 2 trÆ°á»ng hÆ¡p nÃ y?
///     - Náº¿u truyá»n vÃ o `Widget` luÃ´n thÃ¬ tá»©c lÃ  báº¡n Ä‘Ã£ khá»Ÿi táº¡o `Widget` trÆ°á»›c khi cháº¡y `commRunApp`.
///     - Náº¿u truyá»n vÃ o `() => Widget` thÃ¬ tá»©c lÃ  báº¡n chÆ°a khá»Ÿi táº¡o Widget Ä‘Ã³ ngay. Widget Ä‘Ã³ sáº½ Ä‘Æ°á»£c khá»Ÿi táº¡o bÃªn trong commRunApp sau nhá»¯ng logic riÃªng cá»§a commRunApp. Äiá»u nÃ y cÃ³ lá»£i Ã­ch trong 1 sá»‘ trÆ°á»ng há»£p, vÃ­ dá»¥ nhÆ° báº¡n muá»‘n khá»Ÿi táº¡o 1 vÃ i viewmodel hoáº·c controller trÆ°á»›c khi Wigdet chÃ­nh Ä‘Æ°á»£c khá»Ÿi táº¡o Ä‘á»ƒ trÃ¡nh 1 sá»‘ lá»—i liÃªn quan Ä‘áº¿n viá»‡c khá»Ÿi táº¡o Widget quÃ¡ sá»›m.
///
///
/// * `onBindingInitialized` (Optional): HÃ m async Ä‘Æ°á»£c gá»i sau khi `WidgetsBinding` Ä‘Ã£ Ä‘Æ°á»£c khá»Ÿi táº¡o. ThÆ°á»ng dÃ¹ng Ä‘á»ƒ cháº¡y cÃ¡c logic khá»Ÿi táº¡o cáº§n thiáº¿t trÆ°á»›c khi app chÃ­nh thá»©c cháº¡y.
Future<void> commRunApp(
  Object app, {
  Future<void> Function(WidgetsBinding widgetsBinding)? onBindingInitialized,
}) async {
  if (app is! Widget && app is! Widget Function()) {
    // Chá»‰ cháº¥p nháº­n Widget hoáº·c () => Widget lÃ m tham sá»‘ app
    // Náº¿u truyá»n vÃ o Widget luÃ´n thÃ¬ tá»«c lÃ  báº¡n Ä‘Ã£ khá»Ÿi táº¡o Widget trÆ°á»›c khi cháº¡y commRunApp
    // Náº¿u truyá»n vÃ o () => Widget thÃ¬ tá»©c lÃ  báº¡n chÆ°a khá»Ÿi táº¡o Widget Ä‘Ã³ ngay. Widget Ä‘Ã³ sáº½ Ä‘Æ°á»£c khá»Ÿi táº¡o bÃªn trong commRunApp sau nhá»¯ng logic riÃªng cá»§a commRunApp
    // Äiá»u nÃ y cÃ³ lá»£i Ã­ch trong 1 sá»‘ trÆ°á»ng há»£p, vÃ­ dá»¥ nhÆ° báº¡n muá»‘n khá»Ÿi táº¡o 1 vÃ i viewmodel hoáº·c controller trÆ°á»›c khi Wigdet chÃ­nh chá»©a app cá»§a báº¡n Ä‘Æ°á»£c khá»Ÿi táº¡o. Náº¿u truyá»n luÃ´n
    throw ArgumentError("commRunApp only accepts a Widget or () => Widget as app parameter");
  }

  commCrashOnAnyErrorInDev();

  runZonedGuarded(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

      // initialize things
      await PrefAssist.init();
      await CommLocalize.loadTranslations("packages/dsp_base/lib/xml_strings", "strings.xml");

      // Classify device based on RAM memory
      await CommFigs.classifyDevice();

      await onBindingInitialized?.call(widgetsBinding);

      CommApp.lastVersionCode = PrefAssist.getInt(PrefComm.PREF_LAST_VERSION_CODE);
      final currentVersionCode = await MixedUtils.currentVersionCode();
      if (currentVersionCode > 0 && currentVersionCode != CommApp.lastVersionCode) {
        PrefAssist.setInt(PrefComm.PREF_LAST_VERSION_CODE, currentVersionCode);
      }

      AdvertsConfig.clearLastTimeShowedFullAd();

      if (CommFigs.IS_ADD_TEST_DEVICE) {
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: [await AdvertsConfig.instance.getAdMobDeviceAndroidId()],
          ),
        );
      }

      // Initialize Crashlytics
      if (Firebase.apps.isNotEmpty) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
        Isolate.current.addErrorListener(
          RawReceivePort((pair) async {
            final List<dynamic> errorAndStacktrace = pair;
            await FirebaseCrashlytics.instance.recordError(
              errorAndStacktrace.first,
              errorAndStacktrace.last,
              fatal: true,
            );
          }).sendPort,
        );
      }

      if (!CommFigs.IS_PRODUCT) {
        AdvertsConfig.instance.isHideAd = PrefAssist.getBoolean(PrefComm.IS_HIDE_AD_DEBUG);
      }

      final Widget widgetApp;
      if (app is Widget) {
        widgetApp = app;
      } else {
        widgetApp = (app as Widget Function())();
      }

      runApp(widgetApp);
    },
    (error, stack) {
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        CommLogger.saveToSessionLog("P", line);
        parent.print(zone, line);
      },
    ),
  );
}

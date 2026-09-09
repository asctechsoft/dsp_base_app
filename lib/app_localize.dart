import "package:dsp_base/convenience_imports.dart";
import "package:dsp_base/type_utils/pair.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart" show rootBundle;
import "package:get/get.dart";
import "package:xml/xml.dart";

class CommLocalize {
  static final List<Pair<String, String>> _cachedLocaleFiles = [];

  static Future<void> setAppLocale(Locale locale) async {
    // Save the locale
    await PrefAssist.setString(PrefComm.CONFIGURED_LOCALE_BY_USER, locale.toString());

    for (final pair in _cachedLocaleFiles.toList()) {
      await CommLocalize.loadTranslations(pair.key, pair.value, isChangeLocale: true);
    }
    // NOT Get.updateLocale(locale): that calls forceAppUpdate(), which does a full
    // engine reassemble and remounts GetMaterialApp from its initialRoute — the
    // navigator stack is lost and the app lands back on the splash screen.
    // Setting Get.locale + appUpdate() rebuilds GetMaterialApp's own root builder
    // in place (same Element, same Navigator State), refreshing every `.tr` string
    // without touching the route stack.
    Get.locale = locale;
    Get.appUpdate();
  }

  static Future<void> deviceChangeLocale(Locale locale) async {
    for (final pair in _cachedLocaleFiles.toList()) {
      await CommLocalize.loadTranslations(pair.key, pair.value, isChangeLocale: true);
    }
    Get.locale = locale;
    Get.appUpdate();
  }

  static Locale? getConfiguredLocale() {
    final savedLocale = PrefAssist.getString(PrefComm.CONFIGURED_LOCALE_BY_USER, defaultValue: "");

    if (savedLocale.isEmpty) return null;
    if (savedLocale.contains("_")) {
      final localeParts = savedLocale.split("_");
      if (localeParts.length == 2) {
        final languageCode = localeParts[0];
        final countryCode = localeParts[1];
        return Locale(languageCode, countryCode);
      }
    } else {
      return Locale(savedLocale);
    }
    return null;
  }

  /// Get the actual system locale from the platform
  /// This is more reliable than Get.deviceLocale which may return incorrect values on some devices (e.g., Honor devices)
  static Locale? getSystemLocale() {
    try {
      // Try to get locale from WidgetsBinding first (most reliable - gets actual system locale)
      if (WidgetsBinding.instance.platformDispatcher.locales.isNotEmpty) {
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locales.first;
        debugPrint(
          "[CommLocalize] System locales from platform: ${WidgetsBinding.instance.platformDispatcher.locales}",
        );
        debugPrint("[CommLocalize] System locale from platform: $systemLocale");
        return systemLocale;
      }
    } catch (e, stack) {
      debugPrint("[CommLocalize] Could not get locale from WidgetsBinding: $e\n$stack");
      commCrashOnTry(e, stack, hint: "getSystemLocale");
    }

    // Fallback to Get.deviceLocale if WidgetsBinding is not available
    // Note: This may still return incorrect values on some devices, but it's better than nothing
    final fallbackLocale = Get.deviceLocale;
    debugPrint("[CommLocalize] Using fallback locale: $fallbackLocale");
    return fallbackLocale;
  }

  static Locale getAppLocale() {
    final configuredLocale = getConfiguredLocale();
    final getLocale = Get.locale;
    final systemLocale = getSystemLocale();
    const defaultLocale = Locale("en", "US");

    debugPrint("[CommLocalize] app locale - Configured locale: $configuredLocale");
    debugPrint("[CommLocalize] app locale - Get.locale: $getLocale");
    debugPrint("[CommLocalize] app locale - System locale: $systemLocale");
    debugPrint("[CommLocalize] app locale - Default locale: $defaultLocale");

    return configuredLocale ?? getLocale ?? systemLocale ?? defaultLocale;
  }

  static Future<Map<String, String>> _loadXml(
    String path, {
    bool isChangeLocale = false,
  }) async {
    final xmlString = await rootBundle.loadString(path);
    final document = XmlDocument.parse(xmlString);
    final translations = <String, String>{};
    for (final node in document.findAllElements("string")) {
      final key = node.getAttribute("name");
      if (!isChangeLocale && CommFigs.IS_DEBUG && key != null && translations.containsKey(key)) {
        throw Exception("Duplicated key: $key");
      }
      final value = node.innerText
          .replaceAll('\\"', '"')
          .replaceAll("\\'", "'")
          .replaceAll(r"\r\n", "\n")
          .replaceAll(r"\n", "\n")
          .replaceAll(r"\t", "\t")
          .replaceAll("%1\$s", "@args1")
          .replaceAll("%2\$s", "@args2")
          .replaceAll("%3\$s", "@args3")
          .replaceAll("%4\$s", "@args4")
          .replaceAll("%5\$s", "@args5")
          .replaceAll("%6\$s", "@args6")
          .replaceAll("%7\$s", "@args7")
          .replaceAll("%8\$s", "@args8");
      if (key != null) {
        translations[key] = value;
      }
    }
    return translations;
  }

  static String getLocaleName(Locale locale) {
    switch (locale.toString()) {
      case "en_US":
        return "English (United States)";
      case "vi_VN":
        return "Vietnamese (Vietnam)";
      case "fr_FR":
        return "French (France)";
      case "it_IT":
        return "Italian (Italy)";
      case "de_DE":
        return "German (Germany)";
      case "es_ES":
        return "Spanish (Spain)";
      case "ru_RU":
        return "Russian (Russia)";
      case "pt_PT":
        return "Portuguese (Portugal)";
      case "tr_TR":
        return "Turkish (Turkey)";
      case "ar_SA":
        return "Arabic (Saudi Arabia)";
      case "id_ID":
        return "Indonesian (Indonesia)";
      case "fa_IR":
        return "Persian (Iran)";
      case "zh_CN":
        return "Chinese (Simplified)";
      case "zh_TW":
        return "Chinese (Traditional)";
      case "ja_JP":
        return "Japanese (Japan)";
      case "ko_KR":
        return "Korean (South Korea)";
    }

    switch (locale.languageCode) {
      case "en":
        return "English (United States)";
      case "vi":
        return "Vietnamese (Vietnam)";
      case "fr":
        return "French (France)";
      case "it":
        return "Italian (Italy)";
      case "de":
        return "German (Germany)";
      case "es":
        return "Spanish (Spain)";
      case "ru":
        return "Russian (Russia)";
      case "pt":
        return "Portuguese (Portugal)";
      case "tr":
        return "Turkish (Turkey)";
      case "ar":
        return "Arabic (Saudi Arabia)";
      case "id":
        return "Indonesian (Indonesia)";
      case "fa":
        return "Persian (Iran)";
      case "zh":
        return "Chinese (Simplified)";
      case "ja":
        return "Japanese (Japan)";
      case "ko":
        return "Korean (South Korea)";
    }

    if (CommFigs.IS_DEBUG) {
      throw Exception("Locale not found $locale");
    } else {
      return locale.toString();
    }
  }

  /// Locales offered when [CommFigs.IS_MULTI_LANGUAGE] is `false`.
  /// Only English and Vietnamese are shown in this mode.
  static const _enViSupportedLocales = <Locale>[
    Locale("en", "US"), // English (United States)
    Locale("vi", "VN"), // Vietnamese (Vietnam)
  ];

  /// The locales the app actually offers.
  ///
  /// - When [CommFigs.IS_MULTI_LANGUAGE] is `true`  -> full multi-language list.
  /// - When [CommFigs.IS_MULTI_LANGUAGE] is `false` -> English + Vietnamese only.
  static const List<Locale> supportedLocales = CommFigs.IS_MULTI_LANGUAGE
      ? _allSupportedLocales
      : _enViSupportedLocales;

  /// Full multi-language locale list (used when [CommFigs.IS_MULTI_LANGUAGE] is `true`).
  static const _allSupportedLocales = <Locale>[
    Locale("en", "US"), // English (United States)
    Locale("vi", "VN"), // Vietnamese (Vietnam)
    Locale("fr", "FR"), // French (France)
    Locale("it", "IT"), // Italian (Italy)
    Locale("de", "DE"), // German (Germany)
    Locale("es", "ES"), // Spanish (Spain)
    Locale("ru", "RU"), // Russian (Russia)
    Locale("pt", "PT"), // Portuguese (Portugal)
    Locale("tr", "TR"), // Turkish (Turkey)
    Locale("ar", "SA"), // Arabic (Saudi Arabia)
    Locale("id", "ID"), // Indonesian (Indonesia)
    Locale("fa", "IR"), // Persian (Iran)
    Locale("zh", "CN"), // Chinese (Simplified)
    Locale("zh", "TW"), // Chinese (Traditional)
    Locale("ja", "JP"), // Japanese (Japan)
    Locale("ko", "KR"), // Korean (South Korea)
  ];

  static String _getFilePath(String root, Locale locale, String fileName) {
    switch (locale.toString()) {
      case "ar_SA":
        return "$root/values-ar/$fileName";
      case "de_DE":
        return "$root/values-de/$fileName";
      case "es_ES":
        return "$root/values-es/$fileName";
      case "fa_IR":
        return "$root/values-fa/$fileName";
      case "fr_FR":
        return "$root/values-fr/$fileName";
      case "id_ID":
        return "$root/values-id/$fileName";
      case "it_IT":
        return "$root/values-it/$fileName";
      case "ja_JP":
        return "$root/values-ja/$fileName";
      case "ko_KR":
        return "$root/values-ko/$fileName";
      case "pt_PT":
        return "$root/values-pt/$fileName";
      case "ru_RU":
        return "$root/values-ru/$fileName";
      case "tr_TR":
        return "$root/values-tr/$fileName";
      case "vi_VN":
        return "$root/values-vi/$fileName";
      case "zh_CN":
        return "$root/values-zh-rCN/$fileName";
      case "zh_TW":
        return "$root/values-zh-rTW/$fileName";
    }

    switch (locale.languageCode) {
      case "en":
        return "$root/values/$fileName";
      case "ar":
        return "$root/values-ar/$fileName";
      case "de":
        return "$root/values-de/$fileName";
      case "es":
        return "$root/values-es/$fileName";
      case "fa":
        return "$root/values-fa/$fileName";
      case "fr":
        return "$root/values-fr/$fileName";
      case "id":
        return "$root/values-id/$fileName";
      case "it":
        return "$root/values-it/$fileName";
      case "ja":
        return "$root/values-ja/$fileName";
      case "ko":
        return "$root/values-ko/$fileName";
      case "pt":
        return "$root/values-pt/$fileName";
      case "ru":
        return "$root/values-ru/$fileName";
      case "tr":
        return "$root/values-tr/$fileName";
      case "vi":
        return "$root/values-vi/$fileName";
      case "zh":
        return "$root/values-zh-rCN/$fileName";
    }

    return "$root/values/$fileName";
  }

  static Map<String, Map<String, String>> _translations = {};

  static Future<void> loadTranslations(
    String root,
    String fileName, {
    bool isChangeLocale = false,
  }) async {
    if (!_cachedLocaleFiles.any(
      (pair) => pair.key == root && pair.value == fileName,
    )) {
      _cachedLocaleFiles.add(Pair<String, String>(root, fileName));
    }

    final currentTranslations = Map<String, Map<String, String>>.from(
      _translations,
    );

    // Use getSystemLocale() instead of Get.deviceLocale for more reliable device locale detection
    final deviceLanguageCode = getSystemLocale()?.languageCode ?? "";
    final appLanguageCode = getAppLocale().languageCode;

    // Get.clearTranslations();
    for (final locale in CommLocalize.supportedLocales) {
      final localeName = locale.toString();
      final localeLanguageCode = locale.languageCode;
      if ((localeLanguageCode != "en_US") &&
          (localeLanguageCode != deviceLanguageCode && localeLanguageCode != appLanguageCode)) {
        continue;
      }
      debugPrint("localeName: $localeName");
      debugPrint("root: $root");
      debugPrint("fileName: $fileName");
      debugPrint("localeLanguageCode: $localeLanguageCode");
      debugPrint("deviceLanguageCode: $deviceLanguageCode");
      debugPrint("appLanguageCode: $appLanguageCode");
      debugPrint("Loading translations ... $localeName $root $fileName");

      try {
        final mapLocalized = await _loadXml(
          _getFilePath(root, locale, fileName),
          isChangeLocale: isChangeLocale,
        );

        if (!currentTranslations.containsKey(localeName)) {
          currentTranslations[localeName] = mapLocalized;
        } else {
          if (CommFigs.IS_DEBUG && !isChangeLocale) {
            final mapCached = currentTranslations[localeName]!;
            for (final key in mapCached.keys) {
              if (mapLocalized.containsKey(key)) {
                throw Exception("Duplicated key: $key");
              }
            }
          }
          currentTranslations[localeName] = {
            ...currentTranslations[localeName]!,
            ...mapLocalized,
          };
        }
      } catch (e, stack) {
        commCrashOnTry(e, stack, hint: 'Error loading translations for "$localeName" from "$root": $e\n$stack');
      }
    }

    _translations = Map<String, Map<String, String>>.from(currentTranslations);

    Get.addTranslations(_translations);
  }
}

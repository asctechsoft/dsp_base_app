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
    await Get.updateLocale(locale);
  }

  static Future<void> deviceChangeLocale(Locale locale) async {
    for (final pair in _cachedLocaleFiles.toList()) {
      await CommLocalize.loadTranslations(pair.key, pair.value, isChangeLocale: true);
    }
    await Get.updateLocale(locale);
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
      case "ar_SA":
        return "Arabic (Saudi Arabia)";
      case "af_ZA":
        return "Afrikaans (South Africa)";
      case "am_ET":
        return "Amharic (Ethiopia)";
      case "az_AZ":
        return "Azerbaijani (Azerbaijan)";
      case "be_BY":
        return "Belarusian (Belarus)";
      case "bg_BG":
        return "Bulgarian (Bulgaria)";
      case "bn_BD":
        return "Bengali (Bangladesh)";
      case "ca_ES":
        return "Catalan (Spain)";
      case "cs_CZ":
        return "Czech (Czech Republic)";
      case "da_DK":
        return "Danish (Denmark)";
      case "de_DE":
        return "German (Germany)";
      case "el_GR":
        return "Greek (Greece)";
      case "en_GB":
        return "English (United Kingdom)";
      case "en_CA":
        return "English (Canada)";
      case "en_AU":
        return "English (Australia)";
      case "es_BR":
        return "Spanish (Brazil)";
      case "es_ES":
        return "Spanish (Spain)";
      case "es_US":
        return "Spanish (United States)";
      case "et_EE":
        return "Estonian (Estonia)";
      case "eu_ES":
        return "Basque (Spain)";
      case "fa_IR":
        return "Persian (Iran)";
      case "fi_FI":
        return "Finnish (Finland)";
      case "fil_PH":
        return "Filipino (Philippines)";
      case "fr_FR":
        return "French (France)";
      case "fr_CA":
        return "French (Canada)";
      case "gl_ES":
        return "Galician (Spain)";
      case "gu_IN":
        return "Gujarati (India)";
      case "he_IL":
        return "Hebrew (Israel)";
      case "hi_IN":
        return "Hindi (India)";
      case "hr_HR":
        return "Croatian (Croatia)";
      case "hu_HU":
        return "Hungarian (Hungary)";
      case "hy_AM":
        return "Armenian (Armenia)";
      case "id_ID":
        return "Indonesian (Indonesia)";
      case "is_IS":
        return "Icelandic (Iceland)";
      case "it_IT":
        return "Italian (Italy)";
      case "ja_JP":
        return "Japanese (Japan)";
      case "ka_GE":
        return "Georgian (Georgia)";
      case "kk_KZ":
        return "Kazakh (Kazakhstan)";
      case "km_KH":
        return "Khmer (Cambodia)";
      case "kn_IN":
        return "Kannada (India)";
      case "ko_KR":
        return "Korean (South Korea)";
      case "ku_TR":
        return "Kurdish (Turkey)";
      case "ky_KG":
        return "Kyrgyz (Kyrgyzstan)";
      case "lo_LA":
        return "Lao (Laos)";
      case "lt_LT":
        return "Lithuanian (Lithuania)";
      case "lv_LV":
        return "Latvian (Latvia)";
      case "mk_MK":
        return "Macedonian (North Macedonia)";
      case "ml_IN":
        return "Malayalam (India)";
      case "mn_MN":
        return "Mongolian (Mongolia)";
      case "mr_IN":
        return "Marathi (India)";
      case "ms_MY":
        return "Malay (Malaysia)";
      case "my_MM":
        return "Burmese (Myanmar)";
      case "nb_NO":
        return "Norwegian BokmÃ¥l (Norway)";
      case "ne_NP":
        return "Nepali (Nepal)";
      case "nl_NL":
        return "Dutch (Netherlands)";
      case "no_NO":
        return "Norwegian (Norway)";
      case "pa_IN":
        return "Punjabi (India)";
      case "pl_PL":
        return "Polish (Poland)";
      case "pt_BR":
        return "Portuguese (Brazil)";
      case "pt_PT":
        return "Portuguese (Portugal)";
      case "ro_RO":
        return "Romanian (Romania)";
      case "ru_RU":
        return "Russian (Russia)";
      case "si_LK":
        return "Sinhala (Sri Lanka)";
      case "sk_SK":
        return "Slovak (Slovakia)";
      case "sl_SI":
        return "Slovenian (Slovenia)";
      case "sq_AL":
        return "Albanian (Albania)";
      case "sr_RS":
        return "Serbian (Serbia)";
      case "sv_SE":
        return "Swedish (Sweden)";
      case "sw_KE":
        return "Swahili (Kenya)";
      case "ta_IN":
        return "Tamil (India)";
      case "ta_LK":
        return "Tamil (Sri Lanka)";
      case "te_IN":
        return "Telugu (India)";
      case "th_TH":
        return "Thai (Thailand)";
      case "tl_PH":
        return "Tagalog (Philippines)";
      case "tr_TR":
        return "Turkish (Turkey)";
      case "uk_UA":
        return "Ukrainian (Ukraine)";
      case "ur_PK":
        return "Urdu (Pakistan)";
      case "uz_UZ":
        return "Uzbek (Uzbekistan)";
      case "vi_VN":
        return "Vietnamese (Vietnam)";
      case "cy_GB":
        return "Welsh (United Kingdom)";
      case "zh_CN":
        return "Chinese (China)";
      case "zh_HK":
        return "Chinese (Hong Kong)";
      case "zh_TW":
        return "Chinese (Traditional)";
      case "zu_ZA":
        return "Zulu (South Africa)";
    }

    switch (locale.languageCode) {
      case "en":
        return "English (United States)";
      case "ar":
        return "Arabic (Saudi Arabia)";
      case "af":
        return "Afrikaans (South Africa)";
      case "am":
        return "Amharic (Ethiopia)";
      case "az":
        return "Azerbaijani (Azerbaijan)";
      case "be":
        return "Belarusian (Belarus)";
      case "bg":
        return "Bulgarian (Bulgaria)";
      case "bn":
        return "Bengali (Bangladesh)";
      case "ca":
        return "Catalan (Spain)";
      case "cs":
        return "Czech (Czech Republic)";
      case "da":
        return "Danish (Denmark)";
      case "de":
        return "German (Germany)";
      case "el":
        return "Greek (Greece)";
      case "es":
        return "Spanish (Spain)";
      case "et":
        return "Estonian (Estonia)";
      case "eu":
        return "Basque (Spain)";
      case "fa":
        return "Persian (Iran)";
      case "fi":
        return "Finnish (Finland)";
      case "fil":
        return "Filipino (Philippines)";
      case "fr":
        return "French (France)";
      case "gl":
        return "Galician (Spain)";
      case "gu":
        return "Gujarati (India)";
      case "hi":
        return "Hindi (India)";
      case "hr":
        return "Croatian (Croatia)";
      case "hu":
        return "Hungarian (Hungary)";
      case "hy":
        return "Armenian (Armenia)";
      case "id":
        return "Indonesian (Indonesia)";
      case "is":
        return "Icelandic (Iceland)";
      case "it":
        return "Italian (Italy)";
      case "he":
        return "Hebrew (Israel)";
      case "ja":
        return "Japanese (Japan)";
      case "ka":
        return "Georgian (Georgia)";
      case "kk":
        return "Kazakh (Kazakhstan)";
      case "km":
        return "Khmer (Cambodia)";
      case "kn":
        return "Kannada (India)";
      case "ko":
        return "Korean (South Korea)";
      case "ky":
        return "Kyrgyz (Kyrgyzstan)";
      case "lo":
        return "Lao (Laos)";
      case "lt":
        return "Lithuanian (Lithuania)";
      case "lv":
        return "Latvian (Latvia)";
      case "mk":
        return "Macedonian (North Macedonia)";
      case "ml":
        return "Malayalam (India)";
      case "mn":
        return "Mongolian (Mongolia)";
      case "mr":
        return "Marathi (India)";
      case "ms":
        return "Malay (Malaysia)";
      case "my":
        return "Burmese (Myanmar)";
      case "nb":
        return "Norwegian BokmÃ¥l (Norway)";
      case "ne":
        return "Nepali (Nepal)";
      case "nl":
        return "Dutch (Netherlands)";
      case "no":
        return "Norwegian (Norway)";
      case "pa":
        return "Punjabi (India)";
      case "pl":
        return "Polish (Poland)";
      case "pt":
        return "Portuguese (Brazil)";
      case "ro":
        return "Romanian (Romania)";
      case "ru":
        return "Russian (Russia)";
      case "si":
        return "Sinhala (Sri Lanka)";
      case "sk":
        return "Slovak (Slovakia)";
      case "sl":
        return "Slovenian (Slovenia)";
      case "sq":
        return "Albanian (Albania)";
      case "sr":
        return "Serbian (Serbia)";
      case "sv":
        return "Swedish (Sweden)";
      case "sw":
        return "Swahili (Kenya)";
      case "ta":
        return "Tamil (India)";
      case "te":
        return "Telugu (India)";
      case "th":
        return "Thai (Thailand)";
      case "tr":
        return "Turkish (Turkey)";
      case "uk":
        return "Ukrainian (Ukraine)";
      case "ur":
        return "Urdu (Pakistan)";
      case "vi":
        return "Vietnamese (Vietnam)";
      case "zh":
        return "Chinese (China)";
    }

    if (CommFigs.IS_DEBUG) {
      throw Exception("Locale not found $locale");
    } else {
      return locale.toString();
    }
  }

  static const supportedLocales = <Locale>[
    Locale("en", "US"), // English (United States)

    Locale("af", "ZA"), // Afrikaans (South Africa)
    Locale("am", "ET"), // Amharic (Ethiopia)
    Locale("ar", "SA"), // Arabic (Saudi Arabia)
    Locale("az", "AZ"), // Azerbaijani (Azerbaijan)
    Locale("be", "BY"), // Belarusian (Belarus)
    Locale("bg", "BG"), // Bulgarian (Bulgaria)
    Locale("bn", "BD"), // Bengali (Bangladesh)
    Locale("ca", "ES"), // Catalan (Spain)
    Locale("cs", "CZ"), // Czech (Czech Republic)
    Locale("da", "DK"), // Danish (Denmark)
    Locale("de", "DE"), // German (Germany)
    Locale("el", "GR"), // Greek (Greece)
    Locale("en", "AU"), // English (Australia)
    Locale("en", "CA"), // English (Canada)
    Locale("en", "GB"), // English (United Kingdom)
    Locale("es", "BR"), // Spanish (Brazil)
    Locale("es", "ES"), // Spanish (Spain)
    Locale("es", "US"), // Spanish (United States)
    Locale("et", "EE"), // Estonian (Estonia)
    Locale("eu", "ES"), // Basque (Spain)
    Locale("fa", "IR"), // Persian (Iran)
    Locale("fi", "FI"), // Finnish (Finland)
    Locale("fil", "PH"), // Filipino (Philippines)
    Locale("fr", "FR"), // French (France)
    Locale("fr", "CA"), // French (Canada)
    Locale("gl", "ES"), // Galician (Spain)
    Locale("gu", "IN"), // Gujarati (India)
    Locale("hi", "IN"), // Hindi (India)
    Locale("hr", "HR"), // Croatian (Croatia)
    Locale("hu", "HU"), // Hungarian (Hungary)
    Locale("hy", "AM"), // Armenian (Armenia)
    Locale("id", "ID"), // Indonesian (Indonesia)
    Locale("is", "IS"), // Icelandic (Iceland)
    Locale("it", "IT"), // Italian (Italy)
    Locale("he", "IL"), // Hebrew (Israel)
    Locale("ja", "JP"), // Japanese (Japan)
    Locale("ka", "GE"), // Georgian (Georgia)
    Locale("kk", "KZ"), // Kazakh (Kazakhstan)
    Locale("km", "KH"), // Khmer (Cambodia)
    Locale("kn", "IN"), // Kannada (India)
    Locale("ko", "KR"), // Korean (South Korea)
    Locale("ky", "KG"), // Kyrgyz (Kyrgyzstan)
    Locale("lo", "LA"), // Lao (Laos)
    Locale("lt", "LT"), // Lithuanian (Lithuania)
    Locale("lv", "LV"), // Latvian (Latvia)
    Locale("mk", "MK"), // Macedonian (North Macedonia)
    Locale("ml", "IN"), // Malayalam (India)
    Locale("mn", "MN"), // Mongolian (Mongolia)
    Locale("mr", "IN"), // Marathi (India)
    Locale("ms", "MY"), // Malay (Malaysia)
    Locale("my", "MM"), // Burmese (Myanmar)
    Locale("nb", "NO"), // Norwegian BokmÃ¥l (Norway)
    Locale("ne", "NP"), // Nepali (Nepal)
    Locale("nl", "NL"), // Dutch (Netherlands)
    Locale("no", "NO"), // Norwegian (Norway)
    Locale("pa", "IN"), // Punjabi (India)
    Locale("pl", "PL"), // Polish (Poland)
    Locale("pt", "BR"), // Portuguese (Brazil)
    Locale("pt", "PT"), // Portuguese (Portugal)
    Locale("ro", "RO"), // Romanian (Romania)
    Locale("ru", "RU"), // Russian (Russia)
    Locale("si", "LK"), // Sinhala (Sri Lanka)
    Locale("sk", "SK"), // Slovak (Slovakia)
    Locale("sl", "SI"), // Slovenian (Slovenia)
    Locale("sq", "AL"), // Albanian (Albania)
    Locale("sr", "RS"), // Serbian (Serbia)
    Locale("sv", "SE"), // Swedish (Sweden)
    Locale("sw", "KE"), // Swahili (Kenya)
    Locale("te", "IN"), // Telugu (India)
    Locale("ta", "IN"), // Tamil (India)
    Locale("ta", "LK"), // Tamil (Sri Lanka)
    Locale("th", "TH"), // Thai (Thailand)
    Locale("tr", "TR"), // Turkish (Turkey)
    Locale("uk", "UA"), // Ukrainian (Ukraine)
    Locale("ur", "PK"), // Urdu (Pakistan)
    Locale("vi", "VN"), // Vietnamese (Vietnam)
    Locale("zh", "CN"), // Chinese (China)
    Locale("zh", "HK"), // Chinese (Hong Kong)
    Locale("zh", "TW"), // Chinese (Traditional)
    Locale("zu", "ZA"), // Zulu (South Africa)
  ];

  static String _getFilePath(String root, Locale locale, String fileName) {
    switch (locale.toString()) {
      case "af_ZA":
        return "$root/values-af/$fileName";
      case "am_ET":
        return "$root/values-am/$fileName";
      case "ar_SA":
        return "$root/values-ar/$fileName";
      case "az_AZ":
        return "$root/values-az/$fileName";
      case "be_BY":
        return "$root/values-be/$fileName";
      case "bg_BG":
        return "$root/values-bg/$fileName";
      case "bn_BD":
        return "$root/values-bn/$fileName";
      case "ca_ES":
        return "$root/values-ca/$fileName";
      case "cs_CZ":
        return "$root/values-cs/$fileName";
      case "da_DK":
        return "$root/values-da/$fileName";
      case "de_DE":
        return "$root/values-de/$fileName";
      case "el_GR":
        return "$root/values-el/$fileName";
      case "en_AU":
        return "$root/values-en-rAU/$fileName";
      case "en_CA":
        return "$root/values-en-rCA/$fileName";
      case "en_GB":
        return "$root/values-en-rGB/$fileName";
      case "es_ES":
        return "$root/values-es/$fileName";
      case "es-MX":
        return "$root/values-es-rMX/$fileName";
      case "es_BR":
        return "$root/values-es-rBR/$fileName";
      case "es_US":
        return "$root/values-es-rUS/$fileName";
      case "et_EE":
        return "$root/values-et/$fileName";
      case "eu_ES":
        return "$root/values-eu/$fileName";
      case "fa_IR":
        return "$root/values-fa/$fileName";
      case "fi_FI":
        return "$root/values-fi/$fileName";
      case "fil_PH":
        return "$root/values-fil/$fileName";
      case "fr_FR":
        return "$root/values-fr/$fileName";
      case "fr_CA":
        return "$root/values-fr-rCA/$fileName";
      case "gl_ES":
        return "$root/values-gl/$fileName";
      case "gu_IN":
        return "$root/values-gu/$fileName";
      case "hi_IN":
        return "$root/values-hi/$fileName";
      case "hr_HR":
        return "$root/values-hr/$fileName";
      case "hu_HU":
        return "$root/values-hu/$fileName";
      case "hy_AM":
        return "$root/values-hy/$fileName";
      case "id_ID":
        return "$root/values-id/$fileName";
      case "is_IS":
        return "$root/values-is/$fileName";
      case "it_IT":
        return "$root/values-it/$fileName";
      case "he_IL":
        return "$root/values-iw/$fileName";
      case "ja_JP":
        return "$root/values-ja/$fileName";
      case "ka_GE":
        return "$root/values-ka/$fileName";
      case "kk_KZ":
        return "$root/values-kk/$fileName";
      case "km_KH":
        return "$root/values-km/$fileName";
      case "kn_IN":
        return "$root/values-kn/$fileName";
      case "ko_KR":
        return "$root/values-ko/$fileName";
      case "ky_KG":
        return "$root/values-ky/$fileName";
      case "lo_LA":
        return "$root/values-lo/$fileName";
      case "lt_LT":
        return "$root/values-lt/$fileName";
      case "lv_LV":
        return "$root/values-lv/$fileName";
      case "mk_MK":
        return "$root/values-mk/$fileName";
      case "ml_IN":
        return "$root/values-ml/$fileName";
      case "mn_MN":
        return "$root/values-mn/$fileName";
      case "mr_IN":
        return "$root/values-mr/$fileName";
      case "ms_MY":
        return "$root/values-ms/$fileName";
      case "my_MM":
        return "$root/values-my/$fileName";
      case "nb_NO":
        return "$root/values-nb/$fileName";
      case "ne_NP":
        return "$root/values-ne/$fileName";
      case "nl_NL":
        return "$root/values-nl/$fileName";
      case "no_NO":
        return "$root/values-no/$fileName";
      case "pl_PL":
        return "$root/values-pl/$fileName";
      case "pt_PT":
        return "$root/values-pt/$fileName";
      case "ro_RO":
        return "$root/values-ro/$fileName";
      case "ru_RU":
        return "$root/values-ru/$fileName";
      case "sk_SK":
        return "$root/values-sk/$fileName";
      case "sl_SI":
        return "$root/values-sl/$fileName";
      case "sq_AL":
        return "$root/values-sq/$fileName";
      case "sr_RS":
        return "$root/values-sr/$fileName";
      case "sv_SE":
        return "$root/values-sv/$fileName";
      case "sw_KE":
        return "$root/values-sw/$fileName";
      case "te_IN":
        return "$root/values-te/$fileName";
      case "th_TH":
        return "$root/values-th/$fileName";
      case "tr_TR":
        return "$root/values-tr/$fileName";
      case "uk_UA":
        return "$root/values-uk/$fileName";
      case "ur_PK":
        return "$root/values-ur/$fileName";
      case "vi_VN":
        return "$root/values-vi/$fileName";
      case "ta_LK":
        return "$root/values-ta/$fileName";
      case "ta_IN":
        return "$root/values-ta-rIN/$fileName";
      case "zh_CN":
        return "$root/values-zh-rCN/$fileName";
      case "zh_HK":
        return "$root/values-zh-rHK/$fileName";
      case "zh_TW":
        return "$root/values-zh-rTW/$fileName";
      case "zu_ZA":
        return "$root/values-zu/$fileName";
    }

    switch (locale.languageCode) {
      case "en":
        return "$root/values/$fileName";
      case "ar":
        return "$root/values-ar/$fileName";
      case "af":
        return "$root/values-af/$fileName";
      case "am":
        return "$root/values-am/$fileName";
      case "az":
        return "$root/values-az/$fileName";
      case "be":
        return "$root/values-be/$fileName";
      case "bg":
        return "$root/values-bg/$fileName";
      case "bn":
        return "$root/values-bn/$fileName";
      case "ca":
        return "$root/values-ca/$fileName";
      case "cs":
        return "$root/values-cs/$fileName";
      case "da":
        return "$root/values-da/$fileName";
      case "de":
        return "$root/values-de/$fileName";
      case "el":
        return "$root/values-el/$fileName";
      case "es":
        return "$root/values-es/$fileName";
      case "et":
        return "$root/values-et/$fileName";
      case "eu":
        return "$root/values-eu/$fileName";
      case "fa":
        return "$root/values-fa/$fileName";
      case "fi":
        return "$root/values-fi/$fileName";
      case "fil":
        return "$root/values-fil/$fileName";
      case "fr":
        return "$root/values-fr/$fileName";
      case "gl":
        return "$root/values-gl/$fileName";
      case "gu":
        return "$root/values-gu/$fileName";
      case "hi":
        return "$root/values-hi/$fileName";
      case "hr":
        return "$root/values-hr/$fileName";
      case "hu":
        return "$root/values-hu/$fileName";
      case "hy":
        return "$root/values-hy/$fileName";
      case "id":
        return "$root/values-id/$fileName";
      case "is":
        return "$root/values-is/$fileName";
      case "it":
        return "$root/values-it/$fileName";
      case "he":
        return "$root/values-iw/$fileName";
      case "ja":
        return "$root/values-ja/$fileName";
      case "ka":
        return "$root/values-ka/$fileName";
      case "kk":
        return "$root/values-kk/$fileName";
      case "km":
        return "$root/values-km/$fileName";
      case "kn":
        return "$root/values-kn/$fileName";
      case "ko":
        return "$root/values-ko/$fileName";
      case "ky":
        return "$root/values-ky/$fileName";
      case "lo":
        return "$root/values-lo/$fileName";
      case "lt":
        return "$root/values-lt/$fileName";
      case "lv":
        return "$root/values-lv/$fileName";
      case "mk":
        return "$root/values-mk/$fileName";
      case "ml":
        return "$root/values-ml/$fileName";
      case "mn":
        return "$root/values-mn/$fileName";
      case "mr":
        return "$root/values-mr/$fileName";
      case "ms":
        return "$root/values-ms/$fileName";
      case "my":
        return "$root/values-my/$fileName";
      case "nb":
        return "$root/values-nb/$fileName";
      case "ne":
        return "$root/values-ne/$fileName";
      case "nl":
        return "$root/values-nl/$fileName";
      case "no":
        return "$root/values-no/$fileName";
      case "pa":
        return "$root/values-pa/$fileName";
      case "pl":
        return "$root/values-pl/$fileName";
      case "pt":
        return "$root/values-pt/$fileName";
      case "ro":
        return "$root/values-ro/$fileName";
      case "ru":
        return "$root/values-ru/$fileName";
      case "si":
        return "$root/values-si/$fileName";
      case "sk":
        return "$root/values-sk/$fileName";
      case "sl":
        return "$root/values-sl/$fileName";
      case "sq":
        return "$root/values-sq/$fileName";
      case "sr":
        return "$root/values-sr/$fileName";
      case "sv":
        return "$root/values-sv/$fileName";
      case "sw":
        return "$root/values-sw/$fileName";
      case "te":
        return "$root/values-te/$fileName";
      case "th":
        return "$root/values-th/$fileName";
      case "ta":
        return "$root/values-ta/$fileName";
      case "tr":
        return "$root/values-tr/$fileName";
      case "uk":
        return "$root/values-uk/$fileName";
      case "ur":
        return "$root/values-ur/$fileName";
      case "vi":
        return "$root/values-vi/$fileName";
      case "zh":
        return "$root/values-zh/$fileName";
      case "zu":
        return "$root/values-zu/$fileName";
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

import "dart:io";

class AdTestIds {
  static const String _testIdRoot = "ca-app-pub-3940256099942544/";

  static final String bannerAdId = Platform.isAndroid ? "${_testIdRoot}9214589741" : "${_testIdRoot}2435281174";

  static final String interstitialAdId = Platform.isAndroid ? "${_testIdRoot}1033173712" : "${_testIdRoot}4411468910";

  static final String nativeAdId = Platform.isAndroid ? "${_testIdRoot}2247696110" : "${_testIdRoot}3986624511";

  static final String nativeAdVideoId = Platform.isAndroid ? "${_testIdRoot}1044960115" : "${_testIdRoot}2521693316";

  static final String appOpenAdId = Platform.isAndroid ? "${_testIdRoot}9257395921" : "${_testIdRoot}5575463023";

  static final String rewardedAdId = Platform.isAndroid ? "${_testIdRoot}5224354917" : "${_testIdRoot}1712485313";
}

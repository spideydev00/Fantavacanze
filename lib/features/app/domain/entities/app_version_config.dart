enum AppVersionStatus { upToDate, forceUpdate }

class AppVersionConfig {
  final String minSupportedVersion;
  final String storeUrl;

  AppVersionConfig({
    required this.minSupportedVersion,
    required this.storeUrl,
  });
}

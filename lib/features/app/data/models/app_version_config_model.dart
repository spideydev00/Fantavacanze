class AppVersionConfigModel {
  final String minSupportedVersion;
  final String storeUrl;

  AppVersionConfigModel({
    required this.minSupportedVersion,
    required this.storeUrl,
  });

  factory AppVersionConfigModel.fromJson(Map<String, dynamic> json) {
    return AppVersionConfigModel(
      minSupportedVersion: json['min_supported_version'],
      storeUrl: json['store_url'],
    );
  }
}

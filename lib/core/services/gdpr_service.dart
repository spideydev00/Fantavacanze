import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:flutter/foundation.dart';
import 'package:gdpr_admob/gdpr_admob.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GdprService {
  final GdprAdmob _gdprAdmob = GdprAdmob();
  bool _isInitializing = false;
  String? _currentConsentStatus;
  String? _errorMessage;

  String? get currentConsentStatus => _currentConsentStatus;
  String? get errorMessage => _errorMessage;
  bool get isInitializing => _isInitializing;

  Future<void> initializeAndShowForm({List<String>? testIdentifiers}) async {
    if (_isInitializing) return;
    _isInitializing = true;
    _errorMessage = null;

    // IMPORTANT: Replace with your actual test device identifiers
    final defaultTestIdentifiers =
        (kDebugMode && defaultTargetPlatform == TargetPlatform.android)
            ? [AppSecrets.androidTestDevice]
            : (kDebugMode && defaultTargetPlatform == TargetPlatform.iOS)
                ? [AppSecrets.iosTestDevice]
                : <String>[];

    final error = await _gdprAdmob.initialize(
      // Use DebugGeography.debugGeographyEea for testing in EEA region
      // Use DebugGeography.debugGeographyNotEea for testing outside EEA
      // Remove 'mode' for production to let the SDK auto-detect
      mode: DebugGeography.debugGeographyEea,
      testIdentifiers: testIdentifiers ?? defaultTestIdentifiers,
      // publisherId: "YOUR_ADMOB_PUBLISHER_ID",
    );

    if (error != null) {
      _errorMessage = error.message;
    } else {
      await _fetchConsentStatus();
    }

    _isInitializing = false;
  }

  Future<void> _fetchConsentStatus() async {
    final status = await _gdprAdmob.getConsentStatus();
    _currentConsentStatus = status;
    // Notify listeners
  }

  Future<String?> getConsentStatusString() async {
    await _fetchConsentStatus();
    return _currentConsentStatus;
  }

  // Resets the consent status. The next call to initializeAndShowForm will show the form.
  Future<void> resetConsentStatus() async {
    if (_isInitializing) return;
    _isInitializing = true;
    _errorMessage = null;

    final error = await _gdprAdmob.resetConsentStatus();
    if (error != null) {
      _errorMessage = error.message;
    } else {
      await _fetchConsentStatus();
    }
    _isInitializing = false;
  }
}

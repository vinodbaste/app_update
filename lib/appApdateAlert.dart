library inapp_updates;

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

///Info about the most recent and current versions of the software
///that are accessible through the Apple App Store or Google Play Store.
class AppVersionStatus {
  final String appVersion;
  final String storeVersion;
  final String storeLink;
  final String? releaseNotes;

  AppVersionStatus._({
    required this.appVersion,
    required this.storeVersion,
    required this.storeLink,
    this.releaseNotes,
  });

  /// Returns `true` if the store version of the application is greater than the local version.
  bool get isUpdateAvailable {
    final appLocalVersion = appVersion.split('.').map(int.parse).toList();
    final appStoreVersion = storeVersion.split('.').map(int.parse).toList();

    //Only one comparison needs to return "true" in order to establish that the appStoreVersion version
    // is greater than the appLocalVersion version.
    // This is because each subsequent field in the version notation is less important than
    // the one before it.
    for (var i = 0; i < appStoreVersion.length; i++) {
      if (appStoreVersion[i] > appLocalVersion[i]) {
        return true;
      }
      if (appLocalVersion[i] > appStoreVersion[i]) {
        return false;
      }
    }
    return false;
  }
}

/// An optional value that will force the plugin to always return [forceAppVersion]
/// as the value of [storeVersion]. This can be useful to test the plugin's behavior
/// before publishing a new version.
class AppUpdates {
  final String? iosPackageName;
  final String? androidPackageName;
  final String? iosAppStoreCountry;
  final String? forceAppVersion;

  AppUpdates({
    this.androidPackageName,
    this.iosPackageName,
    this.iosAppStoreCountry,
    this.forceAppVersion,
  });

  /// Shows the user a platform-specific alert about the app update. The user
  /// can dismiss the alert or proceed to the app store.
  ///
  /// To change the appearance and behavior of the update dialog, you can
  /// optionally provide [dialogTitle], [dialogText], [updateButtonText], [allowDismissal],
  /// [dismissButtonText], and [dismissAction] parameters.
  showUpdateAlert({required BuildContext context,
    String? dialogTitle,
    String? dialogText,
    String? updateButtonText,
    bool? allowDismissal,
    String? dismissButtonText,
    VoidCallback? dismissAction}) async {

    final AppVersionStatus? versionStatus = await _getVersionStatus();

    if (versionStatus != null && versionStatus.isUpdateAvailable) {

      _showUpdateDialog(
          context: context,
          versionStatus: versionStatus,
          dialogTitle: dialogTitle,
          dialogText: dialogText,
          updateButtonText: updateButtonText,
          allowDismissal: allowDismissal,
          dismissButtonText: dismissButtonText,
          dismissAction: dismissAction);
    }
  }

  /// This retrieves the data and verifies the version status.
  /// If you wish to use the data in a different way or display a custom alert, this is beneficial.
  Future<AppVersionStatus?> _getVersionStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS) {
      return _iosStoreVersion(packageInfo);
    } else if (Platform.isAndroid) {
      return _androidStoreVersion(packageInfo);
    } else {
      debugPrint(
          'The target platform "${Platform.operatingSystem}" is not yet supported by this package.');
    }
    return null;
  }

  /// This function attempts to clean local version strings so they match the MAJOR.MINOR.PATCH
  /// versioning pattern, so they can be properly compared with the store version.
  String _getCleanVersion(String version) =>
      RegExp(r'\d+\.\d+\.\d+').stringMatch(version) ?? '0.0.0';

  /// iOS info is fetched by using the iTunes lookup API, which returns a
  /// JSON document.
  Future<AppVersionStatus?> _iosStoreVersion(PackageInfo packageInfo) async {
    final id = iosPackageName ?? packageInfo.packageName;
    final parameters = {"bundleId": id};
    if (iosAppStoreCountry != null) {
      parameters.addAll({"country": iosAppStoreCountry!});
    }
    var uri = Uri.https("itunes.apple.com", "/lookup", parameters);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Failed to query iOS App Store');
      return null;
    }
    final jsonObj = json.decode(response.body);
    final List results = jsonObj['results'];
    if (results.isEmpty) {
      debugPrint('Can\'t find an app in the App Store with the id: $id');
      return null;
    }
    return AppVersionStatus._(
      appVersion: _getCleanVersion(forceAppVersion ?? packageInfo.version),
      storeVersion:
          _getCleanVersion(forceAppVersion ?? jsonObj['results'][0]['version']),
      storeLink: jsonObj['results'][0]['trackViewUrl'],
      releaseNotes: jsonObj['results'][0]['releaseNotes'],
    );
  }

  /// Android info is fetched by parsing the html of the app store page.
  Future<AppVersionStatus?> _androidStoreVersion(
      PackageInfo packageInfo) async {
    final id = androidPackageName ?? packageInfo.packageName;
    final uri = Uri.https(
        "play.google.com", "/store/apps/details", {"id": id, "hl": "en"});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the Play Store with the id: $id');
      return null;
    }
    final document = parse(response.body);

    String storeVersion = '0.0.0';
    String? releaseNotes;

    final additionalInfoElements = document.getElementsByClassName('hAyfc');
    if (additionalInfoElements.isNotEmpty) {
      final versionElement = additionalInfoElements.firstWhere(
        (elm) => elm.querySelector('.BgcNfc')!.text == 'Current Version',
      );
      storeVersion = versionElement.querySelector('.htlgb')!.text;

      final sectionElements = document.getElementsByClassName('W4P4ne');
      final releaseNotesElement = sectionElements.firstWhereOrNull(
        (elm) => elm.querySelector('.wSaTQd')!.text == 'What\'s New',
      );
      releaseNotes = releaseNotesElement
          ?.querySelector('.PHBdkd')
          ?.querySelector('.DWPxHb')
          ?.text;
    } else {
      final scriptElements = document.getElementsByTagName('script');
      final infoScriptElement = scriptElements.firstWhere(
        (elm) => elm.text.contains('key: \'ds:4\''),
      );

      final param = infoScriptElement.text
          .substring(20, infoScriptElement.text.length - 2)
          .replaceAll('key:', '"key":')
          .replaceAll('hash:', '"hash":')
          .replaceAll('data:', '"data":')
          .replaceAll('sideChannel:', '"sideChannel":')
          .replaceAll('\'', '"');
      final parsed = json.decode(param);
      final data = parsed['data'];

      storeVersion = data[1][2][140][0][0][0];
      releaseNotes = data[1][2][144][1][1];
    }

    return AppVersionStatus._(
      appVersion: _getCleanVersion(forceAppVersion ?? packageInfo.version),
      storeVersion: _getCleanVersion(forceAppVersion ?? storeVersion),
      storeLink: uri.toString(),
      releaseNotes: releaseNotes,
    );
  }

  /// Shows the user a platform-specific alert about the app update. The user
  /// can dismiss the alert or proceed to the app store.
  ///
  /// To change the appearance and behavior of the update dialog, you can
  /// optionally provide [dialogTitle], [dialogText], [updateButtonText],
  /// [dismissButtonText], and [dismissAction] parameters.
  void _showUpdateDialog({
    required BuildContext context,
    required AppVersionStatus versionStatus,
    String? dialogTitle,
    String? dialogText,
    String? updateButtonText,
    bool? allowDismissal,
    String? dismissButtonText,
    VoidCallback? dismissAction,
  }) async {
    final dialogTitleWidget = Text(dialogTitle ?? 'Update Available');
    final dialogTextWidget = Text(
      dialogText ?? 'Update your app now to latest version and give it a spin!',
    );

    final updateButtonTextWidget = Text(updateButtonText ?? 'Update');
    updateAction() {
      _launchAppStore(versionStatus.storeLink);
      if (allowDismissal ?? true) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    List<Widget> actions = [
      Platform.isAndroid
          ? TextButton(
              onPressed: updateAction,
              child: updateButtonTextWidget,
            )
          : CupertinoDialogAction(
              onPressed: updateAction,
              child: updateButtonTextWidget,
            ),
    ];

    if (allowDismissal ?? true) {
      final dismissButtonTextWidget = Text(dismissButtonText ?? 'Maybe Later');
      dismissAction = dismissAction ??
          () => Navigator.of(context, rootNavigator: true).pop();
      actions.add(
        Platform.isAndroid
            ? TextButton(
                onPressed: dismissAction,
                child: dismissButtonTextWidget,
              )
            : CupertinoDialogAction(
                onPressed: dismissAction,
                child: dismissButtonTextWidget,
              ),
      );
    }

    await showDialog(
      context: context,
      barrierDismissible: allowDismissal ?? true,
      builder: (BuildContext context) {
        return WillPopScope(
            child: Platform.isAndroid
                ? AlertDialog(
                    title: dialogTitleWidget,
                    content: dialogTextWidget,
                    actions: actions,
                  )
                : CupertinoAlertDialog(
                    title: dialogTitleWidget,
                    content: dialogTextWidget,
                    actions: actions,
                  ),
            onWillPop: () => Future.value(allowDismissal));
      },
    );
  }

  /// Launches the Apple App Store or Google Play Store page for the app.
  Future<void> _launchAppStore(String appStoreLink) async {
    debugPrint(appStoreLink);
    if (await canLaunchUrl(Uri.parse(appStoreLink))) {
      await canLaunchUrl(Uri.parse(appStoreLink));
    } else {
      throw 'Could not launch appStoreLink';
    }
  }
}

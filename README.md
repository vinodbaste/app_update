
# App Update alert Plugin
```keep your app users up to date on their devices```

[![API](https://img.shields.io/badge/API-21%2B-brightgreen.svg?style=flat)](https://android-arsenal.com/api?level=21)
[![GitHub tag](https://img.shields.io/github/tag/vinodbaste/image-compressor?include_prereleases=&sort=semver&color=blue)](https://github.com/vinodbaste/image-compressor/releases/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue)](#license)
[![News - Android Weekly](https://img.shields.io/badge/News-Android_Weekly-d36f21)](https://androidweekly.net/issues/issue-326)
[![Story - Medium](https://img.shields.io/badge/Story-Medium-2ea44f)](https://medium.com/codex/image-compressor-13dbfd0445a3)
[![GitHub - VinodBaste](https://img.shields.io/badge/GitHub-VinodBaste-4664c6)](https://github.com/vinodbaste/Image-compressor)

With the help of a this Flutter plugin.
* Check if a user has the most recent installation of your app.
* Display a message to the user with a link to the relevant app store page.

See more at the [Dart Packages page.](https://pub.dartlang.org/packages/new_version)

<img src = "https://github.com/vinodbaste/app_update/blob/main/screenshots/android.png" width = 250 height = 500 />

## Installation
Add `app_update_alert` as [a dependency in your `pubspec.yaml` file.](https://flutter.io/using-packages/)

## With Flutter:
```
Run this command:
flutter pub add app_update_alert
```
This will add a line like below to your package's ```pubspec.yaml```

```
dependencies:
  app_update_alert: ^1.1.0
```
run an implicit ```flutter pub get```

## Usage
Create an instance of `AppUpdate` in `main.dart` (or wherever your app is initialised).

```Dart
@override
  void initState() {
    super.initState();
 final appUpdate = AppUpdate(
      iosPackageName: 'com.your.IOSpackage',
      androidPackageName: 'com.your.Androidpackage', 
      iOSAppStoreCountry: 'in'
  );
}
```

Your Flutter package identification will be used by the plugin automatically to search the app store.
You can overwrite this identity if your app uses a different one on the Google Play Store or Apple App Store by giving values for `androidPackageName` and/or `iosPackageName.`

```Dart
@override
  void initState() {
    super.initState();
 final appUpdate = AppUpdate(
      iosPackageName: 'com.your.IOSpackage',
      androidPackageName: 'com.your.Androidpackage', 
      iOSAppStoreCountry: 'in'
  );
}
```

*For iOS:* You must specify `iOSAppStoreCountry` to the two-letter country code of the Software Store you want to search if your app is only accessible outside the India. A list of ISO Country Codes can be found at http://en.wikipedia.org/wiki/ISO 3166-1 alpha-2.


### Quickstart
Calling `showUpdateAlert` with your app's `BuildContext` will check if the app can be updated, and will automatically display a platform-specific alert that the user can use to go to the app store.

```Dart
@override
  void initState() {
    super.initState();
 final appUpdate = AppUpdate(
      iosPackageName: 'com.your.IOSpackage',
      androidPackageName: 'com.your.Androidpackage', 
      iOSAppStoreCountry: 'in'
  );
  
 `appUpdate.showUpdateAlert(context: context);`
}
```

# License
```
Copyright [2022] [Vinod Baste]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

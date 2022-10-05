import 'package:app_update_alert/app_update_alert.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    // Instantiate AppUpdate manager object (Using GCP Console app as example)
    final appUpdate = AppUpdates(
        iosPackageName: 'com.google.Vespa',
        androidPackageName: 'com.google.android.apps.cloudconsole',
        iosAppStoreCountry: 'in'
    );

    // Instantiate AppUpdate manager object with forceAppVersion
    final forceAppUpdate = AppUpdates(
        iosPackageName: 'com.google.Vespa',
        androidPackageName: 'com.google.android.apps.cloudconsole',
        iosAppStoreCountry: 'in',
        forceAppVersion: '1.0.1'
    );

    // You can let the plugin handle fetching the status and showing a dialog,
    // or you can add version and forceUpdate the status to display the dialog.
    const forceUpdate = true;

    if (forceUpdate) {
      showUpdateDialog(appUpdate);
    } else {
      showUpdateDialog(forceAppUpdate);
    }
  }

  showUpdateDialog(AppUpdates appUpdate) {
    appUpdate.showUpdateAlert(context: context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example App"),
      ),
    );
  }
}

import 'package:app_updates/app_updates.dart';
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

    // Instantiate AppUpdates manager object
    final appUpdates = AppUpdates(
      iosPackageName: 'your IOS Package Name',
      androidPackageName: 'your android Package Name',
      iosAppStoreCountry: 'in'
    );

    // You can let the plugin handle fetching the status and showing a dialog
    appUpdates.showUpdateAlert(context: context);

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

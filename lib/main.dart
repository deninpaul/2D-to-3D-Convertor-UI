import 'package:flutter/material.dart';
import 'package:hotelapp/Utils/global.dart';
import 'entries.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    azureURL = apiURL;

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Entry(),
      },
      theme: ThemeData(
        
        primarySwatch: Colors.lightGreen,
        fontFamily: "GeneralSans",
      ),
    );
  }
}

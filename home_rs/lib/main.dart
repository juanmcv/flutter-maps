import 'package:flutter/material.dart';
import 'package:home_rs/app/ui/routes/pages.dart';

import 'app/ui/routes/routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
     theme: ThemeData(
       primarySwatch: Colors.blue,
     ),
     initialRoute: Routes.SPLASH,
      routes: appRoutes(),
    );
  }
}
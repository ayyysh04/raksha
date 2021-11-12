import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:raksha/Utils/routes.dart';
import 'package:raksha/Utils/themes.dart';
import 'package:raksha/core/store.dart';
import 'package:raksha/pages/homepage.dart';
import 'package:velocity_x/velocity_x.dart';

void main() async {
  await FlutterBackgroundService.initialize(onStart);
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  runApp(VxState(
    store: Mystore(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = (VxState.store as Mystore).themeMode!.themeMode;
    return MaterialApp(
      themeMode: themeMode,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      debugShowCheckedModeBanner: false,
      title: 'Raksha',
      home: SplashScreenWidget(),
      routes: {
        MyRoutes.homeRoute: (context) => HomePage(),
      },
    );
  }
}

class SplashScreenWidget extends StatelessWidget {
  const SplashScreenWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      durationInSeconds: 3,
      loaderColor: context.accentColor,
      backgroundColor: Vx.white,
      logo: Image.asset("assets/images/logo.png"),
      logoSize: 120,
      loadingText: Text(
        "Made in India",
      ),
      navigator: HomePage(),
    );
  }
}

import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raksha/Utils/background_services.dart';
import 'package:raksha/Utils/routes.dart';
import 'package:raksha/Utils/themes.dart';
import 'package:raksha/core/store.dart';
import 'package:raksha/pages/homepage.dart';
import 'package:raksha/pages/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      loaderColor: Vx.green700,
      backgroundColor: Vx.white,
      logo: Image.asset("assets/images/logo.png"),
      logoSize: 120,
      title: Text("RAKSHA",
          style: TextStyle(
            color: Vx.green700,
            fontSize: 40,
            fontFamily: GoogleFonts.poppins().fontFamily,
          )),
      loadingText: Text(
        "Made in India",
      ),
      futureNavigator: isAppOpeningForFirstTime(),
    );
  }

  Future<Object> isAppOpeningForFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = prefs.getBool("appOpenedBefore") ?? false;
    if (!result) {
      prefs.setBool("appOpenedBefore", true);
    }

    if (result) {
      await Future.delayed(Duration(seconds: 3));
      return Future.value(HomePage());
    } else
      return Future.value(OnBoardingPage());
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:marquee/marquee.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:raksha/Utils/home/customer_painter/curve_wave.dart';
import 'package:raksha/pages/ContactScreens/my_contacts.dart';
import 'package:raksha/pages/settings/settings_screen.dart';
import 'package:raksha/widgets/home/emergency_button.dart';
import 'package:raksha/widgets/home/safe_home.dart';
import 'package:raksha/widgets/home/women_quote_carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;

import 'package:permission_handler/permission_handler.dart' as appPermissions;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool alerted = false;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  List<Widget> _pages = [Home(), MyContactsScreen(), SettingsScreen()];
  PageController controller = PageController();
  int selectedIndex = 0;
  int badge = 0;
  // int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true,
      appBar: AppBar(
        title: "Raksha".text.xl3.make(),
        centerTitle: true,
        backgroundColor: Vx.red400,
        toolbarHeight: 60,
      ),
      body: PageView.builder(
        itemBuilder: (context, position) {
          return _pages[position];
        },
        itemCount: 3,
        onPageChanged: (page) {
          setState(() {
            // print(page);
            selectedIndex = page;
            // badge = badge + 1;
          });
        },
        controller: controller,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              tabs: [
                GButton(
                  gap: 10,
                  iconActiveColor: Vx.red500,
                  iconColor: Colors.black,
                  textColor: Vx.red500,
                  backgroundColor: Vx.red200,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  gap: 10,
                  iconActiveColor: Vx.red500,
                  iconColor: Colors.black,
                  textColor: Vx.red500,
                  backgroundColor: Vx.red200,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  icon: LineIcons.phone,
                  leading: selectedIndex == 1 || badge == 0
                      ? null
                      : Badge(
                          badgeColor: Colors.red.shade100,
                          elevation: 0,
                          position: BadgePosition.topEnd(top: -12, end: -12),
                          badgeContent: Text(
                            badge.toString(),
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                          child: Icon(
                            LineIcons.phone,
                            color:
                                selectedIndex == 1 ? Colors.pink : Colors.black,
                          ),
                        ),
                  text: 'Contacts',
                ),
                GButton(
                  gap: 10,
                  iconActiveColor: Vx.red500,
                  iconColor: Colors.black,
                  textColor: Vx.red500,
                  backgroundColor: Vx.red200,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  icon: Icons.settings_outlined,
                  text: 'Settings',
                ),
              ],
              selectedIndex: selectedIndex,
              onTabChange: (index) {
                setState(() {
                  // selectedIndex = index;
                  controller.animateToPage(index,
                      duration: Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn);
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription? backgroundState;
  Future<dynamic> fetchNews() async {
    dynamic response;
    try {
      response = await http.get(Uri.parse(
          'https://newsapi.org/v2/everything?q=women security&apiKey=90f054484072424db01c52b8e5b6b0e7'));
      if (response.statusCode == 200) {
        dynamic json = jsonDecode(response.body)["articles"];
        return json;
      }
    } catch (e) {}
  }

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool? alerted;
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  static Future<void> openGoogleMap(String location) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$location';

    try {
      await launch(googleUrl);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "Something went wrong! Call emergency numbers.");
    }
  }

  @override
  void initState() {
    final service = FlutterBackgroundService();
    StreamSubscription backgroundState =
        service.onDataReceived.listen((event) async {
      if (event?["action"] == "setStateAlert") {
        prefs = await SharedPreferences.getInstance();
        await prefs?.reload();
        if (mounted)
          setState(() {
            alerted = prefs?.getBool("alerted") ?? false;
          });
      }
    });
    checkAlertSharedPreferences();
    checkPermission();
    super.initState();
  }

  @override
  void dispose() {
    backgroundState?.cancel();
    super.dispose();
  }

  SharedPreferences? prefs;
  checkAlertSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        alerted = prefs?.getBool("alerted") ?? false;
        print(alerted);
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder(
              initialData: null,
              future: fetchNews(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                String news = "";

                if (snapshot.hasData) {
                  for (int i = 0; i < snapshot.data.length; i++) {
                    news = news + snapshot.data[i]["source"]["name"] + ":";
                    news = news + snapshot.data[i]["title"];
                    news = news + ". ";
                  }
                } else
                  news = "No Internet                         ";

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  height: 50,
                  child: Marquee(
                    text: news,
                  ),
                );
              },
            ),
            5.heightBox,
            EmergencyButton(
              message: (alerted == null || alerted == false)
                  ? "Tap in case \nof emergency"
                  : "Help is in the way!\n Stay Strong",
              child: (alerted == null || alerted == false)
                  ? Image.asset(
                      "assets/images/alert.png",
                      width: 70,
                      height: 70,
                    )
                  : Image.asset(
                      "assets/images/alarm.png",
                      width: 70,
                      height: 70,
                    ),
              onPressed: (alertedCallBack) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                int pin = (prefs.getInt('pin') ?? -1111);
                print(pin);
                await prefs.reload();
                alerted = prefs.getBool("alerted");

                if (alertedCallBack) //turn on sos
                {
                  int pin = (prefs.getInt('pin') ?? -1111);
                  print('User $pin .');
                  if (pin == -1111) {
                    sendAlertSMS(false);
                  } else {
                    showPinModelBottomSheet(pin);
                  }
                } else {
                  sendAlertSMS(true); //turn off sos
                }
              },
              alerted: alerted,
            ).centered(),
            Row(
              children: [
                "Tools".text.size(20).bold.make(),
                5.widthBox,
                Divider().expand(),
              ],
            ),
            SingleChildScrollView(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        "Emergency",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Telephony.instance.dialPhoneNumber("100");
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "Police".text.bold.make(),
                              "100".text.make()
                            ],
                          ),
                        ),
                      ),
                      5.widthBox,
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Telephony.instance.dialPhoneNumber("1091");
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "Women Helpline".text.center.bold.make(),
                              "1091".text.make()
                            ],
                          ),
                        ),
                      ),
                      5.widthBox,
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          clipBehavior: Clip.antiAlias,
                          onPressed: () async {
                            await Telephony.instance.dialPhoneNumber("1291");
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "Senior Citizen Helpline".text.center.bold.make(),
                              "1291".text.make()
                            ],
                          ),
                        ),
                      ),
                      5.widthBox,
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Telephony.instance.dialPhoneNumber("101");
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "FIRE".text.center.bold.make(),
                              "101".text.make()
                            ],
                          ),
                        ),
                      ),
                      5.widthBox,
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Telephony.instance.dialPhoneNumber("102");
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "AMBULANCE".text.center.bold.make(),
                              "102".text.make()
                            ],
                          ),
                        ),
                      ),
                      5.widthBox,
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 5)),
                          onPressed: () async {
                            await Telephony.instance.dialPhoneNumber("112");
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "NATIONAL EMERGENCY NUMBER"
                                  .text
                                  .center
                                  .bold
                                  .make(),
                              "112".text.make()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: "Safe Places Nearby".text.size(20).make(),
                    ),
                  ],
                ),
                SizedBox(
                    height: 80,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () async {
                                await openGoogleMap("Police Stations near me");
                              },
                              child: "Police Stations".text.bold.make(),
                            ),
                          ),
                          5.widthBox,
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () async {
                                await openGoogleMap("Hospitals near me");
                              },
                              child: "Hospitals".text.bold.make(),
                            ),
                          ),
                          5.widthBox,
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () async {
                                await openGoogleMap("Pharmacies near me");
                              },
                              child: "Pharmacies".text.bold.make(),
                            ),
                          ),
                          5.widthBox,
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () async {
                                await openGoogleMap("Bus Stations near me");
                              },
                              child: "Bus Stations".text.bold.make(),
                            ),
                          ),
                          5.widthBox,
                        ])),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: "Location SafeGaurd".text.size(20).make(),
                    )
                  ],
                ),
                SafeHome(),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: "Saftey Tips".text.size(20).make(),
                    )
                  ],
                ),
                WomenSafteyTipsCarousel(),
              ]),
            ).expand(),
          ],
        ),
      ),
    );
  }

  checkPermission() async {
    appPermissions.PermissionStatus conPer =
        await appPermissions.Permission.contacts.status;
    appPermissions.PermissionStatus locPer =
        await appPermissions.Permission.location.status;
    appPermissions.PermissionStatus phonePer =
        await appPermissions.Permission.phone.status;
    appPermissions.PermissionStatus smsPer =
        await appPermissions.Permission.sms.status;
    if (conPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.contacts.request();
    }
    if (locPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.location.request();
    }
    if (phonePer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.phone.request();
    }
    if (smsPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.sms.request();
    }
    if (phonePer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.phone.request();
    }
  }

  Future<void> sendSMS(String number, String msgText) async {
    await Telephony.backgroundInstance.sendSms(to: number, message: msgText);
    // print(number);
    // print(msgText);
    // smsSender.SmsMessage msg = new smsSender.SmsMessage(number, msgText);
    // final smsSender.SmsSender sender = new smsSender.SmsSender();
    // msg.onStateChanged.listen((state) {
    //   if (state == smsSender.SmsMessageState.Sending) {
    //     Fluttertoast.showToast(
    //       msg: 'Sending Alert...',
    //       backgroundColor: Colors.blue,
    //     );
    //   } else if (state == smsSender.SmsMessageState.Sent) {
    //     Fluttertoast.showToast(
    //       msg: 'Alert Sent Successfully!',
    //       backgroundColor: Colors.green,
    //     );
    //   } else if (state == smsSender.SmsMessageState.Fail) {
    //     Fluttertoast.showToast(
    //       msg: 'Failure! Check your credits & Network Signals!',
    //       backgroundColor: Colors.red,
    //     );
    //   } else {
    //     Fluttertoast.showToast(
    //       msg: 'Failed to send SMS. Try Again!',
    //       backgroundColor: Colors.red,
    //     );
    //   }
    // });
    // sender.sendSms(msg);
  }

  sendAlertSMS(bool isAlert) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool("alerted", isAlert);
      alerted = isAlert;
    });
    checkPermission();

    // prefs.setBool("alerted", isAlert);
    List<String> numbers = prefs.getStringList("numbers") ?? [];

    LocationData? myLocation;
    String error;
    Location location = new Location();
    String link = '';
    try {
      myLocation = await location.getLocation();
      var currentLocation = myLocation;
      if (numbers.isEmpty) {
        setState(() {
          prefs.setBool("alerted", false);
          alerted = false;
        });
        return Fluttertoast.showToast(
          msg: 'No Contacts Found!',
          backgroundColor: Colors.red,
        );
      } else {
        String li =
            "http://maps.google.com/?q=${currentLocation.latitude},${currentLocation.longitude}";
        if (isAlert) {
          link = "Help Me! SOS \n$li";
        } else {
          Fluttertoast.showToast(
              msg: "Contacts are being notified about false SOS.");
          link = "I am safe, track me here\n$li";
          final service = FlutterBackgroundService();
          service.sendData({"action": "alertOff"});
        }

        for (int i = 0; i < numbers.length; i++) {
          sendSMS(numbers[i].split("***")[1], link);
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Please grant permission';
        print('Error due to Denied: $error');
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied- please enable it from app settings';
        print("Error due to not Asking: $error");
      }
      myLocation = null;

      prefs.setBool("alerted", false);

      setState(() {
        alerted = false;
      });
    }
  }

  showPinModelBottomSheet(int userPin) {
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                    ),
                    Text(
                      "Please enter you PIN!",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Expanded(
                      child: Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(20.0),
                  child: PinPut(
                    onSaved: (value) {
                      print(value);
                    },
                    fieldsCount: 4,
                    onSubmit: (String pin) =>
                        _showSnackBar(pin, context, userPin),
                    focusNode: _pinPutFocusNode,
                    controller: _pinPutController,
                    submittedFieldDecoration: _pinPutDecoration.copyWith(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    selectedFieldDecoration: _pinPutDecoration,
                    followingFieldDecoration: _pinPutDecoration.copyWith(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.deepPurpleAccent.withOpacity(.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _showSnackBar(String pin, BuildContext context, int userPin) {
    if (userPin == int.parse(pin)) {
      Fluttertoast.showToast(
        msg: 'We are glad that you are safe',
      );
      sendAlertSMS(false);
      _pinPutController.clear();
      _pinPutFocusNode.unfocus();
    } else {
      Fluttertoast.showToast(
        msg: 'Wrong Pin! Please try again',
      );
    }
  }
}

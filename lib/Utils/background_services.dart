import 'dart:async';

import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';

const simplePeriodicTask = "simplePeriodicTask";
void onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  String screenShake = "We are always with you!";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  service.onDataReceived.listen((event) async {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);

      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
    if (event["action"] == "alertOff") {
      screenShake = "We are always with you!";
    }
  });
  Location? _location;
  if (prefs.getBool("switchLocationNotify") ?? true) {
    try {
      await BackgroundLocation.setAndroidNotification(
        title: "Location tracking is running in the background!",
        message: "You can turn it off from settings inside the app",
        // icon: '@mipmap/ic_logo',
      );
    } catch (e) {}
  }

  BackgroundLocation.startLocationService(
    distanceFilter: 20,
  );

  BackgroundLocation.getLocationUpdates((location) async {
    print(location.altitude);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _location = location;

    await prefs.setStringList("location",
        [location.latitude.toString(), location.longitude.toString()]);
  });
  ShakeDetector.autoStart(
      shakeThresholdGravity: 3.7,
      onPhoneShake: () async {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate();
        }
        String link = '';
        try {
          double? lat = _location?.latitude;
          double? long = _location?.longitude;
          print("$lat ... $long");
          print("Test 9");
          link = "http://maps.google.com/?q=$lat,$long";
          // SharedPreferences prefs = await SharedPreferences.getInstance();

          List<String> numbers = prefs.getStringList("numbers") ?? [];

          String error;
          try {
            if (numbers.isEmpty) {
              screenShake = "No contacs found, Please call 15 ASAP.";
              debugPrint(
                'No Contacts Found!',
              );
              return;
            } else {
              for (int i = 0; i < numbers.length; i++) {
                Telephony.backgroundInstance.sendSms(
                    to: numbers[i].split("***")[1],
                    message: "Help Me! Track me here.\n$link");
              }
              prefs.setBool("alerted", true);
              FlutterBackgroundService().sendData(
                {"action": "setStateAlert"},
              );
              screenShake = "SOS alert Sent! Help is on the way.";
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
          }
          print("Test 10");
          print(link);
        } catch (e) {
          print("Test 11");
          print(e);
        }
      });
  print("Test 12");
  // bring to foreground

  service.setForegroundMode(true);
  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();

    service.setNotificationInfo(
      title: "Shake to SOS is enabled",
      content: screenShake,
    );

    // service.sendData(
    //   {"current_date": DateTime.now().toIso8601String()},
    // );
  });
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    String contact = inputData?['contact'];
    final prefs = await SharedPreferences.getInstance();
    print(contact);
    List<String>? location = prefs.getStringList("location");
    String link = "http://maps.google.com/?q=${location![0]},${location[1]}";
    print(location);
    print(link);
    Telephony.backgroundInstance
        .sendSms(to: contact, message: "I am on my way! Track me here.\n$link");
    return true;
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:raksha/Utils/background_services.dart';
import 'package:raksha/pages/settings/change_pin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool switchValue = false;
  Future<int> checkPIN() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int pin = (prefs.getInt('pin') ?? -1111);
    print('User $pin .');
    return pin;
  }

  @override
  void initState() {
    super.initState();
    checkService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.white,
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 40,
                color: Vx.black,
              ),
              10.widthBox,
              "Settings".text.size(35).bold.make()
            ],
          ),
          Row(
            children: [
              "SOS pin".text.size(20).make().p(12),
              Divider().expand()
            ],
          ),
          FutureBuilder(
              future: checkPIN(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePinScreen(
                              pin: int.parse(snapshot.data.toString())),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.password),
                      ),
                    ),
                    title: Text(snapshot.data == -1111
                        ? "Create SOS pin"
                        : "Change SOS pin"),
                    subtitle:
                        Text("SOS PIN is required to switch OFF the SOS alert"),
                    trailing: CircleAvatar(
                      radius: 7,
                      backgroundColor:
                          snapshot.data == -1111 ? Colors.red : Colors.white,
                      child: Center(
                        child: Card(
                            color: snapshot.data == -1111
                                ? Colors.orange
                                : Colors.white,
                            shape: CircleBorder(),
                            child: SizedBox(
                              height: 5,
                              width: 5,
                            )),
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              }),
          Row(
            children: [
              "Notifications".text.size(20).make().p(12),
              Divider().expand(),
            ],
          ),
          SwitchListTile(
            onChanged: (val) {
              setState(() {
                switchValue = val;
                controllSafeShake(val);
              });
            },
            value: switchValue,
            secondary: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Center(child: Icon(Icons.hail_rounded)),
            ),
            title: Text("Shake to SOS"),
            subtitle: Text("Shake devive to send SOS automotically"),
          ),
          Divider(
            indent: 40,
            endIndent: 40,
          ),
        ],
      ),
    );
  }

  Future<bool> checkService() async {
    bool running = await FlutterBackgroundService().isServiceRunning();
    setState(() {
      switchValue = running;
    });

    return running;
  }

  void controllSafeShake(bool val) async {
    if (val) {
      FlutterBackgroundService.initialize(onStart);
    } else {
      FlutterBackgroundService().sendData(
        {"action": "stopService"},
      );
    }
  }
}

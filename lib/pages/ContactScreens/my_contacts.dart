import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:raksha/pages/ContactScreens/phonebook_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:velocity_x/velocity_x.dart';

class MyContactsScreen extends StatefulWidget {
  const MyContactsScreen({Key? key}) : super(key: key);

  @override
  _MyContactsScreenState createState() => _MyContactsScreenState();
}

class _MyContactsScreenState extends State<MyContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Vx.red400,
        onPressed: () {
          Navigator.push(
                  context, MaterialPageRoute(builder: (context) => PhoneBook()))
              .whenComplete(() {
            setState(() {});
          });
        },
        child: Icon(Icons.add),
      ),
      backgroundColor: Color(0xFFFAFCFE),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "SOS Contacts",
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        // leading: IconButton(
        //   icon: Image.asset("assets/phone_red.png"),
        //   onPressed: () {},
        // )
      ),
      body: FutureBuilder(
          future: checkforContacts(),
          builder: (context, AsyncSnapshot<List<String>> snap) {
            if (snap.hasData && snap.data != null && snap.data!.isNotEmpty) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            indent: 20,
                            endIndent: 20,
                          ),
                        ),
                        Text("Swipe left to delete Contact"),
                        Expanded(
                          child: Divider(
                            indent: 20,
                            endIndent: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snap.data!.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: DrawerMotion(),
                            children: [
                              SlidableAction(
                                label: 'Delete',
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                onPressed: (context) {
                                  print('Delete');
                                  setState(() {
                                    Fluttertoast.showToast(
                                        msg:
                                            "${snap.data![index].split("***")[0] ?? "No Name"} removed!");
                                    snap.data!.remove(snap.data![index]);

                                    updateNewContactList(snap.data!);
                                  });
                                },
                              ),
                            ],
                            extentRatio: 0.25,
                          ),
                          child: Container(
                            color: Colors.white,
                            child: ListTile(
                              leading: Icon(
                                Icons.account_circle,
                                size: 40,
                              ),
                              title: Text(snap.data![index].split("***")[0]
                                  // ??                                  "No Name"
                                  ),
                              subtitle: Text(snap.data![index].split("***")[1]
                                  // ??
                                  //     "No Contact"
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              );
            } else {
              return Center(
                child: Text("No Contacts found!"),
              );
            }
          }),
    );
  }

  Future<List<String>> checkforContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contacts = prefs.getStringList("numbers") ?? [];
    print(contacts);
    return contacts;
  }

  updateNewContactList(List<String> contacts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("numbers", contacts);
    print(contacts);
  }
}

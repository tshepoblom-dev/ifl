import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/screens/enable_notifications.dart';
import 'package:gpspro/screens/maintenance.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/util/util.dart';
import 'package:gpspro/custom_widgets/AlertDialogCustom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gpspro/api/model/about.dart';
import 'package:gpspro/screens/web_view_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:gpspro/Config.dart';


class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //StreamController<Device> _postsController;
  bool isLoading = true;
  final TextEditingController _newPassword = new TextEditingController();
  final TextEditingController _retypePassword = new TextEditingController();

  int online = 0, offline = 0, unknown = 0;

  @override
  initState() {
    //_postsController = new StreamController();
    super.initState();
  }

  logout() {
    Traccar.sessionLogout()
        .then((value) => {UserRepository.doLogout(), Phoenix.rebirth(context)});
  }

@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: Text(('settings').tr,
            style: TextStyle(color: CustomColor.secondaryColor)),
        backgroundColor: CustomColor.primaryColor,
        bottom: TabBar(
          tabs: [
            Tab(text: ('settings').tr),
            Tab(text: ('about').tr),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _buildSettingsTab(),
          _buildAboutTab(),
        ],
      ),
    ),
  );
}
Widget _buildSettingsTab() {
  return Column(children: <Widget>[
    const Padding(
      padding: EdgeInsets.all(1.0),
    ),
    Padding(
      padding: const EdgeInsets.all(1.0),
      child: Card(
        elevation: 1.0,
        child: ListTile(
          title: Text(
            UserRepository.getUser().name ?? "",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            UserRepository.getUser().email ?? "",
            overflow: TextOverflow.ellipsis,
          ),
          trailing: OutlinedButton(
            onPressed: () {
              logout();
            },
            child: Text(("logout").tr, style: TextStyle(fontSize: 15)),
          ),
        ),
      ),
    ),
    Expanded(
      child: settings(),
    ),
  ]);
}
List<AboutModel> aboutList = [];

void loadAboutList() {
  if (aboutList.isEmpty) {
    aboutList.add(AboutModel(("termsAndCondition").tr, TERMS_AND_CONDITIONS));
    aboutList.add(AboutModel(("privacyPolicy").tr, PRIVACY_POLICY));
    aboutList.add(AboutModel(("contactUs").tr, CONTACT_US));
  }
}

Widget _buildAboutTab() {
  loadAboutList();
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          color: CustomColor.primaryColor,
          padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
          child: Column(
            children: <Widget>[
              Card(
                color: CustomColor.primaryColor,
                elevation: 30,
                child: Image.asset(
                  'images/logo.png',
                  height: 120.0,
                  fit: BoxFit.contain,
                ),
              ),
              Text(APP_NAME,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Text(EMAIL,
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              InkWell(
                onTap: () {
                  launchUrlString("tel://" + PHONE_NO);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child:
                            Icon(Icons.call, color: Colors.white, size: 14),
                      ),
                      TextSpan(
                        text: PHONE_NO,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: aboutList.length,
            itemBuilder: (context, index) {
              final aboutItem = aboutList[index];
              return Card(
                elevation: 1.0,
                child: InkWell(
                  onTap: () async {
                    if (aboutItem.title == ("whatsApp").tr) {
                      await launchUrlString(aboutItem.url!);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                            title: aboutItem.title!,
                            url: aboutItem.url!,
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
                        child: Text(
                          aboutItem.title!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15.0),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    ),
  );
}

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(('settings').tr,
              style: TextStyle(color: CustomColor.secondaryColor)),
          automaticallyImplyLeading: false, // Hides the back button
          backgroundColor: CustomColor.primaryColor,
        ),
        body: new Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(1.0),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: new Card(
              elevation: 1.0,
              child: ListTile(
                title: Text(
                  new String.fromCharCodes(
                      new Runes(UserRepository.getUser().name!)),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  new String.fromCharCodes(
                      new Runes(UserRepository.getUser().email!)),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: OutlinedButton(
                  onPressed: () {
                    logout();
                  },
                  child: Text(("logout").tr, style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ),
          new Expanded(
            child: settings(),
          ),
        ]));
  }*/

  Widget settings() {
    return new Card(
        elevation: 1.0,
        child: Column(
          children: <Widget>[
            /*ListTile(
              title: Text(
                ("notifications").tr,
                style: TextStyle(fontSize: 13),
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnableNotificationPage(),
                  ),
                );
              },
            ),
            Divider(),*/
            ListTile(
              title: Text(
                ("changePassword").tr,
                style: TextStyle(fontSize: 13),
              ),
              onTap: () {
                changePasswordDialog(context);
              },
            ),
            /*
            Divider(),
            ListTile(
              title: Text(
                ("userExpirationTime").tr,
                style: TextStyle(fontSize: 13),
              ),
              trailing: Text(
                UserRepository.getUser().expirationTime != null
                    ? Util()
                        .formatTime(UserRepository.getUser().expirationTime!)
                    : 'Not Found',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Divider(),
            ListTile(
                title: Text(
                  ("sharedMaintenance").tr,
                  style: TextStyle(fontSize: 13),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MaintenancePage(),
                    ),
                  );
                }),
            Divider(),*/
          ],
        ));
  }

  void changePasswordDialog(BuildContext context) {
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 220.0,
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            child: new TextField(
                              controller: _newPassword,
                              decoration: new InputDecoration(
                                  labelText: ('newPassword').tr),
                              obscureText: true,
                            ),
                          ),
                          new Container(
                            child: new TextField(
                              controller: _retypePassword,
                              decoration: new InputDecoration(
                                  labelText: ('retypePassword').tr),
                              obscureText: true,
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // background
                                  foregroundColor: Colors.white, // foreground
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  ('cancel').tr,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  updatePassword();
                                },
                                child: Text(
                                  ('ok').tr,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  void updatePassword() {
    if (_newPassword.text == _retypePassword.text) {
      final user = UserRepository.getUser();
      user.password = _newPassword.text;
      String userReq = json.encode(user.toJson());

      Traccar.updateUser(userReq, user.id.toString()).then((value) => {
            AlertDialogCustom().showAlertDialog(
                context,
                ('passwordUpdatedSuccessfully').tr,
                ('changePassword').tr,
                ('ok').tr)
          });
    } else {
      AlertDialogCustom().showAlertDialog(
          context, ('passwordNotSame').tr, ('failed').tr, ('ok').tr);
    }
  }
}

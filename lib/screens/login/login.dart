import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/api/model/user.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/screens/home.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _serverFilter = new TextEditingController();
  bool _obscureText = true;
bool _prefsLoaded = false;
  late SharedPreferences prefs; // <-- add this
  String? dropdownValue;
  String _url = "http://102.130.118.134:8082";
  String _email = "";
  String _password = "";
  String _notificationToken = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  int id = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isLoading = false;

  @override
  void initState() {
    //_serverFilter.addListener(_urlListen);
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
   // initFirebase();
    checkPreference();    
    super.initState();
  }

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.getToken().then((value) async {
      _notificationToken = value!;
      await UserRepository.prefs.setString("firebaseToken", _notificationToken);
     // final user = UserRepository.getUser();//.get(UserRepository.PREF_USER);
      // Update token on Traccar server
      // updateUserInfo(user, user.id.toString());
      });
 
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message.notification!.title); 
      _showNotification(message.notification!.title.toString(),
          message.notification!.body.toString());
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      sound: 'notify.aiff', // Use the file name added to your project
    );

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(APP_NAME, APP_NAME,
            importance: Importance.max,
            priority: Priority.high,
            icon: "ic_launcher",
            ticker: 'ticker');
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    await flutterLocalNotificationsPlugin
        .show(id++, title, body, notificationDetails, payload: 'item x');
  } 

  void checkPreference() async {
    await [
      Permission.location,
      Permission.notification,
    ].request();

    prefs = await SharedPreferences.getInstance();
    
    prefs.setString("url", _url);

    if (UserRepository.getLanguage() == "es") {
      dropdownValue = "Español";
    } else if (UserRepository.getLanguage() == "en") {
      dropdownValue = "English";
    } else if (UserRepository.getLanguage() == "pt") {
      dropdownValue = "Português";
    } else if (UserRepository.getLanguage() == "fr") {
      dropdownValue = "Français";
    } else if (UserRepository.getLanguage() == "ar") {
      dropdownValue = "العربية";
    } else if (UserRepository.getLanguage() == "fa") {
      dropdownValue = "فارسی";
    } else if (UserRepository.getLanguage() == "pl") {
      dropdownValue = "Polski";
    } else if (UserRepository.getLanguage() == "tr") {
      dropdownValue = "Türkçe";
    }
    //_serverFilter.text = UserRepository.getServerUrl();

    if (UserRepository.getEmail() != null) {
      _emailFilter.text = UserRepository.getEmail()!;
      _passwordFilter.text = UserRepository.getPassword()!;
      _serverFilter.text = prefs.getString('url')!;
      _loginPressed();
    } else {
      setState(() {});
    }
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  // Swap in between our two forms, registering and logging in
  void _formChange() async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: CustomColor.primaryColor,
        elevation: 0,
        title: Text(
          ('loginTitle').tr,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the back arrow color here
        ),
      ),
      body: new Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.0),
              children: <Widget>[
                Column(
                  children: <Widget>[_buildTextFields()],
                )
              ])),
    );
  }

  void showServerDialog(BuildContext context) {
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 170,
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
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text(('serverURl').tr),
                            ],
                          ),
                          new Container(
                            child: new TextField(
                              controller: _serverFilter,
                              decoration: new InputDecoration(
                                  labelText:
                                      'Server Url eg: http://demo.ifalcon.com'),
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.red, // background
                                  backgroundColor: Colors.white, // foreground
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
                                  UserRepository.setServerUrl(
                                      _serverFilter.text);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  ('ok').tr,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          )
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

  Widget _buildTextFields() {
    return new Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10.0),
      child: new Column(
        children: <Widget>[
          new Container(
            child: Image.asset(
              'images/logo.png',
              width: 200,
              height: 200,
            ),
          ),
          // new Container(
          //     child: DropdownButton<String>(
          //   value: dropdownValue,
          //   elevation: 16,
          //   style: TextStyle(color: CustomColor.primaryColor),
          //   underline: Container(
          //     height: 2,
          //     color: CustomColor.primaryColor,
          //   ),
          //   onChanged: (String? newValue) {
          //     setState(() {
          //       dropdownValue = newValue!;
          //       print(dropdownValue);
          //       if (newValue == "Français") {
          //         UserRepository.setLanguage("fr");
          //         Get.updateLocale(Locale("fr", ''));
          //       } else if (newValue == "Español") {
          //         UserRepository.setLanguage("es");
          //         Get.updateLocale(Locale("es", ''));
          //       } else if (newValue == "English") {
          //         UserRepository.setLanguage("en");
          //         Get.updateLocale(Locale("en", ''));
          //       } else if (newValue == "Português") {
          //         UserRepository.setLanguage("pt");
          //         Get.updateLocale(Locale("pt", ''));
          //       } else if (newValue == "العربية") {
          //         UserRepository.setLanguage("ar");
          //         Get.updateLocale(Locale("ar", ''));
          //       } else if (newValue == "فارسی") {
          //         UserRepository.setLanguage("fa");
          //         Get.updateLocale(Locale("fa", ''));
          //       } else if (newValue == "Polski") {
          //         UserRepository.setLanguage("pl");
          //         Get.updateLocale(Locale("pl", ''));
          //       } else if (newValue == "Türkçe") {
          //         UserRepository.setLanguage("tr");
          //         Get.updateLocale(Locale("tr", ''));
          //       }
          //     });
          //     Phoenix.rebirth(context);
          //   },
          //   items: <String>[
          //     "English",
          //     "Français",
          //     "Español",
          //     "Português",
          //     "العربية",
          //     "فارسی",
          //     "Polski",
          //     "Türkçe"
          //   ].map<DropdownMenuItem<String>>((String value) {
          //     return DropdownMenuItem<String>(
          //       value: value,
          //       child: Text(value),
          //     );
          //   }).toList(),
          // )),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          new Container(
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(labelText: ('username').tr),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(labelText: ('userPassword').tr),
              obscureText: false,
            ),
          ),
          _buildLoginButtons(),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              child: new Text(DEVELOPED_BY),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoginButtons() {
    if (_form == FormType.login) {
      return new Container(
        width: MediaQuery.of(context).size.width,
        child: new Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5),
            ),
            GestureDetector(
                onTap: () {
                  _loginPressed();
                },
                child: Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CustomColor.primaryColor,
                      border: Border.all(
                        color: CustomColor.primaryColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            ('loginTitle').tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800),
                          )
                        ]))),
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
          ],
        ),
      );
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              child: ElevatedButton(
                onPressed: () {
                  _createAccountPressed();
                },
                child: Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),
            new TextButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  Widget demoAndRegisterWidget() {
    return GestureDetector(
        onTap: () {},
        child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: CustomColor.primaryColor,
                border: Border.all(
                  color: CustomColor.primaryColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 15.0,
                    offset: Offset(2, 10.0),
                  )
                ]),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    ('demo').tr,
                    style: TextStyle(color: Colors.white),
                  )
                ])));
  }

  void _loginPressed() async {
    try {
      isLoading = true;
      Traccar.login(_email, _password).then((response) async {
        if (response != null) {
          if (response.statusCode == 200) {
            UserRepository.setUser(response.body);
            isLoading = false;
            User user = User.fromJson(jsonDecode(response.body));
            await initFirebase().then((_) => updateUserInfo(user, user.id.toString()));
            
            Navigator.of(context, rootNavigator: true)
                .pop(); // dismisses only the dialog and returns nothing
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          } else if (response.statusCode == 401) {
            isLoading = false;
            Fluttertoast.showToast(
                msg: ("loginFailed").tr,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {});
          } else if (response.statusCode == 400) {
            if (response.body ==
                "Account has expired - SecurityException (PermissionsManager:259 < *:441 < SessionResource:104 < ...)") {
              setState(() {});
              showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title: Text(("failed").tr),
                  content: Text(("loginFailed").tr),
                  actions: <Widget>[
                    new TextButton(
                      onPressed: () {
                        isLoading = false;
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // dismisses only the dialog and returns nothing
                      },
                      child: new Text(("ok").tr),
                    ),
                  ],
                ),
              );
            }
          } else {
            isLoading = false;
            Fluttertoast.showToast(
                msg: response.body,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {});
          }
        } else {
          setState(() {});
          isLoading = false;
          Fluttertoast.showToast(
              msg: ("errorMsg").tr,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    } catch (e) {
      isLoading = false;
      setState(() {});
    }
  }

  void _createAccountPressed() {
    print('The user wants to create an account with $_email and $_password');
  }
/*
  void updateUserInfo(User user, String id) {
    var oldToken = user.attributes!["notificationTokens"].toString().split(",");
    var tokens = user.attributes!["notificationTokens"];

    if (user.attributes!.containsKey("notificationTokens")) {
      if (!oldToken.contains(_notificationToken)) {
        user.attributes!["notificationTokens"] =
            _notificationToken + "," + tokens;
      }
    } else {
      user.attributes!["notificationTokens"] = _notificationToken;
    }

    String userReq = json.encode(user.toJson());

    Traccar.updateUser(userReq, id).then((value) => {});
  }
 void updateUserInfo(User user, String id) {
  if (_notificationToken.isEmpty) return;

  final Set<String> tokenSet = {};

  // Extract existing tokens
  if (user.attributes != null && user.attributes!.containsKey("notificationTokens")) {
    final raw = user.attributes!["notificationTokens"].toString();
    final existingTokens = raw.split(",").where((token) => token.trim().isNotEmpty);
    tokenSet.addAll(existingTokens);
  } else {
    user.attributes ??= {};
  }

  // Add new token if not already present
  tokenSet.add(_notificationToken);

  // Save cleaned token list
  user.attributes!["notificationTokens"] = tokenSet.join(",");

  final userReq = json.encode(user.toJson());
  Traccar.updateUser(userReq, id).then((value) {
    print("User updated with tokens: ${tokenSet.length}");
  });
}*/
void updateUserInfo(User user, String id) {
  if (_notificationToken.isEmpty) return;

  // Ensure attributes map exists
  user.attributes ??= {};

  // Overwrite with the new token
  user.attributes!["notificationTokens"] = _notificationToken;

  final userReq = json.encode(user.toJson());

  Traccar.updateUser(userReq, id).then((value) {
    print("User updated with latest notification token");
  });
}


/*void updateFirebaseNotificationToken2(User user, String id) {
  Map<String, dynamic> tokensMap = {};

  if (user.attributes != null && user.attributes!["notificationTokens"] != null) {
    try {
      tokensMap = jsonDecode(user.attributes!["notificationTokens"]);
    } catch (_) {
      // fallback if it's a legacy string format
      tokensMap = {};
    }
  } else {
    user.attributes = HashMap();
  }

  // Identify this device/platform
  String deviceId = Platform.operatingSystem + "_" + const Uuid().v4().substring(0, 8);

  tokensMap[deviceId] = _notificationToken;

  user.attributes!["notificationTokens"] = jsonEncode(tokensMap);

  String userReq = json.encode(user.toJson());

  Traccar.updateUser(userReq, id).then((value) {
    print("Firebase token map updated to Traccar.");
  }).catchError((e) {
    print("Failed to update token: $e");
  });
}*/

}

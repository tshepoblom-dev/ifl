import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/api/model/user.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/screens/home.dart';
import 'package:gpspro/screens/login/login.dart';
import 'package:gpspro/screens/login/loginChoose.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:permission_handler/permission_handler.dart';


class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with WidgetsBindingObserver {
  String _notificationToken = "";
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

  @override
  void initState() {
    super.initState();
    checkPreference();
  }

  void checkPreference() async {
    await [
      Permission.location,
      Permission.notification,
    ].request();
    if (UserRepository.getEmail() != null) {
     //
    //  await initFirebase();
      checkLogin();
      
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginChooseScreen(),
        ),
      );
    }
  }

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging
        .getToken()
        .then((value) => {print(value), _notificationToken = value!});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message.notification!.title);
      print(message.notification!.body);
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

  void checkLogin() {
    Traccar.login(UserRepository.getEmail(), UserRepository.getPassword())
        .then((response) async{
      if (response != null) {
        if (response.statusCode == 200) {
          UserRepository.setUser(response.body);
          final user = User.fromJson(jsonDecode(response.body));
          await initFirebase().then((_) => updateUserInfo(user, user.id.toString()));
          //updateUserInfo(user, user.id.toString());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      }
    });
  }
/*
  void updateUserInfo(User user, String id) {
    if (user.attributes != null) {
      var oldToken =
          user.attributes!["notificationTokens"].toString().split(",");
      var tokens = user.attributes!["notificationTokens"];

      if (user.attributes!.containsKey("notificationTokens")) {
        if (!oldToken.contains(_notificationToken)) {
          user.attributes!["notificationTokens"] =
              _notificationToken + "," + tokens;
        }
      } else {
        user.attributes!["notificationTokens"] = _notificationToken;
      }
    } else {
      user.attributes = new HashMap();
      user.attributes?["notificationTokens"] = _notificationToken;
    }

    String userReq = json.encode(user.toJson());

    Traccar.updateUser(userReq, id).then((value) => {});
  }
*
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
}
*/
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


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            child: new Column(children: <Widget>[
              new Image.asset(
                'images/logo.png',
                height: 250.0,
                fit: BoxFit.contain,
              ),
              Padding(
                padding: EdgeInsets.all(20),
              ),
              Text(SPLASH_SCREEN_TEXT1,
                  style:
                      TextStyle(color: CustomColor.primaryColor, fontSize: 20)),
              Text(SPLASH_SCREEN_TEXT2,
                  style:
                      TextStyle(color: CustomColor.primaryColor, fontSize: 15)),
              Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            ]),
          ),
        ],
      ),
    );
  }
}

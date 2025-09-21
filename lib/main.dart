import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpspro/api/model/user.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/firebase_options.dart';
import 'package:gpspro/locale/translation_service.dart';
import 'package:gpspro/screens/splash_screen.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:gpspro/theme.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:gpspro/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  UserRepository.prefs = await SharedPreferences.getInstance();
  
  runApp(Phoenix(child: MyApp()));
}

//late SharedPreferences prefs;
String langCode = "en";
Locale? _locale;

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MyAppPageState();
}

class _MyAppPageState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    checkPreference();
    requestNotificationPermission();

  }
 /* 
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showFlutterNotification(message);
}*/
 Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
  Future<String> checkPreference() async {
    if (UserRepository.getLanguage() == null) {
      UserRepository.setLanguage("en");
      _locale = TranslationService.locale;
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      langCode = UserRepository.getLanguage()!;
      _locale = Locale(langCode);
    }
    return langCode;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: CustomColor.primaryColor,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor:
          CustomColor.primaryColor, // Navigation bar color
    ));

    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme =
        Util().createTextTheme(context, "Open Sans", "Open Sans");

    MaterialTheme theme = MaterialTheme(textTheme);

    return GetMaterialApp(
      enableLog: true,
      locale: _locale,
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: SplashScreenPage(),
      logWriterCallback: (String text, {bool isError = false}) {
        if (isError) {
          debugPrint('\x1B[31m🔥 ERROR: $text\x1B[0m'); // Red for errors
        } else if (text.contains('translation')) {
          debugPrint(
              '\x1B[34m🌍 Translation Log: $text\x1B[0m'); // Blue for translations
        } else if (text.contains('navigation')) {
          debugPrint(
              '\x1B[32m🚀 Navigation Log: $text\x1B[0m'); // Green for navigation
        } else {
          debugPrint(
              '\x1B[36m📌 GetX Log: $text\x1B[0m'); // Cyan for general logs
        }
      },
    );
  }

  /*
// Handle tap on notification (in-app navigation logic)
void handleNotificationClick(RemoteMessage message) {
  final data = message.data;
  final link = data['link']; // Custom FCM payload link
  if (link != null) {
    // TODO: implement navigation logic based on link
    debugPrint("User clicked notification: $link");
  }
}

// Setup Firebase messaging + permissions + notification channel
Future<void> setupFlutterNotifications() async {
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.requestPermission();
  }

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for critical notifications',
    importance: Importance.high,
    playSound: true,
  );

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iOSInit = DarwinInitializationSettings();
  final initSettings = InitializationSettings(android: androidInit, iOS: iOSInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings,
    onDidReceiveNotificationResponse: (details) {
      // Handle interaction
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Optionally log or send token to server
  await FirebaseMessaging.instance.getToken().then((token){
     //save token
     _notificationToken = token ?? '';
     prefs.setString("firebaseToken", _notificationToken);
//     User user = UserRepository.getUser();
     updateUserInfo(currentUser, currentUser.id.toString());
  });  

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message.notification!.title); 
      showFlutterNotification(message);
    });

    // TODO: POST token to your backend or Traccar API
  }

  // Display notification
  void showFlutterNotification(RemoteMessage message) {   

    RemoteNotification? notification = message.notification;

    if (notification != null && Platform.isAndroid) {
      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        ticker: 'ticker'
      );

      const iosDetails = DarwinNotificationDetails();

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: jsonEncode(message.data),
      );
    }
  }
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
  }*/
}
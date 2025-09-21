import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gpspro/screens/About.dart';
import 'package:gpspro/screens/Settings.dart';
import 'package:gpspro/screens/dashboard/dashboard.dart';
import 'package:gpspro/screens/device/devices.dart';
import 'package:gpspro/screens/map_home.dart';
import 'package:gpspro/theme/CustomColor.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;
  late String email;
  late String password;
  List<String>? devicesId = [];

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() async {
      return await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(("areYouSure").tr),
          content: Text(("doYouWantToExit").tr),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(("no").tr),
            ),
            ElevatedButton(
              onPressed: () => {SystemNavigator.pop()},
              /*Navigator.of(context).pop(true)*/
              child: Text(("yes").tr),
            ),
          ],
        ),
      );
    }

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: <Widget>[
              MapPage(),
              DevicePage(),
              DashboardPage(),
              SettingsPage(),
            //  AboutPage()
            ],
          ),
          bottomNavigationBar: GNav(
            haptic: true, // haptic feedback
            tabBorderRadius: 30,
            duration: Duration(milliseconds: 200), // tab animation duration
            gap: 8, // the tab button gap between icon and text
            color: Colors.white,
            activeColor:
            CustomColor.primaryColor, // selected icon and text color
            iconSize: 24, // tab button icon size
            tabBackgroundColor:
            Colors.white, // selected icon and text color

            // tabShadow: [BoxShadow(color: CustomColor.primaryColor.withOpacity(0.5), blurRadius: 8)], // tab button shadow
            padding: EdgeInsets.all(11), // navigation bar padding
            tabMargin: EdgeInsets.only(top: 5, bottom: 5),
            backgroundColor: CustomColor.primaryColor,
            tabs: [
              GButton(
                icon: Icons.map,
                text: "map".tr,
              ),
              GButton(
                icon: Icons.directions_car_rounded,
                text: "devices".tr,
              ),
              GButton(
                icon: Icons.notifications,
                text: "notifications".tr,
              ),
              GButton(
                icon: Icons.settings,
                text: "settings".tr,
              ),
             /* GButton(
                icon: Icons.info,
                text: "about".tr,
              ),*/
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ));
  }
}

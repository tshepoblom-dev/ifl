import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/screens/home.dart';
import 'package:gpspro/screens/login/login.dart';
import 'package:gpspro/theme/CustomColor.dart';

class LoginChooseScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginChooseScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                colors: [
                  CustomColor
                      .secondaryColor, // Replace with your  gradient end color
                  CustomColor
                      .secondaryColor, // Replace with your  gradient end color
                  CustomColor
                      .primaryColor, // Replace with your gradient start color
                ],
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          'Welcome to iFalconTrace',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CustomColor
                                .primaryColor, // Replace with your gradient start color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Spacer(),
                      Image.asset(
                        "images/logo.png",
                        width: 200,
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                backgroundColor:
                                    Colors.white, // Button background color
                                foregroundColor:
                                    CustomColor.primaryColor, // Text color
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                           /* SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                _loginPressed();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                backgroundColor: Colors
                                    .transparent, // Transparent background
                                foregroundColor: Colors.white, // Text color
                                side: BorderSide(color: Colors.white, width: 2),
                              ),
                              child: Text(
                                'Demo',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                      SizedBox(height: 50), // Add spacing from the bottom
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _loginPressed() async {
    try {
      Traccar.login("demo", "demo").then((response) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      });
    } catch (e) {
      setState(() {});
    }
  }
}

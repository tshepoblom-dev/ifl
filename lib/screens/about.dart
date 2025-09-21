import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/api/model/about.dart';
import 'package:gpspro/screens/web_view_screen.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<AboutModel> aboutList = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (aboutList.isEmpty) {
      aboutList
          .add(new AboutModel(("termsAndCondition").tr, TERMS_AND_CONDITIONS));
      aboutList.add(new AboutModel(("privacyPolicy").tr, PRIVACY_POLICY));
      aboutList.add(new AboutModel(("contactUs").tr, CONTACT_US));
     // aboutList.add(new AboutModel(("Telegram").tr, WHATS_APP));
    }
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            color: CustomColor.primaryColor,
            padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
            child: new Column(children: <Widget>[
              Card(
                  color: CustomColor.primaryColor,
                  elevation: 30,
                  child: new Image.asset(
                    'images/logo.png',
                    height: 120.0,
                    fit: BoxFit.contain,
                  )),
              Text(APP_NAME,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Text(EMAIL, style: TextStyle(color: Colors.white, fontSize: 13)),
              InkWell(
                onTap: () {
                  launchUrlString("tel://" + PHONE_NO);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.call, color: Colors.white, size: 14),
                      ),
                      TextSpan(
                        text: PHONE_NO,
                      ),
                    ],
                  ),
                ),
              )
            ]),
          ),
          Container(
              color: Colors.white,
              child: new Column(
                children: <Widget>[
                  aboutList.isNotEmpty ? loadList() : new Container()
                ],
              ))
        ],
      ),
    );
  }

  Widget loadList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: aboutList.length,
      itemBuilder: (context, index) {
        final urlItem = aboutList[index];
        return new Container(
            padding: const EdgeInsets.all(1.0), child: itemCardList(urlItem));
      },
    );
  }

  Widget itemCardList(AboutModel aboutItem) {
    return new Card(
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
                          title: aboutItem.title!, url: aboutItem.url!)));
            }
          },
          child: Row(
            children: <Widget>[
              new Container(
                padding: EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
                child: Text(aboutItem.title!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.0,
                    )),
              )
            ],
          ),
        ));
  }
}

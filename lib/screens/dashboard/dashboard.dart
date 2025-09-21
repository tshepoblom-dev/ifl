import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/event.dart';
import 'package:gpspro/util/util.dart';
import 'package:gpspro/storage/dataController/DataController.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../event_map.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Event> eventList = [];
  Map<int, Device> devices = new HashMap();
  var deviceId = [];
  bool isLoading = true;
  bool isEventLoading = true;
  late Locale myLocale;

  int online = 0, offline = 0, unknown = 0;

  @override
  initState() {
    super.initState();
    
  }

  void getDevice(DataController controller) {
    if (devices.isEmpty) {
      controller.devices.forEach((key, element) {
        devices.putIfAbsent(element.id!, () => element);
        deviceId.add(element.id.toString());
        if (element.status == "online") {
          online++;
        } else if (element.status == "offline") {
          offline++;
        } else if (element.status == "unknown") {
          unknown++;
        }
      });
      isLoading = false;
    }
  }
double calculatePercent(int part, int total) {
  if (total == 0) return 0.0;
  return part / total;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(('dashboard').tr,
              style: TextStyle(color: CustomColor.secondaryColor)),
          automaticallyImplyLeading: false, // Hides the back button
          backgroundColor: CustomColor.primaryColor,
        ),
        body: GetX<DataController>(
            init: DataController(),
            builder: (controller) {
              getDevice(controller);
              return loadView(controller);
            }));
  }

  Widget loadView(DataController controller) {
    return Column(
      children: <Widget>[
        SizedBox(height: 5),
        Text(("deviceStatus").tr, style: TextStyle(fontSize: 17)),
        SizedBox(
          height: 20,
        ),
        IntrinsicHeight(
          child: Container(
            width: MediaQuery.of(context).size.width / 1,
            child: chart(),
          ),
        ),
        new Divider(height: 0.1),
        SizedBox(height: 5),
        Text(("recentEvents").tr, style: TextStyle(fontSize: 17)),
        SizedBox(height: 5),
        Expanded(child: loadEvents(controller)),
        /*
        controller.events.length > 0
            ? Expanded(child: loadEvents(controller))
            : Container()*/
      ],
    );
  }

 Widget loadEvents(DataController controller) {
  if (controller.isEventLoading.value) {
    return Center(child: CircularProgressIndicator());
  }
/*
  if (controller.events.isEmpty) {
    return Center(
      child: Text(
        'No events found',
        style: TextStyle(fontSize: 14.0, color: Colors.grey),
      ),
    );
  }*/

  return ListView.builder(
    itemCount: controller.events.length,
    itemBuilder: (context, index) {
      final eventItem = controller.events[index];
      String result = "";

      if (eventItem.attributes != null) {
        if (eventItem.type == "alarm" && eventItem.attributes!.containsKey("alarm")) {
          result = eventItem.attributes!["alarm"].toString();
        } else if (eventItem.attributes!.containsKey("result")) {
          result = eventItem.attributes!["result"].toString();
        }
      }

      // Skip connectivity events
      //if (["deviceOffline", "deviceOnline", "deviceUnknown"].contains(eventItem.type)) {
       // return SizedBox.shrink();
      //}

      final device = controller.devices[eventItem.deviceId];

      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventMapPage(
                eventItem.id!,
                eventItem.positionId!,
                eventItem.attributes ?? {},
                eventItem.type!,
                device?.name ?? 'Unknown Device',
              ),
            ),
          );
        },
        child: Card(
          elevation: 3.0,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (device != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        device.name!,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Util().formatTime(eventItem.eventTime ?? ''),
                        style: TextStyle(fontSize: 10.0, color: Colors.grey),
                      ),
                    ],
                  ),
                SizedBox(height: 4),
                Text(
                  (eventItem.type!).tr + (result.isNotEmpty ? " • $result" : ""),
                  style: TextStyle(fontSize: 12.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Widget chart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
            width: 100,
            child: CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 13.0,
              animation: true,
              percent: calculatePercent(online, deviceId.length),
              center: new Text(
                online.toString(),
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              footer: new Text(
                ("online").tr,
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.green,
            )),
        Container(
            width: 100,
            child: CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 13.0,
              animation: true,
              percent: calculatePercent(unknown, deviceId.length),
              center: new Text(
                unknown.toString(),
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              footer: new Text(
                ("unknown").tr,
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.yellow,
            )),
        Container(
            width: 100,
            child: CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 13.0,
              animation: true,
              percent: calculatePercent(offline, deviceId.length),
              center: new Text(
                offline.toString(),
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              footer: new Text(
                ("offline").tr,
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.red,
            )),
      ],
    );
  }
}
/*
class Task {
  String task;
  int taskvalue;
  Color colorval;

  Task(this.task, this.taskvalue, this.colorval);
}
*/
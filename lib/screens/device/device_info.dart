import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/position.dart';
import 'package:gpspro/util/util.dart';
import 'package:gpspro/theme/CustomColor.dart';

class DeviceInfo extends StatefulWidget {
  final int id;
  final String name;
  final Device device;
  final Position? positionModel;

  const DeviceInfo(
      {super.key,
      required this.name,
      required this.device,
      required this.positionModel,
      required this.id});

  @override
  _DeviceInfoState createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name,
              style: TextStyle(color: CustomColor.secondaryColor)),
          iconTheme: IconThemeData(
            color: CustomColor.secondaryColor, //change your color here
          ),
          automaticallyImplyLeading: false, // Hides the back button
          backgroundColor: CustomColor.primaryColor,
        ),
        body: SingleChildScrollView(child: loadDevice()));
  }

  Widget loadDevice() {
    Device? d = widget.device;
    String iconPath = "images/marker_default_offline.png";

    String status;

    if (d.status == "unknown") {
      status = 'static';
    } else {
      status = d.status!;
    }

    if (d.category != null) {
      iconPath = "images/marker_" + d.category! + "_" + status + ".png";
    } else {
      iconPath = "images/marker_default" + "_" + status + ".png";
    }
    return new Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(1.0),
        ),
        new Container(
          child: new Padding(
            padding: const EdgeInsets.all(1.0),
            child: new Card(
              elevation: 5.0,
              child: Column(children: <Widget>[
                Container(
                    child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 10.0, left: 5.0),
                      child: Image.asset(
                        iconPath,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    Container(
                        width: 200,
                        padding: EdgeInsets.only(top: 10.0, left: 5.0),
                        child: Text(
                          d.status!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                )),
                SizedBox(height: 5.0),
              ]),
            ),
          ),
        ),
        Container(child: positionDetails()),
        Container(child: Text("Sensors", style: TextStyle(fontSize: 16))),
        Container(child: sensorInfo())
      ],
    );
  }

  Widget positionDetails() {
    if (widget.positionModel != null) {
      return Card(
        elevation: 5.0,
        child: Column(children: <Widget>[
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.bookmark,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Text(('deviceType').tr),
                      ),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child: Text(widget.device.model == null
                      ? ('noData').tr
                      : widget.device.model!)),
            ],
          )),
          SizedBox(height: 5.0),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.gps_fixed,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 3.0),
                          child: Text(('positionLatitude').tr)),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child:
                      Text(widget.positionModel!.latitude!.toStringAsFixed(5))),
            ],
          )),
          SizedBox(height: 5.0),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.gps_fixed,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Text(('positionLongitude').tr),
                      ),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child: Text(
                      widget.positionModel!.longitude!.toStringAsFixed(5))),
            ],
          )),
          SizedBox(height: 5.0),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.av_timer,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 3.0),
                          child: Text(('positionSpeed').tr))
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child:
                      Text(Util().convertSpeed(widget.positionModel!.speed!))),
            ],
          )),
          SizedBox(height: 5.0),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.directions,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 3.0),
                          child: Text(('positionCourse').tr))
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child: Text(
                      Util().convertCourse(widget.positionModel!.course!))),
            ],
          )),
          SizedBox(height: 5.0),
          widget.positionModel!.address != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Icon(Icons.location_on_outlined,
                          color: CustomColor.primaryColor, size: 25.0),
                    ),
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0, left: 5.0, right: 0),
                                child: Text(
                                  widget.positionModel!.address!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ]),
                    )
                  ],
                )
              : new Container(),
          SizedBox(height: 5.0),
        ]),
      );
    } else {
      return Container(
        child: Text(('noData').tr),
      );
    }
  }
Widget sensorInfo() {
  if (widget.positionModel != null) {
    Map<String, dynamic> attributes = widget.positionModel!.attributes!;
    List<Widget> sensorFields = [];
    List<Widget> driverFields = [];
    List<Widget> vehicleFields = [];

    List<String> sensorKeys = ["totalDistance", "distance", "hours", "ignition"];
    List<String> driverKeys = ["Driver"];
    List<String> vehicleKeys = ["Number_Plate", "Registration_Number", "Engine_Number", "VIN", "Year", "Color"];

    Widget buildField(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(value, textAlign: TextAlign.end)),
          ],
        ),
      );
    }

    attributes.forEach((key, value) {
      if (sensorKeys.contains(key)) {
        if (key == "totalDistance" || key == "distance") {
          sensorFields.add(buildField(key.tr, Util().convertDistance(value)));
        } else if (key == "hours") {
          sensorFields.add(buildField(key.tr, Util().convertDuration(value)));
        } else if (key == "ignition") {
          sensorFields.add(buildField(key.tr, (value.toString()).tr));
        }
      } else if (driverKeys.contains(key)) {
        driverFields.add(buildField(key.tr, value.toString()));
      } else if (vehicleKeys.contains(key)) {
        vehicleFields.add(buildField(key.tr, value.toString()));
      }
    });

    Widget buildSection(String title, List<Widget> fields) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade50, // Light orange background
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.orange.shade200), // Light orange border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            const Divider(color: Colors.orange),
            ...fields,
          ],
        ),
      );
    }

    return Card(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (driverFields.isNotEmpty) buildSection("Driver Details", driverFields),
            if (vehicleFields.isNotEmpty) buildSection("Vehicle Details", vehicleFields),
            if (sensorFields.isNotEmpty) ...[
              const Text("Sensor Stats", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              ...sensorFields,
            ],
          ],
        ),
      ),
    );
  } else {
    return Container();
  }
}

}

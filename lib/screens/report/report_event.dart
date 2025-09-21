import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/event.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/util/util.dart';

class ReportEventPage extends StatefulWidget {
  final int id;
  final String from;
  final String to;
  final String name;
  final Device device;
  ReportEventPage(this.id, this.from, this.to, this.name, this.device);
  @override
  State<StatefulWidget> createState() => new _ReportEventPageState();
}

class _ReportEventPageState extends State<ReportEventPage> {
  List<Event> _eventList = [];
  late StreamController<int> _postsController;
  bool isLoading = true;
  late GoogleMapController mapController;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  getReport() {
    // ignore: unnecessary_null_comparison
    Traccar.getEvents(widget.id.toString(), widget.from, widget.to)
        .then((value) => {
              _eventList.addAll(value!),
              _postsController.add(1),
              isLoading = false,
              setState(() {})
            });
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
      ),
      body: StreamBuilder<int>(
          stream: _postsController.stream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              return loadReportView();
            } else if (isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Text(('noData').tr),
              );
            }
          }),
    );
  }

  Widget loadReportView() {
    return ListView.builder(
      itemCount: _eventList.length,
      itemBuilder: (context, index) {
        final event = _eventList[index];
        return reportRow(event, context);
      },
    );
  }

  Widget reportRow(Event e, BuildContext context) {
    return InkWell(
        onTap: () {
          // Navigator.pushNamed(context, "/eventMap",
          //     arguments: ReportEventArgument(
          //         e.id!, e.positionId!, e.attributes!, e.type!, widget.name));
        },
        child: Card(
            child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.only(top: 3.0, left: 5.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(left: 3.0),
                                  child: Icon(Icons.event_note,
                                      color: CustomColor.primaryColor,
                                      size: 20.0),
                                ),
                              ],
                            )),
                        Container(
                            padding: EdgeInsets.only(
                                top: 5.0, left: 5.0, right: 10.0),
                            child: Text((e.type!).tr)),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.only(top: 3.0, left: 5.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: Icon(Icons.access_time_outlined,
                                      color: CustomColor.primaryColor,
                                      size: 15.0),
                                ),
                              ],
                            )),
                        Container(
                            padding: EdgeInsets.only(
                                top: 5.0, left: 5.0, right: 10.0),
                            child: Text(
                              Util().formatTime(e.eventTime!),
                              style: TextStyle(fontSize: 11),
                            )),
                      ],
                    ),
                  ],
                ))));
  }
}

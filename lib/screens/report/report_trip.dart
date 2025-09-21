import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/trip.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/util/util.dart';
import 'package:gpspro/theme/CustomColor.dart';

class ReportTripPage extends StatefulWidget {
  final int id;
  final String from;
  final String to;
  final String name;
  final Device device;
  ReportTripPage(this.id, this.from, this.to, this.name, this.device);
  @override
  State<StatefulWidget> createState() => new _ReportTripPageState();
}

class _ReportTripPageState extends State<ReportTripPage> {
  List<Trip> _tripList = [];
  late StreamController<int> _postsController;
  bool isLoading = true;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  getReport() {
    Traccar.getTrip(widget.id.toString(), widget.from, widget.to)
        .then((value) => {
              _tripList.addAll(value!),
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
              return loadReport();
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

  Widget loadReport() {
    return ListView.builder(
      itemCount: _tripList.length,
      itemBuilder: (context, index) {
        final trip = _tripList[index];
        return reportRow(trip);
      },
    );
  }

  Widget reportRow(Trip t) {
    return Card(
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(("reportStartTime").tr,
                        style: TextStyle(color: Colors.green)),
                    Text(("reportEndTime").tr,
                        style: TextStyle(color: Colors.red))
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      Util().formatTime(t.startTime!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      Util().formatTime(t.endTime!),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      ("positionOdometer").tr +
                          ": " +
                          Util().convertDistance(t.startOdometer!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      ("positionOdometer").tr +
                          ": " +
                          Util().convertDistance(t.endOdometer!),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      ("positionDistance").tr +
                          ": " +
                          Util().convertDistance(t.distance!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      ("reportAverageSpeed").tr +
                          ": " +
                          Util().convertSpeed(t.averageSpeed!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      ("reportMaximumSpeed").tr +
                          ": " +
                          Util().convertSpeed(t.maxSpeed!),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      ("reportDuration").tr +
                          ": " +
                          Util().convertDuration(t.duration!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      ('reportSpentFuel').tr + ": " + t.spentFuel.toString(),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                t.startAddress != null
                    ? Row(
                        children: [
                          Expanded(
                              child: Text(
                            ('reportStartAddress').tr +
                                ": " +
                                utf8.decode(t.startAddress!.codeUnits),
                            style: TextStyle(fontSize: 11),
                          )),
                        ],
                      )
                    : new Container(),
                t.endAddress != null
                    ? Row(
                        children: [
                          Expanded(
                              child: Text(
                            ('reportEndAddress').tr +
                                ": " +
                                utf8.decode(t.endAddress!.codeUnits),
                            style: TextStyle(fontSize: 11),
                          )),
                        ],
                      )
                    : new Container(),
              ],
            )));
  }
}

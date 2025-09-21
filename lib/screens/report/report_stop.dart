import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/stop.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/util/util.dart';
import 'package:gpspro/theme/CustomColor.dart';

class ReportStopPage extends StatefulWidget {
  final int id;
  final String from;
  final String to;
  final String name;
  final Device device;
  ReportStopPage(this.id, this.from, this.to, this.name, this.device);
  @override
  State<StatefulWidget> createState() => new _ReportStopPageState();
}

class _ReportStopPageState extends State<ReportStopPage> {
  List<Stop> _stopList = [];
  late StreamController<int> _postsController;
  bool isLoading = true;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  getReport() {
    Traccar.getStops(widget.id.toString(), widget.from, widget.to)
        .then((value) => {
              _stopList.addAll(value!),
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
      itemCount: _stopList.length,
      itemBuilder: (context, index) {
        final stop = _stopList[index];
        return reportRow(stop);
      },
    );
  }

  Widget reportRow(Stop s) {
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
                      Util().formatTime(s.startTime!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      Util().formatTime(s.endTime!),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      ('positionOdometer').tr +
                          ": " +
                          Util().convertDistance(s.startOdometer!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      ('positionOdometer').tr +
                          ": " +
                          Util().convertDistance(s.endOdometer!),
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
                      ('reportDuration').tr +
                          ": " +
                          Util().convertDuration(s.duration!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      ('reportEngineHours').tr +
                          ": " +
                          Util().convertDuration(s.engineHours!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      ('reportSpentFuel').tr + ": " + s.spentFuel.toString(),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                s.address != null
                    ? Row(
                        children: [
                          Expanded(
                              child: Text(
                            ('positionAddress').tr +
                                ": " +
                                utf8.decode(s.address!.codeUnits),
                            style: TextStyle(fontSize: 11),
                          )),
                        ],
                      )
                    : new Container(),
              ],
            )));
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/summary.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/util/util.dart';
import 'package:gpspro/theme/CustomColor.dart';

class ReportSummaryPage extends StatefulWidget {
  final int id;
  final String from;
  final String to;
  final String name;
  final Device device;
  ReportSummaryPage(this.id, this.from, this.to, this.name, this.device);
  @override
  State<StatefulWidget> createState() => new _ReportSummaryPageState();
}

class _ReportSummaryPageState extends State<ReportSummaryPage> {
  List<Summary> _summaryList = [];
  late StreamController<int> _postsController;
  bool isLoading = true;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  getReport() {
    Traccar.getSummary(widget.id.toString(), widget.from, widget.to)
        .then((value) => {
              _summaryList.addAll(value!),
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
      itemCount: _summaryList.length,
      itemBuilder: (context, index) {
        final summary = _summaryList[index];
        return reportRow(summary);
      },
    );
  }

  Widget reportRow(Summary s) {
    return Card(
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      ("positionDistance").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      Util().convertDistance(s.distance!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      ("reportStartOdometer").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      Util().convertDistance(s.startOdometer!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      ("reportEndOdometer").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      Util().convertDistance(s.endOdometer!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      ("reportAverageSpeed").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      Util().convertSpeed(s.averageSpeed!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      ("reportMaximumSpeed").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      Util().convertSpeed(s.maxSpeed!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      ('reportEngineHours').tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      Util().convertDuration(s.engineHours!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      ('reportSpentFuel'),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      s.spentFuel.toString(),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
              ],
            )));
  }
}

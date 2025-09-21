import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/screens/report/report_event.dart';
import 'package:gpspro/screens/report/report_route.dart';
import 'package:gpspro/screens/report/report_stop.dart';
import 'package:gpspro/screens/report/report_summary.dart';
import 'package:gpspro/screens/report/report_trip.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ReportListPage extends StatefulWidget {
  final int id;
  final String from;
  final String to;
  final String name;
  final Device device;
  ReportListPage(this.id, this.from, this.to, this.name, this.device);
  @override
  State<StatefulWidget> createState() => new _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  // ignore: non_constant_identifier_names
  Material Items(IconData icon, String heading, Color cColor) {
    return Material(
        color: Colors.white,
        elevation: 14.0,
        shadowColor: CustomColor.primaryColor,
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          onTap: () {
            if (heading == ('reportRoute').tr) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportRoutePage(widget.id,
                          widget.from, widget.to, widget.name, widget.device)));
            } else if (heading == ('reportEvents').tr) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportEventPage(widget.id,
                          widget.from, widget.to, widget.name, widget.device)));
            } else if (heading == ('reportTrips').tr) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportTripPage(widget.id,
                          widget.from, widget.to, widget.name, widget.device)));
            } else if (heading == ('reportStops').tr) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportStopPage(widget.id,
                          widget.from, widget.to, widget.name, widget.device)));
            } else if (heading == ('reportSummary').tr) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportSummaryPage(widget.id,
                          widget.from, widget.to, widget.name, widget.device)));
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 70,
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Text(
                          heading,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cColor,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                      Material(
                        color: cColor,
                        borderRadius: BorderRadius.circular(24.0),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(('reportDashboard').tr,
            style: TextStyle(color: CustomColor.secondaryColor)),
        iconTheme: IconThemeData(
          color: CustomColor.secondaryColor, //change your color here
        ),
      ),
      body: Container(
          child: StaggeredGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          Items(Icons.show_chart, ('reportRoute').tr, CustomColor.primaryColor),
          Items(Icons.info_outline, ('reportEvents').tr,
              CustomColor.primaryColor),
          Items(Icons.timeline, ('reportTrips').tr, CustomColor.primaryColor),
          Items(Icons.block, ('reportStops').tr, CustomColor.primaryColor),
          Items(Icons.list, ('reportSummary').tr, CustomColor.primaryColor),
          //Items(Icons.assessment, "Chart", 0xFF1E88E5)
        ],
        // staggeredTiles: [
        //   StaggeredTile.extent(1, 150.0),
        //   StaggeredTile.extent(1, 150.0),
        //   StaggeredTile.extent(1, 150.0),
        //   StaggeredTile.extent(1, 150.0),
        //   StaggeredTile.extent(1, 150.0),
        //   //StaggeredTile.extent(1, 130.0)
        // ],
      )),
    );
  }
}

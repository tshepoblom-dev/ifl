import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/route_report.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/util/util.dart';
import 'package:gpspro/theme/CustomColor.dart';

class ReportRoutePage extends StatefulWidget {
  final int id;
  final String from;
  final String to;
  final String name;
  final Device device;
  ReportRoutePage(this.id, this.from, this.to, this.name, this.device);
  @override
  State<StatefulWidget> createState() => new _ReportRoutePageState();
}

class _ReportRoutePageState extends State<ReportRoutePage> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  List<RouteReport> _routeList = [];
  late StreamController<int> _postsController;
  MapType _currentMapType = MapType.normal;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> _markers = Set<Marker>();
  bool isLoading = true;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  static final CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 0,
  );

  getReport() {
    Traccar.getRoute(widget.id.toString(), widget.from, widget.to)
        .then((value) => {
              _routeList.addAll(value!),
              value.forEach((element) {
                polylineCoordinates
                    .add(LatLng(element.latitude!, element.longitude!));
              }),
              fitBound(),
              setState(() {})
            });
  }

  void fitBound() {
    if (_routeList.isNotEmpty) {
      _postsController.add(1);
      isLoading = false;
      LatLngBounds bound = Util().boundsFromLatLngList(_routeList);
      addMarkers();
      drawPolyline();
      Future.delayed(const Duration(milliseconds: 2000), () {
        // ignore: unnecessary_null_comparison
        if (this.mapController != null) {
          CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
          this.mapController.animateCamera(u2).then((void v) {
            check(u2, this.mapController);
          });
        }
      });
    }
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  void addMarkers() async {
    var iconPath = "images/start.png";
    final Uint8List? startIcon = await Util().getBytesFromAsset(iconPath, 70);
    var endIconPath = "images/end.png";
    final Uint8List? endIcon = await Util().getBytesFromAsset(endIconPath, 70);

    _markers = Set<Marker>();
    _markers.add(Marker(
      markerId: MarkerId(_routeList.first.deviceId.toString()),
      position: LatLng(_routeList.first.latitude!,
          _routeList.first.longitude!), // updated position
      icon: BitmapDescriptor.bytes(startIcon!),
    ));

    _markers.add(Marker(
      markerId: MarkerId(_routeList.last.deviceId.toString()),
      position: LatLng(_routeList.last.latitude!,
          _routeList.last.longitude!), // updated position
      icon: BitmapDescriptor.bytes(endIcon!),
    ));
    setState(() {});
  }

  void drawPolyline() async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        width: 6,
        polylineId: id,
        color: Colors.greenAccent,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
            appBar: AppBar(
              title: Text(
                widget.name,
                style: TextStyle(color: CustomColor.secondaryColor),
                overflow: TextOverflow.ellipsis,
              ),
              iconTheme: IconThemeData(
                color: CustomColor.secondaryColor, //change your color here
              ),
            ),
            body: loadReport());
  }

  Widget loadReport() {
    return StreamBuilder<int>(
        stream: _postsController.stream,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            return loadMap();
          } else if (isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text(('noData').tr),
            );
          }
        });
  }

  Widget loadMap() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          mapType: _currentMapType,
          initialCameraPosition: _initialRegion,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
          },
          markers: _markers,
          polylines: Set<Polyline>.of(polylines.values),
          onTap: (LatLng latLng) {},
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
              alignment: Alignment.bottomRight,
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                SizedBox(width: 16.0),
                Builder(
                  builder: (context) => FloatingActionButton(
                      child: Icon(Icons.article, size: 36.0),
                      backgroundColor: CustomColor.primaryColor,
                      onPressed: () {
                        onSheetShowContents(context);
                      }),
                ),
              ])),
        ),
      ],
    );
  }

  Widget loadReportView() {
    return ListView.builder(
      itemCount: _routeList.length,
      itemBuilder: (context, index) {
        final report = _routeList[index];
        return reportRow(report, context);
      },
    );
  }

  Widget reportRow(RouteReport r, BuildContext context) {
    return Card(
        child: Container(
            child: Column(
      children: <Widget>[
        r.address != null
            ? Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 3.0),
                    child: Icon(Icons.location_on_outlined,
                        color: CustomColor.primaryColor, size: 20.0),
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
                                utf8.decode(r.address!.codeUnits),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ]),
                  )
                ],
              )
            : new Container(),
        Row(
          children: [
            Container(
                padding: EdgeInsets.only(top: 3.0, left: 3.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(Icons.location_on_outlined,
                          color: CustomColor.primaryColor, size: 20.0),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.only(top: 5.0, left: 3.0, right: 10.0),
                child: Text("Lat: " +
                    r.latitude!.toStringAsFixed(5) +
                    " Lng: " +
                    r.longitude!.toStringAsFixed(5))),
          ],
        ),
        Row(
          children: [
            Container(
                padding: EdgeInsets.only(top: 3.0, left: 5.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(Icons.speed,
                          color: CustomColor.primaryColor, size: 17.0),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 10.0),
                child: Text(Util().convertSpeed(r.speed!))),
          ],
        ),
        Row(
          children: [
            Container(
                padding: EdgeInsets.only(top: 3.0, left: 5.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(Icons.access_time_outlined,
                          color: CustomColor.primaryColor, size: 15.0),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 10.0),
                child: Text(
                  Util().formatTime(r.fixTime!),
                  style: TextStyle(fontSize: 11),
                )),
          ],
        ),
      ],
    )));
  }

  void onSheetShowContents(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
        ),
        child: Center(
          child: bottomSheetContent(),
        ),
      ),
    );
  }

  Widget bottomSheetContent() {
    return SafeArea(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Text(
                        widget.name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ))),
              InkWell(
                child: Icon(
                  Icons.close,
                  size: 40,
                ),
                onTap: () => {Navigator.pop(context)},
              )
            ],
          ),
          Divider(),
          Expanded(child: loadReportView())
        ],
      ),
    );
  }
}

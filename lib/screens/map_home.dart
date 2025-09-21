import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/api/model/PinInformation.dart';
import 'package:gpspro/api/model/command.dart';
import 'package:gpspro/api/model/command_model.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:gpspro/util/util.dart';
import 'package:gpspro/storage/dataController/DataController.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/custom_widgets/MapPinPillComponent.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  TextEditingController _searchController = new TextEditingController();

  late GoogleMapController mapController;
  Set<Marker> _markers = Set<Marker>();
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;
  Color _trafficBackgroundButtonColor = CustomColor.secondaryColor;
  Color _mapTypeBackgroundColor = CustomColor.secondaryColor;
  Color _trafficForegroundButtonColor = CustomColor.primaryColor;
  Color _mapTypeForegroundColor = CustomColor.primaryColor;
  int _selectedDeviceId = 0;
  bool deviceSelected = false;
  double pinPillPosition = -200;
  late LatLng _location;
  PinInformation currentlySelectedPin = PinInformation(
      location: LatLng(0, 0),
      name: '',
      status: '',
      charging: false,
      ignition: false,
      batteryLevel: "",
      labelColor: Colors.grey,
      deviceId: 0,
      calcTotalDist: "0 Km",
      blocked: false,
      speed: '',
      updatedTime: null,
      address: null,
      device: null,
      positionModel: null);
  late PinInformation sourcePinInfo;
  late PinInformation destinationPinInfo;
  double currentZoom = 14;
  List<Device> devicesList = [];
  List<Device> _searchResult = [];
  String selectedIndex = "all";
  late Timer _timer;

  bool first = true;
  bool streetView = false;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  List<String> _commands = <String>[];
  double _dialogCommandHeight = 150.0;
  int _selectedCommand = 0;
  final TextEditingController _customCommand = new TextEditingController();

  List<CommandModel> savedCommand = [];
  CommandModel _selectedSavedCommand = new CommandModel();

  DataController? controller;

  @override
  initState() {
    super.initState();
  }

  void _onMapCreated() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = LatLng(position.latitude, position.longitude);
    });
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

  void addMarker(DataController controller) {
    _markers = Set<Marker>();

    controller.positions.forEach((key, value) async {
      var iconPath;

      if (controller.devices[value.deviceId]!.category != null) {
        if (controller.devices[value.deviceId]!.status == "unknown") {
          iconPath = "images/marker_" +
              controller.devices[value.deviceId]!.category! +
              "_static.png";
        } else {
          iconPath = "images/marker_" +
              controller.devices[value.deviceId]!.category! +
              "_" +
              controller.devices[value.deviceId]!.status! +
              ".png";
        }
      } else {
        if (controller.devices[value.deviceId]!.status == "unknown") {
          iconPath = "images/marker_default_static.png";
        } else {
          iconPath = "images/marker_default_" +
              controller.devices[value.deviceId]!.status! +
              ".png";
        }
      }
      final Uint8List? markerIcon =
          await Util().getBytesFromAsset(iconPath, 60);

      sourcePinInfo = PinInformation(
          name: "",
          location: LatLng(0, 0),
          speed: "",
          address: "",
          updatedTime: "",
          labelColor: CustomColor.primaryColor,
          deviceId: value.deviceId,
          blocked: value.blocked,
          status: controller.devices[value.deviceId]!.status,
          device: controller.devices[value.deviceId],
          positionModel: controller.positions[value.deviceId],
          calcTotalDist: "0 Km",
          charging: null,
          batteryLevel: '',
          ignition: null);

      createCustomMarkerBitmap(controller.devices[value.deviceId]!.name)
          .then((BitmapDescriptor bitmapDescriptor) {
        _markers.add(Marker(
          markerId: MarkerId("t_" + value.deviceId.toString()),
          position: LatLng(value.latitude!, value.longitude!),
          anchor: const Offset(0.4, 0.4),
          // updated position
          icon: bitmapDescriptor,
          onTap: () {
            mapController.getZoomLevel().then((value) => {
                  if (value < 14)
                    {
                      currentZoom = 16,
                    }
                });

            CameraPosition cPosition = CameraPosition(
              target: LatLng(value.latitude!, value.longitude!),
              zoom: currentZoom,
            );
            mapController.moveCamera(CameraUpdate.newCameraPosition(cPosition));
            _selectedDeviceId = value.deviceId!;
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 30;
              streetView = true;
              polylines.clear();
              polylineCoordinates.clear();
              drawPolyline();
              updateMarkerInfo(value.deviceId!, iconPath, controller);
            });
          },
        ));
      });

      _markers.add(Marker(
        markerId: MarkerId(value.deviceId.toString()),
        position: LatLng(value.latitude!, value.longitude!),
        // updated position
        rotation: value.course!,
        icon: BitmapDescriptor.bytes(markerIcon!),
        onTap: () {
          mapController.getZoomLevel().then((value) => {
                if (value < 14)
                  {
                    currentZoom = 16,
                  }
              });

          CameraPosition cPosition = CameraPosition(
            target: LatLng(value.latitude!, value.longitude!),
            zoom: currentZoom,
          );
          mapController.moveCamera(CameraUpdate.newCameraPosition(cPosition));
          _selectedDeviceId = value.deviceId!;
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 30;
            streetView = true;
            polylines.clear();
            polylineCoordinates.clear();
            drawPolyline();
            updateMarkerInfo(value.deviceId!, iconPath, controller);
          });
        },
        // infoWindow: InfoWindow(
        //   title: widget.model.devices[value.deviceId].name,
        // )),
      ));
    });

    LatLngBounds bound =
        Util().boundsFromLatLngList(controller.positions.values.toList());

    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
      this.mapController.animateCamera(u2).then((void v) {
        check(u2, this.mapController);
      });
      _timer.cancel();
      setState(() {});
    });
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(title) async {
    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);

    /* Do your painting of the custom icon here, including drawing text, shapes, etc. */
    TextSpan span = new TextSpan(
        style: new TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            backgroundColor: CustomColor.primaryColor),
        text: title);

    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: m.TextDirection.ltr,
    );
    tp.layout();
    tp.paint(c, new Offset(20.0, 10.0));

    Picture p = recorder.endRecording();
    ByteData? pngBytes =
        await (await p.toImage(tp.width.toInt() + 40, tp.height.toInt() + 20))
            .toByteData(format: ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes!.buffer);

    return BitmapDescriptor.bytes(data);
  }

  Future<ui.Image> getImageFromPath(String imagePath) async {
    //String fullPathOfImage = await getFileData(imagePath);

    //File imageFile = File(fullPathOfImage);
    ByteData bytes = await rootBundle.load(imagePath);
    Uint8List imageBytes = bytes.buffer.asUint8List();
    //Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });
    //print("COMPLETERR DONE Full path of image is"+imagePath);
    return completer.future;
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  void updateMarker(DataController controller) async {
    var iconPath;

    controller.positions.forEach((key, pos) async {
      if (controller.devices[pos.deviceId]!.category != null) {
        if (controller.devices[pos.deviceId]!.status == "unknown") {
          iconPath = "images/marker_" +
              controller.devices[pos.deviceId]!.category! +
              "_static.png";
        } else {
          iconPath = "images/marker_" +
              controller.devices[pos.deviceId]!.category! +
              "_" +
              controller.devices[pos.deviceId]!.status! +
              ".png";
        }
      } else {
        if (controller.devices[pos.deviceId]!.status! == "unknown") {
          iconPath = "images/marker_default_static.png";
        } else {
          iconPath = "images/marker_default_" +
              controller.devices[pos.deviceId]!.status! +
              ".png";
        }
      }
      // ignore: unused_local_variable
      bool blocked = false;
      if (pos.blocked != null) {
        blocked = pos.blocked!;
      }

      var pinPosition = LatLng(pos.latitude!, pos.longitude!);

      final Uint8List? markerIcon =
          await Util().getBytesFromAsset(iconPath, 60);

      _markers.removeWhere((m) => m.markerId.value == pos.deviceId.toString());
      _markers.removeWhere(
          (m) => "t_" + m.markerId.value == "t_" + pos.deviceId.toString());
      createCustomMarkerBitmap(controller.devices[pos.deviceId]!.name)
          .then((BitmapDescriptor bitmapDescriptor) {
        _markers.add(Marker(
          markerId: MarkerId("t_" + pos.deviceId.toString()),
          position: pinPosition,
          icon: bitmapDescriptor,
          onTap: () {
            mapController.getZoomLevel().then((value) => {
                  if (value < 14)
                    {
                      currentZoom = 16,
                    }
                });

            CameraPosition cPosition = CameraPosition(
              target: LatLng(pos.latitude!, pos.longitude!),
              zoom: currentZoom,
            );
            mapController.moveCamera(CameraUpdate.newCameraPosition(cPosition));
            //mapController.moveCamera(cameraUpdate);
            _selectedDeviceId = pos.deviceId!;
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 30;
              streetView = true;
              polylines.clear();
              polylineCoordinates.clear();
              drawPolyline();
              updateMarkerInfo(pos.deviceId!, iconPath, controller);
            });
          },
        ));
      });

      _markers.add(Marker(
        markerId: MarkerId(pos.deviceId.toString()),
        position: pinPosition,
        icon: BitmapDescriptor.bytes(markerIcon!),
        rotation: pos.course!,
        onTap: () {
          mapController.getZoomLevel().then((value) => {
                if (value < 14)
                  {
                    currentZoom = 16,
                  }
              });

          CameraPosition cPosition = CameraPosition(
            target: LatLng(pos.latitude!, pos.longitude!),
            zoom: currentZoom,
          );
          mapController.moveCamera(CameraUpdate.newCameraPosition(cPosition));
          //mapController.moveCamera(cameraUpdate);
          _selectedDeviceId = pos.deviceId!;
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 30;
            streetView = true;
            polylines.clear();
            polylineCoordinates.clear();
            drawPolyline();
            updateMarkerInfo(pos.deviceId!, iconPath, controller);
          });
        },
      ));

      updateMarkerInfo(pos.deviceId!, iconPath, controller);
    });
  }

  void updateMarkerInfo(int deviceId, var iconPath, controller) {
    if (_selectedDeviceId == deviceId) {
      String fLastUpdate = Util()
          .formatTime(controller.devices![_selectedDeviceId]!.lastUpdate!);
      polylineCoordinates.add(LatLng(
          controller.positions![_selectedDeviceId]!.latitude!,
          controller.positions![_selectedDeviceId]!.longitude!));
      bool chargingStatus = false, ignitionStatus = false;
      String batteryLevelValue = "";

      if (controller.positions![_selectedDeviceId]!.attributes!
          .containsKey("charge")) {
        chargingStatus =
            controller.positions![_selectedDeviceId]!.attributes!["charge"];
      }

      if (controller.positions![_selectedDeviceId]!.attributes!
          .containsKey("ignition")) {
        ignitionStatus =
            controller.positions![_selectedDeviceId]!.attributes!["ignition"];
      }

      if (controller.positions![_selectedDeviceId]!.attributes!
          .containsKey("batteryLevel")) {
        batteryLevelValue = controller
                .positions![_selectedDeviceId]!.attributes!["batteryLevel"]
                .toString() +
            "%";
      }

      bool blocked = false;
      if (controller.positions![_selectedDeviceId]!.blocked != null) {
        blocked = controller.positions![_selectedDeviceId]!.blocked!;
      }
      double calcDist;
      // ignore: unnecessary_null_comparison
      if (_location != null) {
        calcDist = calculateDistance(
            controller.positions![_selectedDeviceId]!.latitude,
            controller.positions![_selectedDeviceId]!.longitude,
            _location.latitude,
            _location.longitude);
      } else {
        calcDist = 0.0;
      }
      sourcePinInfo = PinInformation(
          name: controller.devices![_selectedDeviceId]!.name,
          location: LatLng(controller.positions![_selectedDeviceId]!.latitude!,
              controller.positions![_selectedDeviceId]!.longitude!),
          speed: Util()
              .convertSpeed(controller.positions![_selectedDeviceId]!.speed!),
          address: controller.positions![_selectedDeviceId]!.address,
          status: controller.devices![_selectedDeviceId]!.status,
          updatedTime: fLastUpdate,
          charging: chargingStatus,
          ignition: ignitionStatus,
          batteryLevel: batteryLevelValue,
          deviceId: _selectedDeviceId,
          blocked: blocked,
          labelColor: CustomColor.primaryColor,
          device: controller.devices![_selectedDeviceId],
          positionModel: controller.positions![_selectedDeviceId],
          calcTotalDist: calcDist.toStringAsFixed(1) + " Km");

      currentlySelectedPin = sourcePinInfo;
    }
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
      _mapTypeBackgroundColor = _currentMapType == MapType.normal
          ? CustomColor.secondaryColor
          : CustomColor.primaryColor;
      _mapTypeForegroundColor = _currentMapType == MapType.normal
          ? CustomColor.primaryColor
          : CustomColor.secondaryColor;
    });
  }

  void _trafficEnabledPressed() {
    setState(() {
      _trafficEnabled = _trafficEnabled == false ? true : false;
      _trafficBackgroundButtonColor = _trafficEnabled == false
          ? CustomColor.secondaryColor
          : CustomColor.primaryColor;

      _trafficForegroundButtonColor = _trafficEnabled == false
          ? CustomColor.primaryColor
          : CustomColor.secondaryColor;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _reloadMap(DataController controller) {
    LatLngBounds bound =
        Util().boundsFromLatLngList(controller.positions.values.toList());

    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    this.mapController.animateCamera(u2).then((void v) {
      check(u2, this.mapController);
    });
    pinPillPosition = -200;
    polylines.clear();
    polylineCoordinates.clear();
    setState(() {});
    Fluttertoast.showToast(
        msg: ("showingAllDevices").tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _streetView(DataController controller) {
    launchUrlString(
        "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=" +
            controller.positions[_selectedDeviceId]!.latitude.toString() +
            "," +
            controller.positions[_selectedDeviceId]!.longitude.toString() +
            "&heading=0&pitch=0&fov=80");
  }

  void moveToMarker(Device device) {
    if (controller!.positions[device.id]!.latitude != null) {
      CameraPosition cPosition = CameraPosition(
        target: LatLng(controller!.positions[device.id]!.latitude!,
            controller!.positions[device.id]!.longitude!),
        zoom: currentZoom,
      );
      mapController.moveCamera(CameraUpdate.newCameraPosition(cPosition));
      _selectedDeviceId = device.id!;
      polylines.clear();
      polylineCoordinates.clear();
      setState(() {
        currentlySelectedPin = sourcePinInfo;
        currentlySelectedPin = sourcePinInfo;
        pinPillPosition = 30;
        streetView = true;
        updateMarkerInfo(device.id!, null, controller);
      });
      Navigator.pop(context);
    }
  }

  static final CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 0,
  );

  onSearchTextChanged(String text) async {
    _searchResult.clear();

    if (text.toLowerCase().isEmpty) {
      setState(() {});
      return;
    }

    devicesList.forEach((device) {
      if (device.name!.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(device);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //
    return new Scaffold(
        key: _drawerKey,
        drawer: SizedBox(width: 250, child: navDrawer()),
        body: GetX<DataController>(
            init: DataController(),
            builder: (dataCtrl) {
              controller = dataCtrl;
              devicesList = dataCtrl.devices.values.toList();
              if (dataCtrl.positions.isNotEmpty) {
                if (first) {
                  addMarker(dataCtrl);
                  first = false;
                } else {
                  updateMarker(dataCtrl);
                }
                return buildMap(dataCtrl);
              } else {
                return Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width /1,
                      height: MediaQuery.of(context).size.height /1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                         /* IconButton(onPressed: (){

                          }, icon: Icon(Icons.add_circle_outline, size: 150,)),*/
                          Text("Loading data...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                        ],
                      )) ,
                );
              }
            }));
  }

  Widget navDrawer() {
    return Drawer(
        child: new Column(children: <Widget>[
      new Container(
        child: new Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: new Card(
            child: new ListTile(
              leading: new Icon(Icons.search),
              title: new TextField(
                controller: _searchController,
                decoration: new InputDecoration(
                    hintText: ('search').tr,
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 12)),
                onChanged: onSearchTextChanged,
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.cancel),
                onPressed: () {
                  _searchController.clear();
                  onSearchTextChanged('');
                },
              ),
            ),
          ),
        ),
      ),
      new Expanded(
          child: _searchResult.length != 0 || _searchController.text.isNotEmpty
              ? new ListView.builder(
                  itemCount: _searchResult.length,
                  itemBuilder: (context, index) {
                    final device = _searchResult[index];
                    return deviceCard(device, context);
                  },
                )
              : selectedIndex == "all"
                  ? new ListView.builder(
                      itemCount: devicesList.length,
                      itemBuilder: (context, index) {
                        final device = devicesList[index];
                        return deviceCard(device, context);
                      })
                  : new ListView.builder(
                      itemCount: 0,
                      itemBuilder: (context, index) {
                        return Text(("noDeviceFound").tr);
                      }))
    ]));
  }

  Widget deviceCard(Device device, BuildContext context) {
    Color color;

    if (device.status == "online") {
      color = Colors.green;
    } else if (device.status == "unknown") {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    String speed;

    if (controller!.positions.containsKey(device.id)) {
      speed = Util().convertSpeed(controller!.positions[device.id]!.speed!);
    } else {
      speed = "0.0 Km/hr";
    }

    return new Card(
      elevation: 2.0,
      child: Padding(
        padding: new EdgeInsets.all(1.0),
        child: ListTile(
          leading: Icon(
            Icons.radio_button_checked,
            color: color,
          ),
          title: Text(device.name!),
          subtitle: Text(speed),
          onTap: () => {moveToMarker(device)},
        ),
      ),
    );
  }

  void showCommandDialog(BuildContext context, Device device) {
    _commands.clear();

    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          Iterable list;
          try {
            Traccar.getSendCommands(device.id.toString()).then((value) => {
                  // ignore: unnecessary_null_comparison
                  if (value.body != null)
                    {
                      list = json.decode(value.body),
                      if (_commands.length == 0)
                        {
                          list.forEach((element) {
                            if (list.length == 1) {
                              _dialogCommandHeight = 200;
                            }
                            _commands.add(element["type"]);
                          })
                        }
                    }
                  else
                    {},
                  setState(() {})
                });
          } catch (e) {
            print(e);
          }
          return Container(
            height: _dialogCommandHeight,
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _commands.length > 0
                    ? Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(('commandTitle').tr),
                                  ],
                                ),
                                new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new DropdownButton<String>(
                                        hint: new Text(('select_command').tr),
                                        // ignore: unnecessary_null_comparison
                                        value: _selectedCommand == null
                                            ? null
                                            : _commands[_selectedCommand],
                                        items: _commands.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(
                                              (value).tr,
                                              style: TextStyle(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == "custom") {
                                              _dialogCommandHeight = 250.0;
                                            } else {
                                              _dialogCommandHeight = 150.0;
                                            }
                                            _selectedCommand =
                                                _commands.indexOf(value!);
                                          });
                                        },
                                      )
                                    ]),
                                _commands[_selectedCommand] == "custom"
                                    ? new Container(
                                        child: new TextField(
                                          controller: _customCommand,
                                          decoration: new InputDecoration(
                                              labelText: ('commandCustom').tr),
                                        ),
                                      )
                                    : new Container(),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red, // background
                                        foregroundColor:
                                            Colors.white, // foreground
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        ('cancel').tr,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        sendCommand(device);
                                      },
                                      child: Text(
                                        ('ok').tr,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : new CircularProgressIndicator(),
              ],
            ),
          );
        }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  void sendCommand(Device device) {
    Map<String, dynamic> attributes = new HashMap();
    if (_commands[_selectedCommand] == "custom") {
      attributes.putIfAbsent("data", () => _customCommand.text);
    } else {
      attributes.putIfAbsent("data", () => _commands[_selectedCommand]);
    }

    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = _commands[_selectedCommand];
    command.attributes = attributes;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
          if (res.statusCode == 200)
            {
              Fluttertoast.showToast(
                  msg: ('command_sent').tr,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
          else
            {
              Fluttertoast.showToast(
                  msg: ('errorMsg').tr,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
        });
  }

  Widget buildMap(DataController controller) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
        ),
        new GoogleMap(
          mapType: _currentMapType,
          initialCameraPosition: _initialRegion,
          trafficEnabled: _trafficEnabled,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
            _onMapCreated();
          },
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          markers: _markers,
          polylines: Set<Polyline>.of(polylines.values),
          onTap: (LatLng latLng) {
            setState(() {
              pinPillPosition = -200;
              streetView = false;
            });
          },
        ),
        MapPinPillComponent(
            pinPillPosition: pinPillPosition,
            currentlySelectedPin: currentlySelectedPin),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 55, 5, 0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "mapType",
                  mini: true,
                  onPressed: _onMapTypeButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: _mapTypeBackgroundColor,
                  foregroundColor: _mapTypeForegroundColor,
                  child: const Icon(Icons.map, size: 25.0),
                ),
                FloatingActionButton(
                  heroTag: "traffic",
                  mini: true,
                  onPressed: _trafficEnabledPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: _trafficBackgroundButtonColor,
                  foregroundColor: _trafficForegroundButtonColor,
                  child: const Icon(Icons.traffic, size: 25.0),
                ),
                FloatingActionButton(
                  heroTag: "reloadMap",
                  mini: true,
                  onPressed: () {
                    _reloadMap(controller);
                  },
                  backgroundColor: CustomColor.secondaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  foregroundColor: CustomColor.primaryColor,
                  child: const Icon(Icons.refresh, size: 25.0),
                ),
                Visibility(
                  visible: streetView,
                  child: FloatingActionButton(
                      heroTag: "streetView",
                      mini: true,
                      onPressed: () {
                        _streetView(controller);
                      },
                      backgroundColor: CustomColor.secondaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      foregroundColor: CustomColor.primaryColor,
                      child: const Icon(Icons.streetview, size: 25.0)),
                ),
                Visibility(
                  visible: streetView,
                  child: FloatingActionButton(
                      heroTag: "commands",
                      mini: true,
                      onPressed: () {
                        showSavedCommandDialog(
                            context, controller.devices[_selectedDeviceId]!);
                      },
                      backgroundColor: CustomColor.secondaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      foregroundColor: CustomColor.primaryColor,
                      child: const Icon(Icons.send_to_mobile, size: 25.0)),
                )
              ],
            ),
          ),
        ),
        Stack(
          children: [
            Positioned(
              top: 55,
              left: 5,
              child: FloatingActionButton(
                heroTag: "openDrawer",
                mini: true,
                onPressed: () {
                  _drawerKey.currentState!.openDrawer();
                  setState(() {});
                },
                materialTapTargetSize: MaterialTapTargetSize.padded,
                backgroundColor: CustomColor.secondaryColor,
                foregroundColor: CustomColor.primaryColor,
                child: const Icon(Icons.menu, size: 25.0),
              ),
            ),
          ],
        )
      ],
    );
  }

  void showSavedCommandDialog(BuildContext context, device) {
    savedCommand.clear();
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          try {
            Traccar.getSavedCommands(device.id.toString()).then((value) => {
                  if (value != null)
                    {
                      if (savedCommand.length == 0)
                        {
                          value.forEach((element) {
                            savedCommand.add(element);
                          }),
                          _selectedSavedCommand.description =
                              savedCommand.first.description,
                        },
                    }
                  else
                    {},
                  setState(() {})
                });
          } catch (e) {
            print(e);
          }
          return Container(
            height: _dialogCommandHeight,
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                savedCommand.length > 0
                    ? Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(('commandTitle').tr),
                                  ],
                                ),
                                new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new DropdownButton<CommandModel>(
                                        hint: new Text(_selectedSavedCommand
                                                    .description !=
                                                null
                                            ? _selectedSavedCommand.description!
                                            : ""),
                                        items: savedCommand
                                            .map((CommandModel value) {
                                          return new DropdownMenuItem<
                                              CommandModel>(
                                            value: value,
                                            child: new Text(
                                              value.description!,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedSavedCommand = value!;
                                          });
                                        },
                                      )
                                    ]),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red, // background
                                        foregroundColor:
                                            Colors.white, // foreground
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        ('cancel').tr,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        sendSavedCommand(device);
                                      },
                                      child: Text(
                                        ('ok').tr,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : savedCommand.length < 0
                        ? Center(child: Text(('noData').tr))
                        : Center(
                            child: Text(('noData').tr,
                                style:
                                    TextStyle(color: CustomColor.primaryColor)))
              ],
            ),
          );
        }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  void sendSavedCommand(Device device) {
    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = "custom";
    command.attributes = _selectedSavedCommand.attributes;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
          if (res.statusCode == 200)
            {
              Fluttertoast.showToast(
                  msg: ('command_sent').tr,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
          else
            {
              Fluttertoast.showToast(
                  msg: ('errorMsg').tr,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
        });
  }
}

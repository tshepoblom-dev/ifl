import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/position.dart';

class PinInformation {
  String? address;
  String? updatedTime;
  LatLng? location;
  String? status;
  String? name;
  String? speed;
  Color? labelColor;
  bool? ignition;
  String? batteryLevel;
  bool? charging;
  int? deviceId;
  bool? blocked;
  String? calcTotalDist;
  Device? device;
  Position? positionModel;

  PinInformation(
      {required this.address,
      required this.updatedTime,
      required this.location,
      required this.status,
      required this.name,
      required this.speed,
      required this.labelColor,
      required this.batteryLevel,
      required this.ignition,
      required this.charging,
      required this.deviceId,
      required this.blocked,
      required this.calcTotalDist,
      required this.device,
      required this.positionModel});
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/api/model/position.dart';
import 'package:gpspro/util/util.dart';
import 'package:jiffy/jiffy.dart';

import '../../api/model/device.dart';

class DeviceCardItem extends StatelessWidget {

  final Device device;
  final Map<int, Position> pos;
  final ValueChanged<Device> onTap;

  DeviceCardItem({required this.device, required this.pos, required this.onTap});

  double subtext = 13;
  double title = 14;

  @override
  Widget build(BuildContext context) {

    Color color;

    if (device.status == "online") {
      color = Colors.green;
    } else if (device.status == "unknown") {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    String fLastUpdate = ('noData').tr;
    if (device.lastUpdate != null) {
      fLastUpdate = Util().formatTime(device.lastUpdate!);
    }

    return  Card(
      color: Colors.white,
      elevation: 1.0,
      child: Padding(
          padding: new EdgeInsets.all(10.0),
          child: Column(children: <Widget>[
            InkWell(
              onTap: () => onTap(device), // 👈 correctly pass the device to the callback
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Row(children: <Widget>[
                            Icon(Icons.radio_button_checked,
                                color: color, size: 18.0),
                            Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Text(
                                  utf8.decode(device.name!.codeUnits),
                                  style: TextStyle(
                                      fontSize: title,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ]),
                          // new Row(children: <Widget>[
                          //   positions.containsKey(device.id)
                          //       ? positions[device.id]!
                          //               .attributes!
                          //               .containsKey("ignition")
                          //           ? positions[device.id]!
                          //                   .attributes!["ignition"]
                          //               ? Icon(Icons.vpn_key,
                          //                   color: CustomColor.onColor,
                          //                   size: 18.0)
                          //               : Icon(Icons.vpn_key,
                          //                   color: CustomColor.offColor,
                          //                   size: 18.0)
                          //           : Icon(Icons.vpn_key,
                          //               color: CustomColor.offColor, size: 18.0)
                          //       : new Container(),
                          //   positions.containsKey(device.id)
                          //       ? positions[device.id]!
                          //               .attributes!
                          //               .containsKey("charge")
                          //           ? positions[device.id]!
                          //                   .attributes!["charge"]
                          //               ? Icon(Icons.battery_charging_full,
                          //                   color: CustomColor.onColor,
                          //                   size: 18.0)
                          //               : Icon(Icons.battery_std,
                          //                   color: CustomColor.offColor,
                          //                   size: 18.0)
                          //           : Icon(Icons.battery_std,
                          //               color: CustomColor.offColor, size: 18.0)
                          //       : new Container(),
                          //   positions.containsKey(device.id)
                          //       ? positions[device.id]!
                          //               .attributes!
                          //               .containsKey("batteryLevel")
                          //           ? Container(
                          //               width: 20,
                          //               child: Text(
                          //                 positions[device.id]!
                          //                         .attributes!["batteryLevel"]
                          //                         .toString() +
                          //                     "%",
                          //                 style: TextStyle(
                          //                     color: CustomColor.primaryColor,
                          //                     fontSize: 10),
                          //                 overflow: TextOverflow.ellipsis,
                          //               ))
                          //           : Text("")
                          //       : new Container()
                          // ]),
                        ]),
                    new Row(children: <Widget>[
                      Icon(Icons.speed, color: color, size: 18.0),
                      Padding(padding: new EdgeInsets.fromLTRB(5, 5, 0, 0)),
                      pos.containsKey(device.id)
                          ? Text(
                        device.status![0].toUpperCase() +
                            device.status!.substring(1) +
                            " " +
                            Util().convertSpeed(pos[device.id]!.speed!),
                        style: TextStyle(fontSize: subtext),
                        overflow: TextOverflow.ellipsis,
                      )
                          : Text(
                          device.status![0].toUpperCase() +
                              device.status!.substring(1),
                          style: TextStyle(fontSize: subtext),
                          overflow: TextOverflow.ellipsis),
                    ]),
                    // new Row(children: <Widget>[
                    //   Icon(Icons.timelapse, color: Colors.red, size: 18.0),
                    //   Padding(padding: new EdgeInsets.fromLTRB(5, 5, 0, 0)),
                    //   positions.containsKey(device.id)
                    //       ? Text(
                    //           device.expirationTime != null
                    //               ? "Expire " +
                    //                   Jiffy.parse(
                    //                           Util().formatTime(
                    //                               device.expirationTime!),
                    //                           pattern: 'dd-MM-yyyy hh:mm:ss aa')
                    //                       .fromNow()
                    //               : "-",
                    //           style: TextStyle(fontSize: subtext),
                    //           overflow: TextOverflow.ellipsis,
                    //         )
                    //       : Text(
                    //           device.status![0].toUpperCase() +
                    //               device.status!.substring(1),
                    //           style: TextStyle(fontSize: subtext),
                    //           overflow: TextOverflow.ellipsis),
                    // ]),
                    pos.containsKey(device.id)
                        ? pos[device.id]!.address != null
                        ? new Row(children: <Widget>[
                      Icon(Icons.location_on_outlined,
                          color: color, size: 18.0),
                      Expanded(
                          child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                pos[device.id]!.address != null
                                    ? Container(
                                  child: Text(
                                    pos[device.id]!.address!,
                                    style:
                                    TextStyle(fontSize: subtext),
                                    textAlign: TextAlign.left,
                                    maxLines: 2,
                                  ),
                                )
                                    : Container()
                              ]))
                    ])
                        : new Container()
                        : new Container(),
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(Icons.timer_rounded, color: color, size: 18.0),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 5, 0, 0)),
                              Text(
                                fLastUpdate,
                                style: TextStyle(fontSize: subtext),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            device.lastUpdate != null
                                ? Jiffy.parse(fLastUpdate,
                                pattern: 'dd-MM-yyyy hh:mm:ss aa')
                                .fromNow()
                                : "-",
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          )
                        ])
                  ],
                ),
              ),
            ),
          ])),
    );

  }



}

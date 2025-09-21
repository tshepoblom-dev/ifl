import 'dart:convert';

import 'package:gpspro/Config.dart';
import 'package:gpspro/api/model/command_model.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/event.dart';
import 'package:gpspro/api/model/geofence.dart';
import 'package:gpspro/api/model/maintenance.dart';
import 'package:gpspro/api/model/notification.dart';
import 'package:gpspro/api/model/notification_type.dart';
import 'package:gpspro/api/model/position.dart';
import 'package:gpspro/api/model/route_report.dart';
import 'package:gpspro/api/model/server.dart';
import 'package:gpspro/api/model/stop.dart';
import 'package:gpspro/api/model/summary.dart';
import 'package:gpspro/api/model/trip.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Traccar {
  static Map<String, String> headers = {};
  static String? serverURL = UserRepository.getServerUrl().toString();
  static String? socketURL;

  static Future<http.Response?> login(email, password) async {
    var uri = Uri.parse(serverURL!);
    String socketScheme;
    if (uri.scheme == "http") {
      socketScheme = "ws://";
    } else {
      socketScheme = "wss://";
    }

    if (uri.hasPort) {
      socketURL =
          socketScheme + uri.host + ":" + uri.port.toString() + "/api/socket";
    } else {
      socketURL = socketScheme + uri.host + "/api/socket";
    }

    print(serverURL);

    Map<String, String> header = {
      "Content-Type": "application/x-www-form-urlencoded"
    };
    try {
      final response = await http.post(Uri.parse(serverURL! + "/api/session"),
          body: {"email": email, "password": password}, headers: header);

      updateCookie(response);

      if (response.statusCode == 200) {
        UserRepository.setEmail(email);
        UserRepository.setPassword(password);
        return response;
      } else {
        return response;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<Device>?> getDevices() async {
    final response = await http.get(Uri.parse(serverURL! + "/api/devices"),
        headers: headers);

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Device.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Position>?> getPositionById(
      String deviceId, String posId) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/positions?deviceId=" +
            deviceId +
            "&id=" +
            posId),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Position.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Position>?> getPositions(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/positions?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Position.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Position>?> getLatestPositions() async {
    headers['Accept'] = "application/json";
    final response = await http.get(Uri.parse(serverURL! + "/api/positions"),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Position.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Device>?> getDevicesById(String id) async {
    final response = await http
        .get(Uri.parse(serverURL! + "/api/devices?id=" + id), headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Device.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> sessionLogout() async {
    headers['content-type'] = "application/x-www-form-urlencoded";
    final response = await http.delete(Uri.parse(serverURL! + "/api/session"),
        headers: headers);
    return response;
  }

  static Future<http.Response> getSendCommands(String id) async {
    final response = await http.get(
        Uri.parse(serverURL! + "/api/commands/types?deviceId=" + id),
        headers: headers);
    return response;
  }

  static Future<http.Response> sendCommands(String command) async {
    headers['content-type'] = "application/json";
    final response = await http.post(
        Uri.parse(serverURL! + "/api/commands/send"),
        body: command,
        headers: headers);
    return response;
  }

  static Future<http.Response> updateUser(String user, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";

    final response = await http.put(Uri.parse(serverURL! + "/api/users/" + id),
        body: user, headers: headers);
    return response;
  }

  static Future<List<RouteReport>?> getRoute(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/route?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => RouteReport.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<NotificationTypeModel>?> getNotificationTypes() async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! + "/api/notifications/types"),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list
          .map((model) => NotificationTypeModel.fromJson(model))
          .toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Event>?> getEvents(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/events?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Event.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<Event?> getEventById(String id) async {
    headers['Accept'] = "application/json";
    final response = await http.get(Uri.parse(serverURL! + "/api/events/" + id),
        headers: headers);
    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Event>?> getAllDeviceEvents(
      var deviceId, String from, String to) async {
    var uri =
        Uri(queryParameters: {'deviceId': deviceId, 'from': from, 'to': to});
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! + "/api/reports/events" + uri.toString()),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Event.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Trip>?> getTrip(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/trips?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Trip.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Stop>?> getStops(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/stops?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Stop.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Summary>?> getSummary(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/summary?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Summary.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<GeofenceModel>?> getGeoFencesByUserID(
      String userID) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! + "/api/geofences?userId=" + userID),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => GeofenceModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<GeofenceModel>?> getGeoFencesByDeviceID(
      String deviceId) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! + "/api/geofences?deviceId=" + deviceId),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => GeofenceModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> addGeofence(String fence) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.post(Uri.parse(serverURL! + "/api/geofences"),
        body: fence, headers: headers);
    return response;
  }

  static Future<http.Response> addDevice(String device) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.post(Uri.parse(serverURL! + "/api/devices"),
        body: device, headers: headers);
    return response;
  }

  static Future<http.Response> updateGeofence(String fence, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.put(
        Uri.parse(serverURL! + "/api/geofences/" + id),
        body: fence,
        headers: headers);
    return response;
  }

  static Future<http.Response> updateDevices(String fence, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.put(
        Uri.parse(serverURL! + "/api/devices/" + id),
        body: fence,
        headers: headers);
    return response;
  }

  static Future<http.Response> addPermission(String permission) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.post(Uri.parse(serverURL! + "/api/permissions"),
        body: permission, headers: headers);
    return response;
  }

  static Future<StreamedResponse> deletePermission(deviceId, fenceId) async {
    http.Request rq =
        http.Request('DELETE', Uri.parse(serverURL! + "/api/permissions"))
          ..headers;
    rq.headers.addAll(<String, String>{
      "Accept": "application/json",
      "Content-type": "application/json; charset=utf-8",
      "cookie": headers['cookie'].toString()
    });
    rq.body = jsonEncode({"deviceId": deviceId, "geofenceId": fenceId});

    return http.Client().send(rq);
  }

  static updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'].toString();
    // ignore: unnecessary_null_comparison
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  static Future<http.Response> deleteGeofence(dynamic id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http
        .delete(Uri.parse(serverURL! + "/api/geofences/$id"), headers: headers);
    return response;
  }

  static Future<String> geocode(String lat, String lng) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(
            serverURL! + "/api/server/geocode?latitude=$lat&longitude=$lng"),
        headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print(response.statusCode);
      return "";
    }
  }

  static Future<List<NotificationModel>?> getNotifications() async {
    headers['Accept'] = "application/json";
    final response = await http
        .get(Uri.parse(serverURL! + "/api/notifications"), headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => NotificationModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<NotificationModel?> addNotifications(
      String notification) async {
    headers['Accept'] = "application/json";
    final response = await http.post(
        Uri.parse(serverURL! + "/api/notifications"),
        body: notification,
        headers: headers);
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(json.decode(response.body));
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> deleteNotifications(String id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.delete(
        Uri.parse(serverURL! + "/api/notifications/$id"),
        headers: headers);
    return response;
  }

  static Future<StreamedResponse> deleteMaintenancePermission(
      deviceId, fenceId) async {
    http.Request rq =
        http.Request('DELETE', Uri.parse(serverURL! + "/api/permissions"))
          ..headers;
    rq.headers.addAll(<String, String>{
      "Accept": "application/json",
      "Content-type": "application/json; charset=utf-8",
      "cookie": headers['cookie'].toString()
    });
    rq.body = jsonEncode({"deviceId": deviceId, "maintenanceId": fenceId});

    return http.Client().send(rq);
  }

  static Future<List<CommandModel>?> getSavedCommands(id) async {
    final response = await http.get(Uri.parse(serverURL! + "/api/commands/"),
        headers: Traccar.headers);
    print(response.body);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => CommandModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<MaintenanceModel>?> getMaintenance() async {
    final response = await http.get(Uri.parse(serverURL! + "/api/maintenance"),
        headers: Traccar.headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => MaintenanceModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<MaintenanceModel>?> getMaintenanceByDeviceId(
      String id) async {
    final response = await http.get(
        Uri.parse(serverURL! + "/api/maintenance?deviceId=" + id.toString()),
        headers: Traccar.headers);
    if (response.statusCode == 200) {
      print(response.body);
      Iterable list = json.decode(response.body);
      return list.map((model) => MaintenanceModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> deleteMaintenance(dynamic id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.delete(
        Uri.parse(serverURL! + "/api/maintenance/$id"),
        headers: headers);
    return response;
  }

  static Future<http.Response> addMaintenance(String m) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.post(Uri.parse(serverURL! + "/api/maintenance"),
        body: m, headers: headers);
    print(response.body);
    return response;
  }

  static Future<http.Response> updateMaintenance(String m) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.post(Uri.parse(serverURL! + "/api/maintenance"),
        body: m, headers: headers);
    print(response.body);
    return response;
  }

  static Future<http.Response> updateNotification(
      String notification, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.put(
        Uri.parse(serverURL! + "/api/notifications/" + id),
        body: notification,
        headers: headers);
    return response;
  }

  static Future<http.Response> addNotification(String notif) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.post(
        Uri.parse(serverURL! + "/api/notifications"),
        body: notif,
        headers: headers);
    return response;
  }

  static Future<Server> getServer() async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.get(Uri.parse(SERVER_URL + "/api/server/"));
    return Server.fromJson(json.decode(response.body));
  }
}

// ignore_for_file: file_names

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:gpspro/api/model/device.dart';
import 'package:gpspro/api/model/event.dart';
import 'package:gpspro/api/model/position.dart';
import 'package:gpspro/api/traccar.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class DataController extends GetxController {
  RxMap<int, Device> devices = <int, Device>{}.obs;
  RxMap<int, Position> positions = <int, Position>{}.obs;

  RxList<Event> events = <Event>[].obs;
  var counter = 0.obs;
  RxBool isLoading = true.obs;
  RxString currentPage = ''.obs;
  RxBool isEventLoading = true.obs;
  IOWebSocketChannel? socketChannel;
  
  final Set<int> _eventIds = {};
  final Map<String, String> _addressCache = {};
  Timer? _throttleTimer;

  Duration throttleDuration = const Duration(milliseconds: 250);
  bool _isThrottled = false;
  final Queue<dynamic> _eventQueue = Queue();
  

  String _latLngKey(double lat, double lon) => "\${lat.toStringAsFixed(5)}_\${lon.toStringAsFixed(5)}";

  @override
  Future<void> onInit() async {
    super.onInit();
    getDevices();
    
        _initSocket();      
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  void onClose() {
    _eventQueue.clear();
    socketChannel?.sink.close();
    super.onClose();
  }

 /* Future<void> getDevices() async {
    try {
      final List<Device>? value = await Traccar.getDevices();
      if (value != null) {
        final Map<int, Device> deviceMap = {
          for (final device in value) device.id!: device
        };
        devices.assignAll(deviceMap);
      }
      _initSocket();
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }*/
  Future<void> getDevices() async{
    Traccar.getDevices().then((List<Device>? value) {
      if (value != null) {
        final Map<int, Device> deviceMap = {
          for (final device in value) device.id!: device
        };
        devices.assignAll(deviceMap);
      }
    });
  }
 /*Future<void> getDevices() async{
    Traccar.getDevices().then((List<Device>? value) {
      
      value!.forEach((element) {
        devices.putIfAbsent(element.id!, () => element);
        devices.update(element.id!, (value) => element);
      });
        _initSocket();      
    });
  }*/

  Future<void> _initSocket() async {
    try {
      final uri = Uri.parse(Traccar.serverURL!);
      final socketScheme = uri.scheme == "http" ? "ws://" : "wss://";
      final socketURL = uri.hasPort
          ? socketScheme + uri.host + ":" + uri.port.toString() + "/api/socket"
          :  socketScheme + uri.host + "/api/socket";

      socketChannel = IOWebSocketChannel.connect(socketURL, headers: Traccar.headers);
     
      socketChannel!.stream.listen((event) {
         _eventQueue.add(event);
        _startThrottledProcessing();
        isLoading.value = false; 
      },
      /*  onDone: () {
          isLoading.value = false;
          socketChannel!.sink.close();
        },
        onError: (error) {
          isLoading.value = false;
          socketChannel!.sink.close();
          print('ws error $error');
        },*/);
    } catch (e) {
      print('Error connecting socket: $e');
    }
  }
  void _startThrottledProcessing() {
    if (_isThrottled || _eventQueue.isEmpty) return;

    _isThrottled = true;
    final nextEvent = _eventQueue.removeFirst();
    _processSocketData(nextEvent);

    Timer(throttleDuration, () {
      _isThrottled = false;
      _startThrottledProcessing(); // Continue with next queued event
    });
  }
   Future<void> _processSocketData(String event) async {
    try {
      final data = json.decode(event);

      if (data["events"] != null) {
        Iterable rawEvents = data["events"];
        List<Event> newEvents = rawEvents.map((model) => Event.fromJson(model)).toList();
        for (var event in newEvents) {         
          if (event.id != null && _eventIds.add(event.id!)) {
            events.add(event);
          }
        }
        isEventLoading.value = false;
      }


      if (data["positions"] != null) {
        Iterable pos = data["positions"];
        List<Position> posList = pos.map((model) => Position.fromJson(model)).toList();
        for (final element in posList) {
          if (element.address == null || element.address!.isEmpty) {
            String key = _latLngKey(element.latitude!, element.longitude!);
            if (_addressCache.containsKey(key)) {
              element.address = _addressCache[key];
            } else {
              final resolvedAddress = await getAddressFromLatLng2(element.latitude!, element.longitude!);
              if (resolvedAddress != null) {
                _addressCache[key] = resolvedAddress;
                element.address = resolvedAddress;
              }
            }
          }
          positions[element.deviceId!] = element;
        }
      }
        if (data["devices"] != null) {
            Iterable events = data["devices"];
            List<Device> deviceList =
                events.map((model) => Device.fromJson(model)).toList();
            deviceList.forEach((Device element) {
              devices.putIfAbsent(element.id!, () => element);
              devices.update(element.id!, (value) => element);
            });
          }
          isLoading.value = false;

    } catch (e) {
      print('Error processing socket data: $e');
    }
  }
 
  Future<void> initSocket() async{
    var uri = Uri.parse(Traccar.serverURL!);
    String socketScheme, socketURL;
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

    socketChannel =
        new IOWebSocketChannel.connect(socketURL, headers: Traccar.headers);

    try {
      socketChannel!.stream.listen(
        (event) {
          var data = json.decode(event);
          print(data);
        /*  if (data["events"] != null) {
            Iterable events = data["events"];
            events.map((model) => Event.fromJson(model)).toList();
          }*/
         
          if (data["events"] != null) {
            Iterable rawEvents = data["events"];
            List<Event> newEvents = rawEvents.map((model) => Event.fromJson(model)).toList();
           // events.addAll(newEvents);
           for (var event in newEvents) {
              if (!events.any((e) => e.id == event.id)) {
                events.add(event);
              }
            }
            isEventLoading.value = false;
          }


          if (data["positions"] != null) {
            Iterable pos = data["positions"];
            List<Position> posList =
                pos.map((model) => Position.fromJson(model)).toList();
            posList.forEach((Position element) async {
              //check if the address is empty
              if(element.address == null || element.address!.isEmpty)
              {
                String? resolvedAddress = await this.getAddressFromLatLng2(element.latitude!, element.longitude!);
                if(resolvedAddress != null) {
                  element.address = resolvedAddress;
                }
              }
              positions.putIfAbsent(element.deviceId!, () => element);
              positions.update(element.deviceId!, (value) => element);
            });
          }

          if (data["devices"] != null) {
            Iterable events = data["devices"];
            List<Device> deviceList =
                events.map((model) => Device.fromJson(model)).toList();
            deviceList.forEach((Device element) {
              devices.putIfAbsent(element.id!, () => element);
              devices.update(element.id!, (value) => element);
            });
          }
          isLoading.value = false;
        },
        onDone: () {
          isLoading.value = false;
          socketChannel!.sink.close();
        },
        onError: (error) {
          isLoading.value = false;
          socketChannel!.sink.close();
          print('ws error $error');
        },
      );
    } catch (error) {
      isLoading.value = false;
      socketChannel!.sink.close();
      print('ws error $error');
    }
  }


  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    final String apiKey = "AIzaSyDiA_r18xLZ5BPEu6xuFfmeX8mP0p_15Qs";
    //final String url = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng';
    final String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";
    try{

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'OK') {
          return jsonResponse['results'][0]['formatted_address'];
          //var res = jsonResponse['display_name'];
          //return res;
        } else {
          print('Could not load address: ${jsonResponse['status']}');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    }catch(error){
      print('getAddressFromLatLng error: $error');
    }
    return null;
  }
  
 Future<String?> getAddressFromLatLng2(double lat, double lng) async {
  final String url = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng';

  try {
    final response = await http.get(Uri.parse(url));//, headers: {
    //  'User-Agent': 'YourAppNameHere' // VERY IMPORTANT: Nominatim requires a valid User-Agent
    //});

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('display_name')) {
        return jsonResponse['display_name'];
      } else {
        print('display_name not found in response.');
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('getAddressFromLatLng2 error: $error');
  }
  return null;
}

}

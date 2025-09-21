class Server {
  int? id;
  Map<String, dynamic>? attributes;
  bool? registration;
  bool? readonly;
  bool? deviceReadonly;
  String? map;
  String? bingKey;
  String? mapUrl;
  dynamic overlayUrl;
  double? latitude;
  double? longitude;
  int? zoom;
  bool? forceSettings;
  String? coordinateFormat;
  bool? limitCommands;
  bool? disableReports;
  bool? fixedEmail;
  String? poiLayer;
  String? announcement;
  bool? emailEnabled;
  bool? geocoderEnabled;
  bool? textEnabled;
  dynamic storageSpace;
  bool? newServer;
  bool? openIdEnabled;
  bool? openIdForce;
  String? version;

  Server(
      {this.id,
      this.attributes,
      this.registration,
      this.readonly,
      this.deviceReadonly,
      this.map,
      this.bingKey,
      this.mapUrl,
      this.overlayUrl,
      this.latitude,
      this.longitude,
      this.zoom,
      this.forceSettings,
      this.coordinateFormat,
      this.limitCommands,
      this.disableReports,
      this.fixedEmail,
      this.poiLayer,
      this.announcement,
      this.emailEnabled,
      this.geocoderEnabled,
      this.textEnabled,
      this.storageSpace,
      this.newServer,
      this.openIdEnabled,
      this.openIdForce,
      this.version});

  Server.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    attributes = json["attributes"];
    registration = json['registration'];
    readonly = json['readonly'];
    deviceReadonly = json['deviceReadonly'];
    map = json['map'];
    bingKey = json['bingKey'];
    mapUrl = json['mapUrl'];
    overlayUrl = json['overlayUrl'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    zoom = json['zoom'];
    forceSettings = json['forceSettings'];
    coordinateFormat = json['coordinateFormat'];
    limitCommands = json['limitCommands'];
    disableReports = json['disableReports'];
    fixedEmail = json['fixedEmail'];
    poiLayer = json['poiLayer'];
    announcement = json['announcement'];
    emailEnabled = json['emailEnabled'];
    geocoderEnabled = json['geocoderEnabled'];
    textEnabled = json['textEnabled'];
    storageSpace = json['storageSpace'];
    newServer = json['newServer'];
    openIdEnabled = json['openIdEnabled'];
    openIdForce = json['openIdForce'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['attributes'] = this.attributes;
    data['registration'] = this.registration;
    data['readonly'] = this.readonly;
    data['deviceReadonly'] = this.deviceReadonly;
    data['map'] = this.map;
    data['bingKey'] = this.bingKey;
    data['mapUrl'] = this.mapUrl;
    data['overlayUrl'] = this.overlayUrl;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['zoom'] = this.zoom;
    data['forceSettings'] = this.forceSettings;
    data['coordinateFormat'] = this.coordinateFormat;
    data['limitCommands'] = this.limitCommands;
    data['disableReports'] = this.disableReports;
    data['fixedEmail'] = this.fixedEmail;
    data['poiLayer'] = this.poiLayer;
    data['announcement'] = this.announcement;
    data['emailEnabled'] = this.emailEnabled;
    data['geocoderEnabled'] = this.geocoderEnabled;
    data['textEnabled'] = this.textEnabled;
    data['storageSpace'] = this.storageSpace;
    data['newServer'] = this.newServer;
    data['openIdEnabled'] = this.openIdEnabled;
    data['openIdForce'] = this.openIdForce;
    data['version'] = this.version;
    return data;
  }
}

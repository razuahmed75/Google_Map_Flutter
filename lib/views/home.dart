import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/utils/map_styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String mapStyles = "";
  @override
  void initState() {
    addMarker();
    _addPolyLines();
    // _gottenUserLocation();
    DefaultAssetBundle.of(context)
        .loadString('json/map_style_standard.json')
        .then((value) => mapStyles = value);
    super.initState();
  }

  List<LatLng> polygonPoints = [
    LatLng(23.574660922973152, 90.4924965477753),
    LatLng(23.57261873176104, 90.50082454169092),
    LatLng(23.5690209697085, 90.50034688571273),
    LatLng(23.561533920688973, 90.49716400937055),
    LatLng(23.569312734479254, 90.48565399845164),
    LatLng(23.57485539658888, 90.49111736577791),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingButton(),
      body: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          markers: _marker,
          circles: {
            Circle(
              circleId: CircleId('1'),
              center: centerLocation ?? _lat[0],
              strokeWidth: 1,
              strokeColor: Colors.black54,
              radius: 350,
              fillColor: Color(0xff006491).withOpacity(0.2),
            )
          },
          polygons: {
            Polygon(
              polygonId: PolygonId("1"),
              points: polygonPoints,
              fillColor: Colors.redAccent.withOpacity(0.3),
              strokeWidth: 2,
              strokeColor: Colors.redAccent,
              geodesic: true,
            )
          },
          polylines: _polylines,
          initialCameraPosition: CameraPosition(
            target: _lat[0],
            zoom: 14,
          )),
    );
  }

  // google map controller
  Completer<GoogleMapController> _controller = Completer();

  // onMapCreated function
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    controller.setMapStyle(mapStyles);
  }

  // set of marker
  final Set<Marker> _marker = {};

  // set of polylines
  final Set<Polyline> _polylines = {};
  List<LatLng> polyList = [
    LatLng(23.55759595578795, 90.49387551091014),
    LatLng(23.561485217769523, 90.4852301081005),
    LatLng(23.5699933967236, 90.4857600461572),
  ];
  void _addPolyLines() {
    _polylines.add(Polyline(
      polylineId: PolylineId('1'),
      points: polyList,
      color: Colors.orangeAccent,
    ));
  }

  // marker function
  List<String> _image = [
    "assets/shop0.png",
    "assets/shop2.png",
    "assets/shop1.png",
  ];
  List<LatLng> _lat = [
    LatLng(23.572639535343484, 90.49155706960619),
    LatLng(23.572368637269534, 90.49821817284665),
    LatLng(23.570368319079503, 90.49410330320164),
  ];
  List _title = [
    'First Location',
    'Second Location',
    'Third Location',
  ];
  List _snippet = [
    'This is my first location',
    'This is my second location',
    'This is my third location',
  ];
  Future<BitmapDescriptor> getMarkerImage(path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List markerImage = data.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(markerImage);
  }

  void addMarker() async {
    for (int i = 0; i < _lat.length; i++) {
      _marker.add(
        Marker(
          markerId: MarkerId(_title[i]),
          // consumeTapEvents: true,
          position: _lat[i],
          icon: await getMarkerImage(_image[i]),
          infoWindow: InfoWindow(
            title: _title[i],
            snippet: _snippet[i],
          ),
        ),
      );
    }
    setState(() {});
  }

  // get polygon area
  var centerLocation;
  getCenterLoation(lat, lng) {
    centerLocation = LatLng(lat, lng);
    return centerLocation;
  }

  Future<BitmapDescriptor> getDeviceMarker() async {
    final ByteData data = await rootBundle.load('assets/mobile.png');
    final Uint8List markerImage = data.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(markerImage);
  }

  // animate camera position
  void _animateToUser(lat, lng) async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 15,
    )));
    setState(() {});
  }

  // inital method for getting user's current location
  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error' + error.toString());
    });

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // finally gotten the user's location
  _gottenUserLocation() {
    _getUserCurrentLocation().then((value) async {
      _marker.add(Marker(
          markerId: MarkerId('4'),
          position: LatLng(value.latitude, value.longitude),
          icon: await getDeviceMarker(),
          infoWindow: InfoWindow(
            title: 'Device Location',
            snippet: 'This is the current device location',
          )));
      _animateToUser(value.latitude, value.longitude);
      getCenterLoation(value.latitude, value.longitude);
    });
  }

  FloatingActionButton _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: _gottenUserLocation,
      backgroundColor: Colors.white,
      tooltip: 'Current Location',
      child: Icon(
        Icons.my_location_rounded,
        color: Colors.black,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Google Map'),
      centerTitle: true,
      backgroundColor: Colors.deepPurple,
      actions: [
        PopupMenuButton(
          color: Colors.white,
          icon: Icon(Icons.more_vert),
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) => [
            PopupMenuItem(child: Text("Default"), value: 1),
            PopupMenuItem(child: Text("Dark"), value: 2),
            PopupMenuItem(child: Text("Night"), value: 3),
            PopupMenuItem(child: Text("Retro"), value: 4),
            PopupMenuItem(child: Text("Silver"), value: 5),
            PopupMenuItem(child: Text("Aubergine"), value: 6),
          ],
          onSelected: (val) => MapStyle(val, _controller, context),
        ),
      ],
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.deepPurple,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
  // void _onAddMarkerButtonPressed() async {
  //   setState(() async {
  //     _marker.addAll(
  //       [
  //         Marker(
  //           markerId: MarkerId("1"),
  //           position: firstLocation,
  //           icon: await getMarkerImage(),
  //           infoWindow: InfoWindow(
  //             title: 'First Location',
  //             snippet: 'This is my first location',
  //           ),
  //         ),
  //         Marker(
  //           markerId: MarkerId("2"),
  //           position: secondLocation,
  //           icon: await getMarkerImage(),
  //           infoWindow: InfoWindow(
  //             title: 'Second Location',
  //             snippet: 'This is the second location',
  //           ),
  //         ),
  //         Marker(
  //           markerId: MarkerId("3"),
  //           position: thirdLocation,
  //           icon: await getMarkerImage(),
  //           infoWindow: InfoWindow(
  //             title: 'Third Location',
  //             snippet: 'This is the third location',
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }
}

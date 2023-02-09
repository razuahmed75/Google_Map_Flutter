import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/widgets/custom_info_window_tile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class CustomMarkerInfoWindowScreen extends StatefulWidget {
  CustomMarkerInfoWindowScreen({super.key});

  @override
  State<CustomMarkerInfoWindowScreen> createState() =>
      _CustomMarkerInfoWindowScreenState();
}

class _CustomMarkerInfoWindowScreenState
    extends State<CustomMarkerInfoWindowScreen> {
  @override
  void initState() {
    addMarker();
    super.initState();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

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
      body: Stack(
        children: [
          GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
              },
              onCameraMove: (position) {
                _customInfoWindowController.onCameraMove!();
              },
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              markers: _marker,
              // circles: {
              //   Circle(
              //     circleId: CircleId('1'),
              //     center: centerLocation ?? _lat[0],
              //     strokeWidth: 1,
              //     strokeColor: Colors.black54,
              //     radius: 750,
              //     fillColor: Color(0xff006491).withOpacity(0.2),
              //   )
              // },
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
              initialCameraPosition: CameraPosition(
                target: _lat[0],
                zoom: 14,
              )),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 230,
            width: 300,
            offset: 35,
          )
        ],
      ),
    );
  }

  // google map controller
  Completer<GoogleMapController> _controller = Completer();

  // onMapCreated function
  void _onMapCreated(GoogleMapController controller) =>
      _customInfoWindowController.googleMapController = controller;
  // void _onMapCreated(GoogleMapController controller) =>
  //     _controller.complete(controller);
  // set of marker
  final Set<Marker> _marker = {};

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
            draggable: true,
            onDragEnd: (updatedLatLng) {},
            onTap: () {
              _customInfoWindowController.addInfoWindow!(
                WindowTile(),
                _lat[i],
              );
            }
            // infoWindow: InfoWindow(
            //   title: _title[i],
            //   snippet: _snippet[i],
            // ),
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
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.deepPurple,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
}

// import 'dart:ui' as ui;
// import 'package:custom_info_window/custom_info_window.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class CustomMarkerInfoWindowScreen extends StatefulWidget {
//   const CustomMarkerInfoWindowScreen({Key? key}) : super(key: key);

//   @override
//   _CustomMarkerInfoWindowScreenState createState() =>
//       _CustomMarkerInfoWindowScreenState();
// }

// class _CustomMarkerInfoWindowScreenState
//     extends State<CustomMarkerInfoWindowScreen> {
//   CustomInfoWindowController _customInfoWindowController =
//       CustomInfoWindowController();

//   final double _zoom = 15.0;
//   Set<Marker> _markers = {};

//   List<LatLng> _lat = [
//     LatLng(23.572639535343484, 90.49155706960619),
//     LatLng(23.572368637269534, 90.49821817284665),
//     LatLng(23.570368319079503, 90.49410330320164),
//   ];

//   List<String> images = [
//     'assets/shop0.png',
//     'assets/shop1.png',
//   ];

//   // Uint8List? markerImage;

//   // Future<Uint8List> getBytesFromAsset(String path, int width) async {
//   //   ByteData data = await rootBundle.load(path);
//   //   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//   //       targetWidth: width);
//   //   ui.FrameInfo fi = await codec.getNextFrame();
//   //   return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//   //       .buffer
//   //       .asUint8List();
//   // }
//   Future<BitmapDescriptor> getMarkerImage(path) async {
//     final ByteData data = await rootBundle.load(path);
//     final Uint8List markerImage = data.buffer.asUint8List();
//     return BitmapDescriptor.fromBytes(markerImage);
//   }

//   @override
//   void dispose() {
//     _customInfoWindowController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     loadData();
//   }
//   //Set<Marker> _markers = {};

//   loadData() async {
//     for (int i = 0; i < images.length; i++) {
//       // if (i == 1) {
//       _markers.add(Marker(
//           markerId: MarkerId('2'),
//           position: _lat[0],
//           icon: await getMarkerImage(images[i]),
//           onTap: () {
//             _customInfoWindowController.addInfoWindow!(
//               Column(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.blue,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.account_circle,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                             SizedBox(
//                               width: 8.0,
//                             ),
//                             Text(
//                               "I am here",
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .headline6!
//                                   .copyWith(
//                                     color: Colors.white,
//                                   ),
//                             )
//                           ],
//                         ),
//                       ),
//                       width: double.infinity,
//                       height: double.infinity,
//                     ),
//                   ),
//                   // Triangle.isosceles(
//                   //   edge: Edge.BOTTOM,
//                   //   child: Container(
//                   //     color: Colors.blue,
//                   //     width: 20.0,
//                   //     height: 10.0,
//                   //   ),
//                   // ),
//                 ],
//               ),
//               _lat[0],
//             );
//           }));
//       // }
//       //else {
//       //   _markers.add(Marker(
//       //       markerId: MarkerId(i.toString()),
//       //       position: _lat[1],
//       //       icon: await getMarkerImage(images[i]),
//       //       onTap: () {
//       //         _customInfoWindowController.addInfoWindow!(
//       //           Container(
//       //             width: 300,
//       //             height: 200,
//       //             decoration: BoxDecoration(
//       //               color: Colors.white,
//       //               border: Border.all(color: Colors.grey),
//       //               borderRadius: BorderRadius.circular(10.0),
//       //             ),
//       //             child: Column(
//       //               mainAxisAlignment: MainAxisAlignment.start,
//       //               crossAxisAlignment: CrossAxisAlignment.start,
//       //               children: [
//       //                 Container(
//       //                   width: 300,
//       //                   height: 100,
//       //                   decoration: BoxDecoration(
//       //                     image: DecorationImage(
//       //                         image: NetworkImage(
//       //                             'https://images.pexels.com/photos/1566837/pexels-photo-1566837.jpeg?cs=srgb&dl=pexels-narda-yescas-1566837.jpg&fm=jpg'),
//       //                         fit: BoxFit.fitWidth,
//       //                         filterQuality: FilterQuality.high),
//       //                     borderRadius: const BorderRadius.all(
//       //                       Radius.circular(10.0),
//       //                     ),
//       //                     color: Colors.red,
//       //                   ),
//       //                 ),
//       //                 Padding(
//       //                   padding:
//       //                       const EdgeInsets.only(top: 10, left: 10, right: 10),
//       //                   child: Row(
//       //                     children: [
//       //                       SizedBox(
//       //                         width: 100,
//       //                         child: Text(
//       //                           'Beef Tacos',
//       //                           maxLines: 1,
//       //                           overflow: TextOverflow.fade,
//       //                           softWrap: false,
//       //                         ),
//       //                       ),
//       //                       const Spacer(),
//       //                       Text(
//       //                         '.3 mi.',
//       //                         // widget.data!.date!,
//       //                       )
//       //                     ],
//       //                   ),
//       //                 ),
//       //                 Padding(
//       //                   padding:
//       //                       const EdgeInsets.only(top: 10, left: 10, right: 10),
//       //                   child: Text(
//       //                     'Help me finish these tacos! I got a platter from Costco and it’s too much.',
//       //                     maxLines: 2,
//       //                   ),
//       //                 ),
//       //               ],
//       //             ),
//       //           ),
//       //           _lat[1],
//       //         );
//       //       }));
//       // }

//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // loadData() ;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Custom Info Window Example'),
//         backgroundColor: Colors.red,
//       ),
//       body: Stack(
//         children: <Widget>[
//           GoogleMap(
//             onTap: (position) {
//               _customInfoWindowController.hideInfoWindow!();
//             },
//             onCameraMove: (position) {
//               _customInfoWindowController.onCameraMove!();
//             },
//             onMapCreated: (GoogleMapController controller) async {
//               _customInfoWindowController.googleMapController = controller;
//             },
//             markers: _markers,
//             initialCameraPosition: CameraPosition(
//               target: _lat[0],
//               zoom: _zoom,
//             ),
//           ),
//           CustomInfoWindow(
//             controller: _customInfoWindowController,
//             height: 200,
//             width: 300,
//             offset: 35,
//           ),
//         ],
//       ),
//     );
//   }
// }

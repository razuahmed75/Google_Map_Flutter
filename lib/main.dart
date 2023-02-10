import 'package:flutter/material.dart';
import 'package:google_map/views/coordinates_address.dart';
import 'package:google_map/views/google_search_places.dart';
import 'package:google_map/views/home.dart';

import 'views/auto_complete_search.dart';
import 'views/custom_marker_network_image.dart';
import 'views/custominfowindow.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Map',
      home: GoogleSearchPlace(),
    );
  }
}

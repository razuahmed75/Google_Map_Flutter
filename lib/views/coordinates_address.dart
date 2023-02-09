import 'package:flutter/material.dart';
// import 'package:flutter_geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';

class CoordinatesAddress extends StatefulWidget {
  const CoordinatesAddress({super.key});

  @override
  State<CoordinatesAddress> createState() => _CoordinatesAddressState();
}

class _CoordinatesAddressState extends State<CoordinatesAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data ?? 'nothing'),
              SizedBox(height: 10),
              Text(datas ?? 'nothing'),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _geoCoding,
                child: Container(
                  color: Colors.green,
                  alignment: Alignment.center,
                  height: 50,
                  width: double.maxFinite,
                  child: Text("Convert"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ========================Geocoding latest one===================================
  Future _geoCoding() async {
    List<Location> locations =
        await locationFromAddress("Gronausestraat 710, Enschede");
    List<Placemark> placemarks =
        await placemarkFromCoordinates(23.570243295746046, 90.4937850316827);
    setState(() {
      var place = placemarks.reversed.last;

      datas = place.locality.toString() +
          ',' +
          place.subAdministrativeArea.toString() +
          ',' +
          place.administrativeArea.toString() +
          ',' +
          place.country.toString();

      data = 'lat= ' +
          locations.last.latitude.toString() +
          ' lng= ' +
          locations.last.longitude.toString();
    });
  }

  /// ========================Flutter Geocoder older version=============================
  var data;
  var datas;
  // Future _coordinateAddress() async {
  //   // From a query
  //   final query = "1600 Amphiteatre Parkway, Mountain View";

  //   var addresses = await Geocoder.local.findAddressesFromQuery(query);

  //   var first = addresses.first;

  //   datas = first.featureName.toString() + first.coordinates.toString();

  //   // From coordinates
  //   final coordinates = new Coordinates(23.570243295746046, 90.4937850316827);

  //   var address =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);

  //   first = address.first;

  //   data = first.locality.toString() +
  //       ',' +
  //       first.subAdminArea.toString() +
  //       ',' +
  //       first.adminArea.toString() +
  //       ',' +
  //       first.countryName.toString();

  //   setState(() {});
  // }
}

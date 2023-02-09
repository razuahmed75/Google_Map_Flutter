import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../utils/consts.dart';
import 'package:http/http.dart' as http;

class GoogleSearchPlace extends StatefulWidget {
  const GoogleSearchPlace({super.key});

  @override
  State<GoogleSearchPlace> createState() => _GoogleSearchPlaceState();
}

class _GoogleSearchPlaceState extends State<GoogleSearchPlace> {
  final _controller = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = "";
  List<dynamic> _placeList = [];

  @override
  void initState() {
    _controller.addListener(() {
      _onChanged();
    });
    super.initState();
  }

  void _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    _getSuggestion(_controller.text);
  }

  var statusCode;
  var data;
  Future _getSuggestion(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      statusCode = response.statusCode;
      data = response.body;
      print(statusCode);
      setState(() {
        _placeList = jsonDecode(response.body.toString())['predictions'];
        print(response.body.toString());
      });
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search place with name',
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text(data.toString()),
            Expanded(
                child: ListView.builder(
                    itemCount: _placeList.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                        title: Text(_placeList[index]['description'] + 'hello'),
                      );
                    })),
          ],
        ),
      )),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Google Search Places api'),
      centerTitle: true,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.blue,
      ),
    );
  }
}

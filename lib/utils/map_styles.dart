import 'package:flutter/material.dart';

void MapStyle(val, _controller, context) {
  if (val == 1) {
    _controller.future.then((style) {
      DefaultAssetBundle.of(context)
          .loadString('json/map_style_standard.json')
          .then((value) {
        style.setMapStyle(value);
      });
    });
  } else if (val == 2) {
    _controller.future.then((style) {
      DefaultAssetBundle.of(context)
          .loadString('json/map_style_dark.json')
          .then((value) {
        style.setMapStyle(value);
      });
    });
  } else if (val == 3) {
    _controller.future.then((style) {
      DefaultAssetBundle.of(context)
          .loadString('json/map_style_night.json')
          .then((value) {
        style.setMapStyle(value);
      });
    });
  } else if (val == 4) {
    _controller.future.then((style) {
      DefaultAssetBundle.of(context)
          .loadString('json/map_style_retro.json')
          .then((value) {
        style.setMapStyle(value);
      });
    });
  } else if (val == 5) {
    _controller.future.then((style) {
      DefaultAssetBundle.of(context)
          .loadString('json/map_style_silver.json')
          .then((value) {
        style.setMapStyle(value);
      });
    });
  } else if (val == 6) {
    _controller.future.then((style) {
      DefaultAssetBundle.of(context)
          .loadString('json/map_style_aubergine.json')
          .then((value) {
        style.setMapStyle(value);
      });
    });
  }
}

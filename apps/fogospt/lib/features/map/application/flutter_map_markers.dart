import 'package:flutter/material.dart';
import 'package:fogos_api/features/latest_warnings/domain/fire.dart';
import 'package:fogos_api/features/latest_warnings/domain/fires.dart';
import 'package:fogospt/features/map/presentation/marker/marker_importance.dart';
import 'package:fogospt/features/map/presentation/marker/warning_marker.dart';
import 'package:latlong2/latlong.dart';

typedef MarkerTapped = void Function(Fire fire);

class FlutterMapMarkers {
  final Fires fires;

  final MarkerTapped onMarkerTapped;

  final Widget markerIcon;

  static const _defaultMarkerIcon = Icon(
    Icons.fireplace,
    color: Colors.red,
  );

  FlutterMapMarkers({
    required this.fires,
    required this.onMarkerTapped,
    this.markerIcon = _defaultMarkerIcon,
  });

  List<WarningMarker> processMarkers({bool isActive = true}) {
    final List<WarningMarker> markers = [];

    for (final fire in fires.data.where(
      (fire) => fire.active == isActive,
    )) {
      markers.add(
        WarningMarker(
          point: LatLng(fire.lat, fire.lng),
          onTap: () => onMarkerTapped(fire),
          type: WarningMarkerType.fire,
          importance:
              fire.important ? MarkerImportance.high : MarkerImportance.medium,
        ),
      );
    }

    return markers;
  }
}

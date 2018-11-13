import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:fogosmobile/models/app_state.dart';
import 'package:fogosmobile/models/fire.dart';
import 'package:fogosmobile/actions/fires_actions.dart';

class HomePage extends StatelessWidget {
  MapController mapController;
  LatLng _center = new LatLng(39.806251, -8.088591);
  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, List>(
      converter: (Store<AppState> store) => store.state.fires,
      builder: (BuildContext context, fires) {
        for (final fire in fires) {
          markers.add(
            new Marker(
              width: 50.0,
              height: 50.0,
              point: new LatLng(fire.lat, fire.lng),
              builder: (_) => new Container(
                child: new IconButton(
                  icon: new Icon(
                    Icons.pin_drop,
                    size: 30.0,
                    color: new Color(
                      fire.statusColor == null ? 0xFF000000 : int.parse('0xFF${fire.statusColor}')
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          );
        }

        return new FlutterMap(
          mapController: mapController,
          options: new MapOptions(
            center: _center,
            zoom: 7.0,
          ),
          layers: [
            new TileLayerOptions(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/fogospt/cjgppvcdp00aa2spjclz9sjst/tiles/256/{z}/{x}/{y}?access_token={accessToken}",
              additionalOptions: {
                'accessToken':
                    'pk.eyJ1IjoiZm9nb3NwdCIsImEiOiJjamZ3Y2E5OTMyMjFnMnFxbjAxbmt3bmdtIn0.xg1X-A17WRBaDghhzsmjIA',
                'id': 'mapbox.streets',
              },
            ),
            new MarkerLayerOptions(
              markers: markers,
            ),
          ],
        );
      },
    );
  }
}

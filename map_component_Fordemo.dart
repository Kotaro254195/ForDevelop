import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/app_model.dart';
import 'package:flutter_app/types/result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/parts/Popup.dart';

class MapComponent extends StatefulWidget {
  MapComponent({this.latLag});
  final LatLng latLag;

  @override
  _MapComponent createState() => _MapComponent(latLag);
}

class _MapComponent extends State<MapComponent>{
  LatLng latLag;
  Set<Marker> _markers={};

  int selectedId;
  int old_SelectedId;

  _MapComponent(LatLng latlng){this.latLag=latlng;}

  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    /*
      _controller.future.then(((GoogleMapController googleMap){
        googleMap.animateCamera(CameraUpdate.newLatLng(latLng))
      });*/

    final appModel = Provider.of<AppModel>(context);
    List<Shop> shops=[
      new Shop(name: "a",evaluation: 5,telephone: "00000000000",latLng: LatLng(37.525790, 140.389847),congestion: 90),
      new Shop(name: "b",evaluation: 4,telephone: "11111111111",latLng: LatLng(37.525479, 140.388699),congestion: 70),
      new Shop(name: "c",evaluation: 3,telephone: "22222222222",latLng: LatLng(37.525062, 140.391156),congestion: 20),
    ];
    return new Stack(children: <Widget>[
      StreamBuilder<Set<Marker>>(
          stream: appModel.shopsModel.markersStream,
          builder: (context, markersSnapshot) {
            return Container(
                child: GoogleMap(

                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                    target: latLag,
                    zoom: 14.5,
                    tilt: 45,
                  ),
                  // markers: markersSnapshot.data,
                  markers: _markers,

                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    setState((){
                      shops.asMap().forEach((int i,Shop shop){
                        _markers.add(
                            Marker(
                              markerId: MarkerId(shop.name),
                              position: shop.latLng,
                              infoWindow: InfoWindow(title: shop.name),
                              onTap: (){setState(() {
                                selectedId=i;
                                old_SelectedId=selectedId;
                                print(selectedId);
                                print("hello");
                              });},
                              icon: ((){
                                if(shop.congestion<40){

                                }
                              })(),
                            )
                        );
                      });
                    }
                    );
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                )
            );
          }),
      if(selectedId!=null)Popup(shops: shops,selectedId: selectedId)
    ]);
  }
}
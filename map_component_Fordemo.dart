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

  List<Shop> shops;

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
    shops=[
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
                                // selectedId=null;
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
      if(selectedId!=null)popup()
    ]);
  }

  Widget popup() {
    // return UpperPop(List<Shop> shops) {
    final TextStyle textStyle = TextStyle(fontSize: 20);
    final TextStyle textButtonStyle =
    TextStyle(fontSize: 20, color: Colors.blue);
    final Size displaySize = MediaQuery.of(context).size;

    //数値の評価→星マークに変換 ex.)evaluation:3→"★★★☆☆"
    String toStar(num evaluation) {
      String str = "";
      for (int i = 0; i < 5; i++) {
        if (i < evaluation)
          str += "★";
        else
          str += "☆";
      }
      return str;
    }

    //混雑度をメッセージを含むTextに変換
    Text describeNum(num congestion) {
      String message;
      if (congestion < 40)
        return Text("空いています",
            style: TextStyle(
                color: Colors.blue, fontSize: displaySize.width / 11));
      else if (congestion < 80)
        return Text("すこし混雑しています",
            style: TextStyle(
                color: Colors.yellow,
                backgroundColor: Colors.grey,
                fontSize: displaySize.width / 11));
      else
        return Text("混んでいます",
            style:
            TextStyle(color: Colors.red, fontSize: displaySize.width / 11));
    }

    return Dismissible(
        key: Key(shops[selectedId].name),
        direction: DismissDirection.down,
        // onDismissed: selectedId=null,
        child: Container(
            height: displaySize.height / 3,
            width: displaySize.width,
            color: Colors.white.withOpacity(0.8),
            margin: EdgeInsets.only(top: displaySize.height / 1.6),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            selectedId == null
                                ? shops[0].name
                                : shops[selectedId].name,
                            style: TextStyle(fontSize: displaySize.width / 8),
                          ),
                          Text(selectedId == null
                              ? shops[0].name
                              : "評価:" + toStar(shops[selectedId].evaluation)),
                          Text(selectedId == null
                              ? shops[0].name
                              : "電話番号:" + shops[selectedId].telephone),
                          if (selectedId != null)
                            describeNum(shops[selectedId].congestion),
                        ],
                      )),
                ],
              ),
            )));
  }
}
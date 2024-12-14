import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_rs/app/ui/utils/map_style.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends ChangeNotifier {
  final Map<MarkerId, Marker> _markers = {};

  Set<Marker> get markers => _markers.values.toSet();
  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarketTap => _markersController.stream;

  Position? _initialPosition;
  CameraPosition get initialCameraPosition => CameraPosition(target: LatLng(
                      _initialPosition!.latitude,
                      _initialPosition!.longitude),
                      zoom: 16,
                      );

  bool _loading = true;
  bool get loading => _loading;

  late bool _gpsEnabled;
  bool get gpsEnabled => _gpsEnabled;

  StreamSubscription? _gpsSubscription, _positionSubscription;
  GoogleMapController? _mapController;

  HomeController() {
    _init();
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(mapStyle);
    _mapController=controller;
  }

  Future<void> turnOnGPS() => Geolocator.openLocationSettings();

  Future<void> _init() async {
    _loading = false;
    _gpsEnabled = await Geolocator.isLocationServiceEnabled();
    _gpsSubscription = Geolocator.getServiceStatusStream().listen(
      (status) async {
        _gpsEnabled = status == ServiceStatus.enabled;
       if(_gpsEnabled){
         _initialLocationUpdates();
       }
      },
    );
    _initialLocationUpdates();
    notifyListeners();
  }

 Future<void> _initialLocationUpdates() async {
   bool inialized=false;
  await  _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream().listen(
      (position)async {
        if(!inialized){
          _setInitialPosition(position);
         inialized=true;
         notifyListeners();
        }
        if(_mapController!=null){
          final zoom= await _mapController!.getZoomLevel();
          final cameraUpdate=CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude), 
             zoom);
          _mapController!.animateCamera(cameraUpdate);
        }
    }, 
    onError: (e) {
      if(e is LocationServiceDisabledException){
        _gpsEnabled=false;
        notifyListeners();
      }
    },);
   
  }

 void _setInitialPosition(Position position)  {
    if (_gpsEnabled && _initialPosition==null) {
      _initialPosition = position;
    }
  }

  void onTap(LatLng position) {
    final id = _markers.length.toString();
    final markerId = MarkerId(id);
    final marker = Marker(
        markerId: markerId,
        position: position,
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: () {
          _markersController.sink.add(id);
        },
        onDragEnd: (newPosition) {
          print("New position $newPosition");
        });
    _markers[markerId] = marker;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _gpsSubscription?.cancel();
    _markersController.close();
    super.dispose();
  }
}

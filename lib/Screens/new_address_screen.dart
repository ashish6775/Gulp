import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shop_app/Helpers/location_helper.dart';
import 'package:shop_app/main.dart';
import "package:sizer/sizer.dart";

class NewAddressScreen extends StatefulWidget {
  final LatLng initialLocation;
  final String screen;

  NewAddressScreen(this.initialLocation, this.screen);
  @override
  _NewAddressScreenState createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  Location location = new Location();
  bool _serviceEnabled;

  PermissionStatus _permissionGranted;

  var selectedHome = false;
  var selectedWork = false;
  var selectedOther = false;
  var loading = false;
  LocationData _locationData;
  final _auth = FirebaseAuth.instance;
  LatLng _pickedLocation;
  String _selectedPlace;
  GoogleMapController _controller;
  Completer<GoogleMapController> completer;
  final _formKey = GlobalKey<FormState>();
  var _flat = '';
  var _landmark = '';
  var _type = 'Other';

  void initState() {
    super.initState();
    if (widget.screen == 'One') {
      _selectLocation(widget.initialLocation);
    } else {
      _isLocationEnabled();
    }
  }

  Future<void> _isLocationEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    Future.delayed(Duration(seconds: 1), () async {
      _locationData = await Location().getLocation();
      setState(() {
        coordinates = LatLng(_locationData.latitude, _locationData.longitude);
        _selectLocation(coordinates);
        _controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(coordinates.latitude, coordinates.longitude),
              zoom: 16,
            ),
          ),
        );
      });

      calculateDistance(_locationData.latitude, _locationData.longitude);
    });
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void calculateDistance(lat1, lon1) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((28.4525328 - lat1) * p) / 2 +
        c(lat1 * p) * c(28.4525328 * p) * (1 - c((76.9882145 - lon1) * p)) / 2;
    distance = 12742 * asin(sqrt(a));
    if (distance > 3) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: Text(
                  'Gulp is yet to start services in this area. But we promise we are working hard to make this happen.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
    }
  }

  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
    });

    if (isValid) {
      _formKey.currentState.save();
      String address = _flat + " " + _landmark;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser.uid)
          .collection('addresses')
          .add({
        'address': _flat + " " + _landmark,
        'type': _type,
        'mapAddress':
            GeoPoint(_pickedLocation.latitude, _pickedLocation.longitude),
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser.uid)
          .update({
        'address': _flat + " " + _landmark,
        'mapAddress':
            GeoPoint(_pickedLocation.latitude, _pickedLocation.longitude),
      });
      selectedAddress = _flat + " " + _landmark;
      coordinates = LatLng(_pickedLocation.latitude, _pickedLocation.longitude);
      setState(() {
        loading = false;
      });
      Navigator.of(context).pop(address);
    }
  }

  Future<void> _selectLocation(position) async {
    if (position == null) {
      _selectedPlace = await LocationHelper.getPlaceAddress(
          widget.initialLocation.latitude, widget.initialLocation.longitude);
      setState(() {
        _pickedLocation = position;
        _selectedPlace = _selectedPlace;
      });
    } else {
      _selectedPlace = await LocationHelper.getPlaceAddress(
          position.latitude, position.longitude);
      setState(() {
        _pickedLocation = position;
        _selectedPlace = _selectedPlace;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        backgroundColor: Colors.black12,
      ),
      bottomSheet: !loading
          ? Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.purple,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text(
                                  _selectedPlace == null
                                      ? 'Locating...'
                                      : _selectedPlace,
                                  style: TextStyle(fontSize: 10.0.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.home_work_outlined,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      key: ValueKey('flat'),
                                      style: TextStyle(fontSize: 10.0.sp),
                                      textCapitalization:
                                          TextCapitalization.words,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'This field cannot be blank';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'HOUSE/FLAT/BLOCK NO.',
                                        labelStyle:
                                            TextStyle(fontSize: 10.0.sp),
                                      ),
                                      onSaved: (value) {
                                        _flat = value.trim();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.landscape_outlined,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      key: ValueKey('landmark'),
                                      style: TextStyle(fontSize: 10.0.sp),
                                      textCapitalization:
                                          TextCapitalization.words,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'This field cannot be blank';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'LANDMARK',
                                        labelStyle:
                                            TextStyle(fontSize: 10.0.sp),
                                      ),
                                      onSaved: (value) {
                                        _landmark = value.trim();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        _type = 'Home';
                                        setState(() {
                                          selectedHome = true;
                                          selectedWork = false;
                                          selectedOther = false;
                                        });
                                      },
                                      icon: selectedHome
                                          ? Icon(
                                              Icons.home,
                                              color: Colors.purple,
                                            )
                                          : Icon(
                                              Icons.home_outlined,
                                              color: Colors.purple,
                                            ),
                                      label: Text(
                                        'HOME',
                                        style: TextStyle(
                                            fontSize: 10.0.sp,
                                            color: Colors.purple),
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        _type = 'Work';
                                        setState(() {
                                          selectedHome = false;
                                          selectedWork = true;
                                          selectedOther = false;
                                        });
                                      },
                                      icon: selectedWork
                                          ? Icon(
                                              Icons.work,
                                              color: Colors.purple,
                                            )
                                          : Icon(
                                              Icons.work_outline_rounded,
                                              color: Colors.purple,
                                            ),
                                      label: Text('WORK',
                                          style: TextStyle(
                                              fontSize: 10.0.sp,
                                              color: Colors.purple)),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        _type = 'Other';
                                        setState(() {
                                          selectedHome = false;
                                          selectedWork = false;
                                          selectedOther = true;
                                        });
                                      },
                                      icon: selectedOther
                                          ? Icon(
                                              Icons.location_on,
                                              color: Colors.purple,
                                            )
                                          : Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.purple,
                                            ),
                                      label: Text('OTHERS',
                                          style: TextStyle(
                                              fontSize: 10.0.sp,
                                              color: Colors.purple)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.purple),
                          ),
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(5),
                          // ),
                          // minWidth: double.infinity,

                          onPressed: _trySubmit,
                          child: Text(
                            'SAVE AND PROCEED',
                            style: TextStyle(
                              fontSize: 10.0.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Container(),
      body: !loading
          ? Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      //completer.complete(controller);
                    },
                    padding: EdgeInsets.only(),
                    //myLocationButtonEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.initialLocation.latitude,
                        widget.initialLocation.longitude,
                      ),
                      zoom: 16,
                    ),
                    onCameraMove: (CameraPosition position) {
                      _selectLocation(position.target);
                    },
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_on,
                      size: 50,
                      color: Colors.purple,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Stack(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.my_location,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    //final GoogleMapController controller = await completer.future;
                                    _locationData =
                                        await Location().getLocation();
                                    _controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(_locationData.latitude,
                                              _locationData.longitude),
                                          zoom: 16,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

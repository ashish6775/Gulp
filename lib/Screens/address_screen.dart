import 'dart:math' show cos, sqrt, asin;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shop_app/Screens/place_service.dart';
import 'package:uuid/uuid.dart';
import 'address_search.dart';
import 'new_address_screen.dart';
import '../main.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Stream<QuerySnapshot> stream;
  final _auth = FirebaseAuth.instance;
  bool _serviceEnabled;
  Location location = new Location();
  LocationData locationData;
  final _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    stream = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection('addresses')
        .orderBy('type')
        .snapshots();
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

  Future<void> newAddressScreen(BuildContext ctx) async {
    String chosenAddress = await Navigator.of(ctx).push<String>(
      MaterialPageRoute(
        builder: (_) {
          return NewAddressScreen(
              LatLng(
                coordinates.latitude,
                coordinates.longitude,
              ),
              "two");
        },
      ),
    );
    setState(() {
      if (chosenAddress != null) {
        selectedAddress = chosenAddress;
      } else {
        return;
      }
    });
    calculateDistance(coordinates.latitude, coordinates.longitude);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          'Manage Addresses',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: stream,
            builder: (ctx, addressSnapshot) {
              if (addressSnapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (addressSnapshot.data.docs.length == 0) {
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.add_location_alt_outlined,
                        color: Colors.purple,
                      ),
                      title: Text(
                        'Add a New Address',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () async {
                        final sessionToken = Uuid().v4();
                        final Suggestion result = await showSearch(
                          context: context,
                          delegate: AddressSearch(sessionToken),
                        );
                        // This will change the text displayed in the TextField
                        if (result != null) {
                          setState(() {
                            _controller.text = result.description;
                          });
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.my_location_outlined,
                        color: Colors.purple,
                      ),
                      title: Text(
                        "Use Current Location",
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () async {
                        _serviceEnabled = await location.serviceEnabled();
                        if (!_serviceEnabled) {
                          _serviceEnabled = await location.requestService();
                          if (!_serviceEnabled) {
                            return;
                          }
                        }
                        Future.delayed(Duration(microseconds: 1), () async {
                          locationData = await Location().getLocation();
                          coordinates = LatLng(
                              locationData.latitude, locationData.longitude);
                          calculateDistance(
                              locationData.latitude, locationData.longitude);
                        });
                        newAddressScreen(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Text(
                          'You don\'t have any addresses saved. Saving address helps you checkout faster.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }
              final address = addressSnapshot.data.docs;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.add_location_alt_outlined,
                      color: Colors.purple,
                    ),
                    title: Text(
                      'Add a New Address',
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () async {
                      final sessionToken = Uuid().v4();
                      final Suggestion result = await showSearch(
                        context: context,
                        delegate: AddressSearch(sessionToken),
                      );
                      // This will change the text displayed in the TextField
                      if (result != null) {
                        setState(() {
                          _controller.text = result.description;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.my_location_outlined,
                      color: Colors.purple,
                    ),
                    title: Text(
                      "Use Current Location",
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () async {
                      _serviceEnabled = await location.serviceEnabled();
                      if (!_serviceEnabled) {
                        _serviceEnabled = await location.requestService();
                        if (!_serviceEnabled) {
                          return;
                        }
                      }
                      Future.delayed(Duration(microseconds: 1), () async {
                        locationData = await Location().getLocation();
                        coordinates = LatLng(
                            locationData.latitude, locationData.longitude);
                        calculateDistance(
                            locationData.latitude, locationData.longitude);
                      });
                      newAddressScreen(context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'SAVED ADDRESSES',
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemBuilder: (context, index) {
                      String type = address[index]['type'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            onTap: () async {
                              setState(() {
                                selectedAddress = address[index]['address'];
                              });
                              GeoPoint geoPoint = address[index]['mapAddress'];
                              coordinates =
                                  LatLng(geoPoint.latitude, geoPoint.longitude);
                              Navigator.of(ctx).pop(selectedAddress);

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_auth.currentUser.uid)
                                  .update({
                                'address': address[index]['address'],
                                'mapAddress': address[index]['mapAddress']
                              });
                            },
                            leading: Icon(
                              type == "Home"
                                  ? Icons.home_outlined
                                  : type == "Work"
                                      ? Icons.work_outline_rounded
                                      : Icons.location_on_outlined,
                              color: Colors.purple,
                            ),
                            title: Text(
                              type,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              address[index]['address'],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_auth.currentUser.uid)
                                    .collection('addresses')
                                    .doc(address[index].id)
                                    .delete();
                              },
                              child: Text(
                                'REMOVE',
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    },
                    itemCount: address.length,
                  ),
                ],
              );
            }),
      ),
    );
  }
}

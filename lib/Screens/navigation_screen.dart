import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Screens/cart_screen.dart';
import 'package:shop_app/Screens/categories_screen.dart';
import 'package:shop_app/Screens/fruits_category_screen.dart';

import 'package:shop_app/Screens/privacy_policy.dart';
import 'package:shop_app/Widgets/badge.dart';
import 'dart:math' show cos, sqrt, asin;

import '../main.dart';
import 'address_screen.dart';
import 'delivery_policy.dart';

import 'orders_screen.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  Location location = new Location();
  bool _serviceEnabled;
  bool switchButton = false;
  bool edit = false;
  bool loading = false;

  PermissionStatus _permissionGranted;
  LocationData locationData;
  final _auth = FirebaseAuth.instance;
  String name = '';

  Stream<QuerySnapshot> stream;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot ds) {
      selectedAddress = ds['address'];
      final mapAddress = ds['mapAddress'];
      double lat = mapAddress.latitude;
      double lng = mapAddress.longitude;
      coordinates = new LatLng(lat, lng);
    }).whenComplete(() {
      setState(() {});
    }).onError((error, stackTrace) => _isLocationEnabled());

    stream = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection('addresses')
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

  void cartScreen(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return CartScreen();
        },
      ),
    );
  }

  Future<void> _isLocationEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        showModalBottomSheet(
            backgroundColor: Colors.purple,
            isDismissible: false,
            enableDrag: false,
            context: context,
            builder: (_) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.location_disabled_sharp,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Device location is off",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                ),
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(5),
                                // ),

                                onPressed: () async {
                                  _serviceEnabled =
                                      await location.serviceEnabled();
                                  if (!_serviceEnabled) {
                                    _serviceEnabled =
                                        await location.requestService();
                                    if (!_serviceEnabled) {
                                      return;
                                    }
                                  }
                                  Navigator.pop(context);
                                  Future.delayed(Duration(microseconds: 1),
                                      () async {
                                    locationData =
                                        await Location().getLocation();
                                    coordinates = LatLng(locationData.latitude,
                                        locationData.longitude);
                                    calculateDistance(locationData.latitude,
                                        locationData.longitude);
                                  });
                                },
                                child: Text(
                                  "TURN ON",
                                  style: TextStyle(
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Turning on device Location will ensure accurate address and hassle free delivery",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )),
              );
            });
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    Future.delayed(Duration(seconds: 1), () async {
      locationData = await Location().getLocation();
      coordinates = LatLng(locationData.latitude, locationData.longitude);
      calculateDistance(locationData.latitude, locationData.longitude);
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    CategoriesScreen(),
    FruitCategoryScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _selectAddress(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: ctx,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder(
                  stream: stream,
                  builder: (ctx, addressSnapshot) {
                    if (addressSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        height: 50,
                      );
                    } else if (addressSnapshot.data.docs.length == 0) {
                      return Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(30.0),
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
                            Container(
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.purple),
                                ),
                                onPressed: () {
                                  _addressScreen(context);
                                },
                                child: Text(
                                  'ADD AN ADDRESS',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final address = addressSnapshot.data.docs;
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            String type = address[index]['type'];
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () async {
                                    setState(() {
                                      selectedAddress =
                                          address[index]['address'];
                                    });

                                    GeoPoint geoPoint =
                                        address[index]['mapAddress'];
                                    coordinates = LatLng(
                                        geoPoint.latitude, geoPoint.longitude);

                                    Navigator.of(ctx).pop();
                                    calculateDistance(coordinates.latitude,
                                        coordinates.longitude);

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
                                ),
                                Divider(),
                              ],
                            );
                          },
                          itemCount: address.length,
                        ),
                        Container(
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.purple),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _addressScreen(context);
                            },
                            child: Text(
                              'ADD NEW ADDRESS',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ],
          ),
        );
      },
    );
  }

  void ordersScreen(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return OrdersScreen();
        },
      ),
    );
  }
  // Future<void> _selectOnMap(double latitude, double longitude) async {
  //   LatLng pickedLocation = await Navigator.of(context).push<LatLng>(
  //     MaterialPageRoute(builder: (ctx) {
  //       return MapScreen(
  //           PlaceLocation(longitude: longitude, latitude: latitude));
  //     }),
  //   );
  //   calculateDistance(pickedLocation.latitude, pickedLocation.longitude);
  //   setState(() {
  //     selectedLocation = selectedLocation;
  //   });
  // }

  Future<void> _addressScreen(BuildContext ctx) async {
    String chosenAddress = await Navigator.of(ctx).push<String>(
      MaterialPageRoute(
        builder: (_) {
          return AddressScreen();
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

  Future<bool> onWillPop() => showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Close the App?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("YES")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("NO")),
          ],
        );
      });

  void privacyPolicy(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return PrivacyPolicy();
        },
      ),
    );
  }

  void deliveryPolicy(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return DeliveryPolicy();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Cart cart = Provider.of<Cart>(context);
    name = _auth.currentUser.displayName;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      onDrawerChanged: (isOpen) {
        if (!isOpen) {
          setState(() {
            edit = false;
          });
        }
      },

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: switchButton
                  ? BoxDecoration(
                      color: Colors.lightGreen,
                    )
                  : BoxDecoration(
                      color: Colors.orange,
                    ),
              child: Text(
                name == null || name == ""
                    ? "Hello Stranger,"
                    : 'Hello ' + name + ',',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person_outline_sharp,
                color: switchButton ? Colors.lightGreen : Colors.orange,
              ),
              title: edit
                  ? TextField(
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(20),
                      ],
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      controller: _controller,
                    )
                  : Text(
                      name == null || name == "" ? "Stranger" : name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              subtitle: Text(
                _auth.currentUser.phoneNumber == null ||
                        _auth.currentUser.phoneNumber == ""
                    ? ""
                    : _auth.currentUser.phoneNumber,
              ),
              trailing: loading
                  ? Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : edit
                      ? IconButton(
                          icon: Icon(
                            Icons.save_outlined,
                            color: switchButton
                                ? Colors.lightGreen
                                : Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              loading = true;
                              _auth.currentUser
                                  .updateDisplayName(_controller.text.trim())
                                  .whenComplete(() {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_auth.currentUser.uid)
                                    .set({
                                  'name': _auth.currentUser.displayName,
                                }, SetOptions(merge: true));
                                setState(() {
                                  loading = false;
                                  edit = false;
                                  name = _auth.currentUser.displayName;
                                });
                              });
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: switchButton
                                ? Colors.lightGreen
                                : Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              edit = true;
                            });
                          },
                        ),
            ),
            Divider(),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                _addressScreen(context);
              },
              leading: Icon(
                Icons.home_outlined,
                color: switchButton ? Colors.lightGreen : Colors.orange,
              ),
              title: Text(
                'Manage Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Add Multiple Address',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                ordersScreen(context);
              },
              leading: Icon(
                Icons.history,
                color: switchButton ? Colors.lightGreen : Colors.orange,
              ),
              title: Text(
                'Past Orders',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Track your Past Orders',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();
                showAboutDialog(
                  context: context,
                  applicationName: 'Gulp',
                  applicationVersion: 'v' + packageInfo.version,
                  applicationIcon: Image.asset(
                    "assets/images/logo.png",
                    height: 50,
                    width: 50,
                  ),
                  children: [
                    Row(
                      children: [
                        Text('Created with '),
                        Icon(
                          Icons.favorite,
                          color: Colors.pink,
                        ),
                        Text(' in India'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Gulp is 100% Made In India online food store. We connect with the local Vendors and Farmers and help them deliver fresh food each day. We are completely bootstrapped with ZERO investors so that our end product always remain cheaper, helping both the customers and mainly local Vendors and Farmers grow :)\n\nMany more things to come. Until then...',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Contact No.: +91 8882644409',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Email: dosaadda@gmail.com',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            privacyPolicy(context);
                          },
                          child: Text("TnC/Privacy Policy",
                              style: TextStyle(
                                color: switchButton
                                    ? Colors.lightGreen
                                    : Colors.orange,
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dashed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            deliveryPolicy(context);
                          },
                          child: Text("Delivery Policy",
                              style: TextStyle(
                                color: switchButton
                                    ? Colors.lightGreen
                                    : Colors.orange,
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dashed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                  ],
                );
              },
              leading: Icon(
                Icons.info_outline,
                color: switchButton ? Colors.lightGreen : Colors.orange,
              ),
              title: Text(
                'About Us',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Contact us/Terms & Links',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text('Do you want to logout?'),
                            contentPadding: EdgeInsets.fromLTRB(24, 5, 24, 24),
                            content: Text(
                              'We will miss you :(',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  cart.clear();
                                  selectedAddress = "";
                                  cartName = "";

                                  //selectedLocation = "";
                                  coordinates = LatLng(0, 0);
                                  FirebaseAuth.instance.signOut();
                                  // GoogleSignIn googleSignIn = GoogleSignIn();
                                  // if (googleSignIn != null) {
                                  //   googleSignIn.signOut();
                                  // } else if (FacebookAuth.instance != null) {
                                  //   FacebookAuth.instance.logOut();
                                  // }
                                  // FacebookAuth.instance.logOut();
                                },
                                child: Text(
                                  'YES',
                                  style: TextStyle(
                                      color: switchButton
                                          ? Colors.lightGreen
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'NO',
                                  style: TextStyle(
                                      color: switchButton
                                          ? Colors.lightGreen
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          );
                        });
                  },
                  child: Text(
                    'LOGOUT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            Divider(),
          ],
        ),
      ),

      appBar: AppBar(
        brightness: switchButton ? Brightness.dark : Brightness.light,
        iconTheme: IconThemeData(
          color: switchButton ? Colors.white : Colors.black,
        ),
        elevation: 0,
        backgroundColor: switchButton ? Colors.lightGreen : Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: GestureDetector(
                    onTap: () {
                      _selectAddress(context);
                    },
                    child: Text(
                      selectedAddress == ""
                          ? "No Address selected yet..."
                          : selectedAddress,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: switchButton ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () {
                    cartScreen(context);
                  },
                  child: Consumer<Cart>(
                    builder: (_, cart, ch) => Badge(
                      child: ch,
                      value: cart.itemCount.toString(),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: switchButton ? Colors.white : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),

      body: WillPopScope(
          child: Container(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          onWillPop: () async {
            final value = await showDialog<bool>(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text("Close the App?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          "YES",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            "NO",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ],
                  );
                });
            return value == true;
          }),
      bottomSheet: Container(
        decoration: BoxDecoration(
            color: Colors.white, border: Border.all(color: Colors.grey)),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  switchButton = false;
                  _onItemTapped(0);
                });
              },
              child: Text(
                'Restaurants',
                style: switchButton
                    ? TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      )
                    : TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
            Switch(
              value: switchButton,
              onChanged: (bool newValue) {
                setState(() {
                  switchButton = newValue;
                });
                if (!switchButton) {
                  _onItemTapped(0);
                } else {
                  _onItemTapped(1);
                }
              },
              inactiveTrackColor: Colors.orange,
              activeTrackColor: Colors.lightGreen,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.orange[900],
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  switchButton = true;
                  _onItemTapped(1);
                });
              },
              child: Text(
                'Fruits/Vegetables',
                style: switchButton
                    ? TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      )
                    : TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   unselectedItemColor: Colors.grey,
      //   selectedItemColor: Colors.purple,
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   items: [
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.home_outlined),
      //         label: "Home",
      //         activeIcon: Icon(Icons.home)),
      //     BottomNavigationBarItem(
      //         icon: Consumer<Cart>(
      //           builder: (_, cart, ch) => Badge(
      //             child: ch,
      //             value: cart.itemCount.toString(),
      //           ),
      //           child: Icon(
      //             Icons.shopping_bag_outlined,
      //           ),
      //         ),
      //         label: "Cart",
      //         activeIcon: Icon(Icons.shopping_bag)),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.account_box_outlined),
      //         label: "Account",
      //         activeIcon: Icon(Icons.account_box)),
      //   ],
      // ),
    );
  }
}

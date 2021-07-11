//import 'dart:html';

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Providers/orders.dart';
import 'package:shop_app/Screens/orders_screen.dart';
import 'package:shop_app/main.dart';
import '../Widgets/cart_item.dart' as ci;
import 'new_address_screen.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool cod = false;
  final _auth = FirebaseAuth.instance;

  Cart cart;
  DateTime deliveryBy;
  Orders order;
  Stream<QuerySnapshot> stream;
  Stream<DocumentSnapshot> stream1;

  double tip = 0.0;
  String request = 'None';
  String txnToken = "";
  bool loading = false;
  var selectedFive = true;
  var selectedZero = false;
  var selectedTen = false;
  var selectedTwenty = false;
  var selectedThirty = false;
  int packaging = 5;
  double wallet = 0;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot ds) {
      wallet = ds['wallet'].toDouble();
    }).whenComplete(() {
      setState(() {});
    }).onError((error, stackTrace) {
      setState(() {
        wallet = 0;
      });
    });
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

  void ordersScreen(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return OrdersScreen();
        },
      ),
    );
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
                                  Navigator.of(context).pop();
                                  newAddressScreen(context);
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
                                    selectedAddress = address[index]['address'];
                                    GeoPoint geoPoint =
                                        address[index]['mapAddress'];
                                    coordinates = LatLng(
                                        geoPoint.latitude, geoPoint.longitude);
                                    Navigator.of(ctx).pop();
                                    calculateDistance(coordinates.latitude,
                                        coordinates.longitude);

                                    setState(() {
                                      selectedAddress =
                                          address[index]['address'];
                                    });
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
                              newAddressScreen(context);
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

  @override
  Widget build(BuildContext context) {
    cart = Provider.of<Cart>(context);
    order = Provider.of<Orders>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: loading == false
          ? AppBar(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: cartName == "Essentials"
                          ? Colors.green
                          : Colors.deepOrange,
                    ),
                  ),
                  Text(
                    'Deliver at ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        selectedAddress == ''
                            ? 'No address selected yet...'
                            : selectedAddress,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _selectAddress(context);
                    },
                    child: Text(
                      'SELECT',
                      style: TextStyle(
                        color: cartName == "Essentials"
                            ? Colors.green
                            : Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              automaticallyImplyLeading: false,
            )
          : null,
      body: loading == false
          ? Builder(
              builder: (BuildContext context) {
                if (cart.items.length == 0) {
                  return Center(
                    child: Text(
                      'No Items in the cart!',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, i) => ci.CartItem(
                            cart.items[i].id,
                            cart.items[i].price,
                            cart.items[i].quantity,
                            cart.items[i].title,
                            cart.items[i].isveg,
                            cart.items[i].index,
                            cart.items[i].pack,
                            cart.items[i].isCustom,
                            cartName == "Essentials"
                                ? Colors.green
                                : Colors.deepOrange,
                          ),
                          itemCount: cart.items.length,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            onChanged: (value) {
                              request = value;
                            },
                            cursorColor: Colors.black,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.sticky_note_2_outlined,
                                color: cartName == "Essentials"
                                    ? Colors.green
                                    : Colors.deepOrange,
                              ),
                              hintText:
                                  "Any special request? We will convey it.",
                              hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black38,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Save environment by Eco-friendly Packaging?'),
                              Text(
                                selectedFive
                                    ? 'Thank you for helping us save our environment.'
                                    : 'Alright! We will save the environment on your behalf.',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      side: BorderSide(
                                          width: 1.5,
                                          color: selectedZero
                                              ? cartName == "Essentials"
                                                  ? Colors.green
                                                  : Colors.deepOrange
                                              : Colors.grey[300]),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedZero = true;
                                        selectedFive = false;
                                        packaging = 0;
                                      });
                                    },
                                    child: Text(
                                      "₹0",
                                      style: TextStyle(
                                          color: selectedZero
                                              ? Colors.black
                                              : Colors.grey),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      side: BorderSide(
                                          width: 1.5,
                                          color: selectedFive
                                              ? cartName == "Essentials"
                                                  ? Colors.green
                                                  : Colors.deepOrange
                                              : Colors.grey[300]),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedZero = false;
                                        selectedFive = true;
                                        packaging = 5;
                                      });
                                    },
                                    child: Text(
                                      "₹5",
                                      style: TextStyle(
                                          color: selectedFive
                                              ? Colors.black
                                              : Colors.grey),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Make your Delivery Person's day!!"),
                              Text(
                                'Support them through these tough times for helping you stay safe indoors.',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      side: BorderSide(
                                          width: 1.5,
                                          color: selectedTen
                                              ? cartName == "Essentials"
                                                  ? Colors.green
                                                  : Colors.deepOrange
                                              : Colors.grey[300]),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (!selectedTen) {
                                          selectedTen = true;
                                          selectedTwenty = false;
                                          selectedThirty = false;
                                          tip = 10;
                                        } else {
                                          selectedTen = false;
                                          selectedTwenty = false;
                                          selectedThirty = false;
                                          tip = 0;
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "₹10",
                                          style: TextStyle(
                                              color: selectedTen
                                                  ? Colors.black
                                                  : Colors.grey),
                                        ),
                                        if (selectedTen)
                                          Icon(
                                            Icons.cancel,
                                            size: 15,
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      side: BorderSide(
                                          width: 1.5,
                                          color: selectedTwenty
                                              ? cartName == "Essentials"
                                                  ? Colors.green
                                                  : Colors.deepOrange
                                              : Colors.grey[300]),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (!selectedTwenty) {
                                          selectedTen = false;
                                          selectedTwenty = true;
                                          selectedThirty = false;
                                          tip = 20;
                                        } else {
                                          selectedTen = false;
                                          selectedTwenty = false;
                                          selectedThirty = false;
                                          tip = 0;
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "₹20",
                                          style: TextStyle(
                                              color: selectedTwenty
                                                  ? Colors.black
                                                  : Colors.grey),
                                        ),
                                        if (selectedTwenty)
                                          Icon(
                                            Icons.cancel,
                                            size: 15,
                                          )
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      side: BorderSide(
                                          width: 1.5,
                                          color: selectedThirty
                                              ? cartName == "Essentials"
                                                  ? Colors.green
                                                  : Colors.deepOrange
                                              : Colors.grey[300]),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (!selectedThirty) {
                                          selectedTen = false;
                                          selectedTwenty = false;
                                          selectedThirty = true;
                                          tip = 30;
                                        } else {
                                          selectedTen = false;
                                          selectedTwenty = false;
                                          selectedThirty = false;
                                          tip = 0;
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "₹30",
                                          style: TextStyle(
                                              color: selectedThirty
                                                  ? Colors.black
                                                  : Colors.grey),
                                        ),
                                        if (selectedThirty)
                                          Icon(
                                            Icons.cancel,
                                            size: 15,
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.black12,
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Bill Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Items Total',
                                    ),
                                    Text(
                                      '₹${(cart.totalAmount).toStringAsFixed(1)}',
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Eco-Friendly Packaging Fee',
                                    ),
                                    Text('₹${(packaging.toStringAsFixed(1))}'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      selectedFive
                                          ? 'Thank you for helping us save our environment.'
                                          : 'Alright! We will save the environment on your behalf.',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Delivery Tip',
                                    ),
                                    Text(
                                      '₹$tip',
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      'This full amount will go to the Delivery patron :)',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Delivery Fee',
                                    ),
                                    Text(
                                      '₹0.0',
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      'We do not charge any Delivery Fee!',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Net Payable',
                                    ),
                                    Text(
                                      '₹${(cart.totalAmount + packaging + tip).toStringAsFixed(1)}',
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Wallet Balance',
                                    ),
                                    wallet >
                                            (cart.totalAmount + packaging + tip)
                                        ? Text(
                                            '-₹${(cart.totalAmount + packaging + tip).toStringAsFixed(1)}',
                                          )
                                        : Text(
                                            '-₹' + wallet.toStringAsFixed(1),
                                          ),
                                  ],
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text(
                              //         'Tax and Charges',
                              //       ),
                              //       Text(
                              //         '₹${(cart.totalAmount * tax).toDouble()}',
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              //Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'To Pay',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        wallet >
                                                (cart.totalAmount +
                                                    packaging +
                                                    tip)
                                            ? '₹0.0'
                                            : '₹${(cart.totalAmount + packaging + tip - wallet).toStringAsFixed(1)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: cartName == "Essentials"
                                          ? Colors.green
                                          : Colors.deepOrange,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.black12,
                          height: 15,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                            title: Text(
                              "Cash on Delivery?",
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              "Due to Covid-19 we recommend you to not use this option to avoid having any contact.",
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: Radio(
                                fillColor: MaterialStateProperty.all<Color>(
                                    cartName == "Essentials"
                                        ? Colors.green
                                        : Colors.deepOrange),
                                value: true,
                                toggleable: true,
                                groupValue: cod,
                                onChanged: (val) {
                                  setState(() {
                                    cod = val;
                                  });
                                })),
                        SizedBox(
                          height: 10,
                        ),
                        cart.items.length == 0
                            ? Container(
                                height: 0,
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: cartName == "Essentials"
                                          ? MaterialStateProperty.all<Color>(
                                              Colors.green)
                                          : MaterialStateProperty.all<Color>(
                                              Colors.deepOrange),
                                    ),
                                    onPressed: () {
                                      if (selectedAddress == "") {
                                        _selectAddress(context);
                                      } else if (distance > 3) {
                                        showDialog(
                                            context: context,
                                            builder: (_) {
                                              return AlertDialog(
                                                content: Text(
                                                    'Gulp is yet to start services in this area. But we promise we are working hard to make this happen.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            });
                                      } else if (cart.totalAmount +
                                              packaging +
                                              tip <
                                          100) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Minimumm order of ₹100 is required'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } else {
                                        FirebaseFirestore.instance
                                            .collection('Branches')
                                            .doc('Branch1')
                                            .get()
                                            .then((value) {
                                          setState(() {
                                            restaurantOpen = value['open'];
                                            if (restaurantOpen ||
                                                cartName == "Essentials") {
                                              openCheckout();
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Restaurant is closed for ordering :('),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          });
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.92,
                                      height: 40,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.shopping_bag_outlined,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'ORDER NOW',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            cartName == "Essentials"
                                                ? "Delivery by: Tomorrow 10-11am"
                                                : "Expected Delivery in 30-40 minutes",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  );
                }
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _razorpay.clear();
  // }

  void openCheckout() async {
    setState(() {
      loading = true;
    });

    List items = [];
    cart.items.forEach((prod) {
      items.add(
          '${prod.title}_${prod.quantity}_${prod.price.toStringAsFixed(0)}_${prod.pack}');
    });

    CollectionReference db = FirebaseFirestore.instance.collection('orders');
    String orderId = db.doc().id;
    String docId; //for essentials
    //for food
    var now = DateTime.now();

    var endTime = DateTime(now.year, now.month, now.day, 23, 59);
    //DateFormat('ddMMyyyy').format(DateTime.now().);
    if (now.isBefore(endTime)) {
      docId =
          DateFormat('ddMMyyyy').format(DateTime(now.year, now.month, now.day));
      if (cartName == "Essentials") {
        deliveryBy = DateTime(now.year, now.month, now.day + 1, 10, 0);
      } else {
        deliveryBy =
            DateTime(now.year, now.month, now.day, now.hour, now.minute + 40);
      }
    } else {
      docId = DateFormat('ddMMyyyy')
          .format(DateTime(now.year, now.month, now.day + 1));
      if (cartName == "Essentials") {
        deliveryBy = DateTime(now.year, now.month, now.day + 2, 10, 0);
      } else {
        deliveryBy =
            DateTime(now.year, now.month, now.day, now.hour, now.minute + 40);
      }
    }

    double finalAmount;
    double fromWallet;

    if (wallet > (cart.totalAmount + packaging + tip)) {
      finalAmount = 0;
      fromWallet = cart.totalAmount + packaging + tip;
    } else {
      finalAmount = cart.totalAmount + packaging + tip - wallet;
      fromWallet = wallet;
    }

    if (cod || finalAmount == 0) {
      setState(() {
        loading = true;
      });
      CollectionReference db = FirebaseFirestore.instance.collection('orders');
      String orderId = db.doc().id;

      WriteBatch writeBatch = FirebaseFirestore.instance.batch();

      writeBatch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser.uid),
          {'wallet': wallet - fromWallet},
          SetOptions(merge: true));

      if (wallet != 0) {
        writeBatch.set(
            FirebaseFirestore.instance
                .collection('users')
                .doc(_auth.currentUser.uid)
                .collection('wallet')
                .doc(),
            {
              'dateTime': DateTime.now(),
              'amountAdded': 0,
              'amountUsed': fromWallet,
              'note': '₹' +
                  fromWallet.toStringAsFixed(0) +
                  " used against order #${orderId.toString().substring(0, 6).toUpperCase()}",
              'cashback': 0,
              'balance': wallet - fromWallet,
            });
      }

      writeBatch.set(db.doc(orderId), {
        'userId': _auth.currentUser.uid,
        'name': _auth.currentUser.displayName,
        'orderId': orderId,
        'dateTime': DateTime.now(),
        'amount': cart.totalAmount + packaging + tip,
        'fromWallet': fromWallet,
        'request': request,
        'payment': 'Cash on Delivery',
        'tip': tip.toDouble(),
        'packaging': packaging.toDouble(),
        'status': cartName == "Food" ? 'Waiting for Approval' : "Order Placed",
        'address': selectedAddress,
        'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
        'number': _auth.currentUser.phoneNumber,
        'deliveryBy': deliveryBy,
        'cart': cartName,
        'items': items,
      });

      if (cartName == "Essentials") {
        cart.items.forEach((prod) {
          writeBatch.set(
              FirebaseFirestore.instance
                  .collection('Branches')
                  .doc('Branch1')
                  .collection('orders')
                  .doc(docId),
              {
                prod.title: FieldValue.increment(prod.quantity),
              },
              SetOptions(merge: true));
        });
        writeBatch.set(
            FirebaseFirestore.instance
                .collection('Branches')
                .doc('Branch1')
                .collection('orders')
                .doc(docId),
            {
              'EssentialRevenue':
                  FieldValue.increment(cart.totalAmount + packaging + tip),
            },
            SetOptions(merge: true));
      } else if (cartName == "Food") {
        writeBatch.set(
            FirebaseFirestore.instance
                .collection('Branches')
                .doc('Branch1')
                .collection('orders')
                .doc(docId),
            {
              'RestaurantRevenue':
                  FieldValue.increment(cart.totalAmount + packaging + tip),
            },
            SetOptions(merge: true));
      }

      writeBatch.commit();

      cart.clear();
      Navigator.of(context).pop();
      ordersScreen(context);
      setState(() {
        //result = value.toString();
      });
    } else {
      var paymentBody = {
        "orderId": orderId,
        "value": finalAmount.toString(),
        "custId": _auth.currentUser.uid,
      };

      print(finalAmount.toString());

      http
          .post(
        Uri.parse(
            "https://us-central1-shop-app-7408b.cloudfunctions.net/paymentFunction"),
        body: paymentBody,
      )
          .then((response1) {
        txnToken = json.decode(response1.body)["body"]["txnToken"];
        setState(() {
          loading = false;
        });

        var response = AllInOneSdk.startTransaction("KGeIop74079861754179",
            orderId, finalAmount.toString(), txnToken, null, false, false);
        response.then((value) async {
          WriteBatch writeBatch = FirebaseFirestore.instance.batch();

          writeBatch.set(
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(_auth.currentUser.uid),
              {'wallet': wallet - fromWallet},
              SetOptions(merge: true));

          if (wallet != 0) {
            writeBatch.set(
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(_auth.currentUser.uid)
                    .collection('wallet')
                    .doc(),
                {
                  'dateTime': DateTime.now(),
                  'amountAdded': 0,
                  'amountUsed': fromWallet,
                  'note': '₹' +
                      fromWallet.toStringAsFixed(0) +
                      " used against order #${orderId.toString().substring(0, 6).toUpperCase()}",
                  'cashback': 0,
                  'balance': wallet - fromWallet,
                });
          }

          writeBatch.set(db.doc(orderId), {
            'userId': _auth.currentUser.uid,
            'name': _auth.currentUser.displayName,
            'orderId': orderId,
            'dateTime': DateTime.now(),
            'amount': cart.totalAmount + packaging + tip,
            'fromWallet': fromWallet,
            'request': request,
            'tip': tip.toDouble(),
            'packaging': packaging.toDouble(),
            'payment': 'Done',
            'status':
                cartName == "Food" ? 'Waiting for Approval' : "Order Placed",
            'address': selectedAddress,
            'coordinates':
                GeoPoint(coordinates.latitude, coordinates.longitude),
            'number': _auth.currentUser.phoneNumber,
            'deliveryBy': deliveryBy,
            'cart': cartName,
            'items': items,
          });

          if (cartName == "Essentials") {
            cart.items.forEach((prod) {
              writeBatch.set(
                  FirebaseFirestore.instance
                      .collection('Branches')
                      .doc('Branch1')
                      .collection('orders')
                      .doc(docId),
                  {
                    prod.title: FieldValue.increment(prod.quantity),
                  },
                  SetOptions(merge: true));
            });
            writeBatch.set(
                FirebaseFirestore.instance
                    .collection('Branches')
                    .doc('Branch1')
                    .collection('orders')
                    .doc(docId),
                {
                  'EssentialRevenue':
                      FieldValue.increment(cart.totalAmount + packaging + tip),
                },
                SetOptions(merge: true));
          } else if (cartName == "Food") {
            writeBatch.set(
                FirebaseFirestore.instance
                    .collection('Branches')
                    .doc('Branch1')
                    .collection('orders')
                    .doc(docId),
                {
                  'RestaurantRevenue':
                      FieldValue.increment(cart.totalAmount + packaging + tip),
                },
                SetOptions(merge: true));
          }

          writeBatch.commit();

          cart.clear();
          Navigator.of(context).pop();
          ordersScreen(context);
          setState(() {
            //result = value.toString();
          });
        }).catchError((onError) {
          if (onError is PlatformException) {
            setState(() {
              //result = onError.message + " \n  " + onError.details.toString();
            });
          } else {
            setState(() {
              //result = onError.toString();
            });
          }
        });
      });
    }
  }
}

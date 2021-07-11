import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

class MyWalletScreen extends StatefulWidget {
  @override
  _MyWalletScreenState createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  TextEditingController _controller;
  bool loading = false;
  double wallet = 0;
  double cashback = 0;
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String txnToken = "";
  Stream<DocumentSnapshot> stream1;
  Stream<QuerySnapshot> stream2;

  @override
  void initState() {
    super.initState();
    stream1 =
        _firestore.collection('users').doc(_auth.currentUser.uid).snapshots();
    stream2 = _firestore
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection("wallet")
        .orderBy("dateTime", descending: true)
        .snapshots();
    _controller = new TextEditingController(text: '499');
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void openCheckout(double amount) async {
    setState(() {
      loading = true;
    });

    CollectionReference db = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .collection("wallet");
    String orderId = db.doc().id;
    //for essentials
    //for food

    var paymentBody = {
      "orderId": orderId,
      "value": amount.toString(),
      "custId": _auth.currentUser.uid,
    };

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
          orderId, amount.toString(), txnToken, null, false, false);
      response.then((value) async {
        if (amount >= 2999) {
          cashback = 151;
        } else if (amount >= 1999) {
          cashback = 101;
        } else if (amount >= 1199) {
          cashback = 51;
        } else {
          cashback = 0;
        }
        WriteBatch writeBatch = _firestore.batch();

        writeBatch.set(db.doc(orderId), {
          'dateTime': DateTime.now(),
          'amountAdded': amount,
          'amountUsed': 0,
          'note': 'Wallet Recharged with ₹' + amount.toStringAsFixed(0),
          'cashback': cashback,
          'balance': wallet + amount + cashback,
        });

        writeBatch
            .update(_firestore.collection('users').doc(_auth.currentUser.uid), {
          'wallet': FieldValue.increment(amount),
        });

        writeBatch.commit();

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

  dialogOpen(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Container(
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.lightGreen,
                    size: 60,
                  ),
                  Text("Add Money to wallet"),
                  Text(
                    "How much would you like to add to your wallet?",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "₹",
                              style: TextStyle(
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(6),
                              ],
                              keyboardType: TextInputType.number,
                            )),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  if (isNumeric(_controller.text)) {
                    if (double.tryParse(_controller.text) >= 1) {
                      openCheckout(double.tryParse(_controller.text));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Minimum value of ₹100 is required'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid value'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Chip(
                    label: Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.lightGreen),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "My Wallet",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.lightGreen,
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: stream1,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var output = snapshot.data.data();
                  if (output['wallet'] == null) {
                    wallet = 0;
                  } else {
                    wallet = output['wallet'].toDouble();
                  }
                }
                return Column(
                  children: [
                    Container(
                      color: Colors.lightGreen,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.lightGreen,
                                    size: 60,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Wallet Balance",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600]),
                                      ),
                                      Text(
                                        wallet == null || wallet == 0
                                            ? "₹0"
                                            : "₹" + wallet.toStringAsFixed(0),
                                        style: TextStyle(
                                            color: Colors.lightGreen,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      dialogOpen(context);
                                    },
                                    child: Chip(
                                        onDeleted: () {
                                          dialogOpen(context);
                                        },
                                        deleteIcon: Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Add Money',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: Colors.lightGreen),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    StreamBuilder(
                        stream: stream2,
                        builder: (ctx, walletSnapshot) {
                          if (walletSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              height: 50,
                            );
                          } else if (walletSnapshot.data.docs.length == 0) {
                            return Container();
                          }
                          final walletDetails = walletSnapshot.data.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final double amountAdded = walletDetails[index]
                                      ['amountAdded']
                                  .toDouble();
                              final double amountUsed =
                                  walletDetails[index]['amountUsed'].toDouble();
                              final double cashbackRec =
                                  walletDetails[index]['cashback'].toDouble();
                              final double balance =
                                  walletDetails[index]['balance'].toDouble();
                              final String note = walletDetails[index]['note'];
                              final DateTime dateTime =
                                  walletDetails[index]['dateTime'].toDate();
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('MMM dd, hh:mm aa')
                                                  .format(dateTime),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            amountAdded == 0
                                                ? Text(
                                                    "Amount Used: ₹" +
                                                        amountUsed
                                                            .toStringAsFixed(0),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                : Text(
                                                    "Amount added: ₹" +
                                                        amountAdded
                                                            .toStringAsFixed(0),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.lightGreen,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                            Text(
                                              note,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            cashbackRec == 0
                                                ? Container()
                                                : Text(
                                                    "₹" +
                                                        cashbackRec
                                                            .toStringAsFixed(
                                                                0) +
                                                        'recieved as cashback',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12)),
                                          ],
                                        ),
                                        Text(
                                          "Balance: ₹" +
                                              balance.toStringAsFixed(0),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              );
                            },
                            itemCount: walletDetails.length,
                          );
                        })
                  ],
                );
              }),
    );
  }
}

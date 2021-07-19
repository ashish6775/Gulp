import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_app/Screens/navigation_screen.dart';

class BeforeSignup extends StatefulWidget {
  @override
  _BeforeSignupState createState() => _BeforeSignupState();
}

class _BeforeSignupState extends State<BeforeSignup> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _referController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool referral = false;
  bool loading = false;

  void _navigationScreen(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return NavigationScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _navigationScreen(context);
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(_auth.currentUser.uid)
                    .set({
                  'phone': _auth.currentUser.phoneNumber.substring(3),
                  'name': _auth.currentUser.displayName == null ||
                          _auth.currentUser.displayName == ""
                      ? "Stranger"
                      : _auth.currentUser.displayName,
                  'wallet': 0,
                }, SetOptions(merge: true));
                if (_auth.currentUser.displayName == null ||
                    _auth.currentUser.displayName == "") {
                  _auth.currentUser.updateDisplayName("Stranger");
                }
              },
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: Theme(
                    data: ThemeData(canvasColor: Colors.transparent),
                    child: Chip(
                      label: Text(
                        " Skip ",
                        style: TextStyle(
                            color: Colors.white60, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor:
                          Colors.black.withOpacity(0.4), // or any other color
                    ),
                  )),
            )
          ],
          elevation: 0,
          backgroundColor: Colors.lightGreen,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.lightGreen,
        body: WillPopScope(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "Hi There!",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "Mind telling us your name?",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Card(
                  elevation: 4,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: "Name",
                      ),
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(20),
                      ],
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      controller: _nameController,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                        value: referral,
                        checkColor: Colors.lightGreen,
                        fillColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        onChanged: (newValue) {
                          setState(() {
                            referral = newValue;
                            _referController.clear();
                          });
                        }),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          referral = !referral;
                          _referController.clear();
                        });
                      },
                      child: Container(
                        child: Text(
                          "Have referral code?",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                if (referral)
                  Card(
                    elevation: 4,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: "Referral Code",
                        ),
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(10),
                        ],
                        keyboardType: TextInputType.number,
                        controller: _referController,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    loading
                        ? Container(
                            child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ))
                        : Container(
                            child: TextButton.icon(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    side: BorderSide(color: Colors.white),
                                  ),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.lightGreen,
                              ),
                              onPressed: () async {
                                if (!referral) {
                                  setState(() {
                                    loading = true;
                                  });

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(_auth.currentUser.uid)
                                      .set({
                                    'phone': _auth.currentUser.phoneNumber
                                        .substring(3),
                                    'name': _nameController.text,
                                    'wallet': 0,
                                    'referredBy': null,
                                    'orders': 0,
                                  }, SetOptions(merge: true)).whenComplete(() {
                                    _auth.currentUser
                                        .updateDisplayName(_nameController.text)
                                        .whenComplete(() {
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.of(context).pop();
                                      _navigationScreen(context);
                                    });
                                  });
                                } else if (_referController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Refer code is empty"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else if (_referController.text.length < 10) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Refer code incorrect"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else if (_referController.text ==
                                    _auth.currentUser.phoneNumber
                                        .substring(3)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Refer code incorrect"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    loading = true;
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .where("phone",
                                          isEqualTo: _referController.text)
                                      .limit(1)
                                      .get()
                                      .then((event) {
                                    if (event.docs.isNotEmpty) {
                                      WriteBatch writeBatch =
                                          _firestore.batch();

                                      writeBatch.set(
                                          _firestore
                                              .collection('users')
                                              .doc(_auth.currentUser.uid),
                                          {
                                            'phone': _auth
                                                .currentUser.phoneNumber
                                                .substring(3),
                                            'name': _nameController.text,
                                            'wallet': 50,
                                            'referredBy': _referController.text,
                                            'orders': 0,
                                          },
                                          SetOptions(merge: true));

                                      writeBatch.set(
                                          _firestore
                                              .collection('users')
                                              .doc(_auth.currentUser.uid)
                                              .collection("wallet")
                                              .doc(),
                                          {
                                            'dateTime': DateTime.now(),
                                            'amountAdded': 50,
                                            'amountUsed': 0,
                                            'note':
                                                '₹50 recieved from referral',
                                            'cashback': 0,
                                            'balance': 50,
                                          },
                                          SetOptions(merge: true));

                                      writeBatch.commit().whenComplete(() {
                                        _auth.currentUser
                                            .updateDisplayName(
                                                _nameController.text)
                                            .whenComplete(() {
                                          setState(() {
                                            loading = false;
                                          });
                                          Navigator.of(context).pop();
                                          _navigationScreen(context);
                                        });
                                      }).onError((error, stackTrace) {
                                        setState(() {
                                          loading = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Something went wrong. Please try again"),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "No matching refer code found"),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }).catchError((e) =>
                                          print("error fetching data: $e"));
                                }
                                //_navigationScreen(context);
                              },
                              label: Text(
                                "CONTINUE   ",
                                style: TextStyle(
                                    color: Colors.lightGreen,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                  ],
                )
              ],
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
            }));
  }
}

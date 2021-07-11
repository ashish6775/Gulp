import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/Widgets/categories_slider.dart';
import 'package:shop_app/Widgets/category_item.dart';
import 'package:in_app_update/in_app_update.dart';

import '../main.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Stream<QuerySnapshot> stream;

  AppUpdateInfo _updateInfo;
  bool cancel = false;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void initState() {
    super.initState();

    checkForUpdate();

    stream = FirebaseFirestore.instance
        .collection('Branches')
        .doc('Branch1')
        .collection('categories')
        .where("type", isEqualTo: "Restaurant")
        .snapshots();
    checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection('Branches')
        .doc('Branch1')
        .get()
        .then((value) {
      setState(() {
        restaurantOpen = value['open'];
      });
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            children: [
              CategoriesSlider(Colors.orange),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                child: Text(
                  "Order By Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                child: Text(
                  "Our Contemporary Take on the Authentic Royal Dishes. Bon Appetite!",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              StreamBuilder(
                stream: stream,
                builder: (ctx, categorySnapshot) {
                  if (categorySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container();
                  }
                  final categoryDocs = categorySnapshot.data.docs;
                  return GridView.builder(
                    itemCount: categoryDocs.length,
                    itemBuilder: (ctx, index) {
                      return CategoryItem(
                          categoryDocs[index]['title'],
                          categoryDocs[index]['url'],
                          categoryDocs[index]['categoryOpen'],
                          categoryDocs[index]['off'],
                          categoryDocs[index]['type'],
                          restaurantOpen);
                    },
                    padding: EdgeInsets.all(10),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          MediaQuery.of(context).size.width * 0.8,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                  );
                },
              ),
              Container(
                height: 50,
              )
            ],
          ),
          if (_updateInfo != null && cancel == false)
            _updateInfo.updateAvailability == UpdateAvailability.updateAvailable
                ? AlertDialog(
                    backgroundColor: Colors.orange,
                    title: Text(
                      "New Update Available! Please Update",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              cancel = true;
                            });
                          },
                          child: Text(
                            'No thanks',
                            style: TextStyle(color: Colors.white),
                          )),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            cancel = true;
                          });
                          InAppUpdate.performImmediateUpdate()
                              .catchError((e) => showSnack(e.toString()));
                        },
                        child: Text(
                          "UPDATE",
                          style: TextStyle(
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : Container()
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/Widgets/categories_slider.dart';
import 'package:shop_app/Widgets/category_item.dart';
import 'package:shop_app/Widgets/single_essential_menu.dart';

class FruitCategoryScreen extends StatefulWidget {
  @override
  _FruitCategoryScreenState createState() => _FruitCategoryScreenState();
}

class _FruitCategoryScreenState extends State<FruitCategoryScreen> {
  Stream<QuerySnapshot> stream;
  Stream<QuerySnapshot> streamSearch;
  final TextEditingController _searchController = TextEditingController();
  bool search = false;
  bool searchStarted = false;
  var queryResultSet = [];

  @override
  void initState() {
    super.initState();

    stream = FirebaseFirestore.instance
        .collection('Branches')
        .doc('Branch1')
        .collection('categories')
        .where("type", isEqualTo: "Essentials")
        .snapshots();
  }

  initiateSearch(value) {
    if (value.length < 3) {
      setState(() {
        searchStarted = false;
      });
    }

    String lowerCaseValue = value.toLowerCase();

    if (queryResultSet.length == 0 && lowerCaseValue.length == 3) {
      setState(() {
        searchStarted = true;
        streamSearch = FirebaseFirestore.instance
            .collection('Branches')
            .doc('Branch1')
            .collection('essentials')
            .where("name", arrayContains: value)
            .snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.lightGreen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                elevation: 4,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Icon(
                        Icons.search_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: "Search from Multiple Categories",
                          ),
                          controller: _searchController,
                          onTap: () {
                            setState(() {
                              search = true;
                            });
                          },
                          onChanged: (val) {
                            initiateSearch(val);
                          },
                        ),
                      ),
                    ),
                    if (search)
                      IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.deepOrange,
                        ),
                        onPressed: () {
                          setState(() {
                            search = false;
                            searchStarted = false;
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          searchStarted
              ? Expanded(child: SingleEssentialMenu(streamSearch))
              : search
                  ? Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Enter atleast 3 letters to start searching",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          CategoriesSlider(Colors.lightGreen),
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
                              "Your daily fresh and healthy intake directly from farm! ",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
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
                                    true,
                                    "0",
                                    categoryDocs[index]['type'],
                                    true,
                                  );
                                },
                                padding: EdgeInsets.all(10),
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      MediaQuery.of(context).size.width * 0.8,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/Widgets/single_essential_menu.dart';

class SearchItemScreen extends StatefulWidget {
  @override
  _SearchItemScreenState createState() => _SearchItemScreenState();
}

class _SearchItemScreenState extends State<SearchItemScreen> {
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot> streamSearch;

  bool search = false;
  bool searchStarted = false;

  initiateSearch(value) {
    if (value.length < 3) {
      setState(() {
        searchStarted = false;
      });
    }

    String lowerCaseValue = value.toLowerCase();

    if (lowerCaseValue.length == 3) {
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                            autofocus: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Search from Multiple Categories",
                            ),
                            controller: _searchController,
                            onTap: () {},
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
                : Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Enter atleast 3 letters to search",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

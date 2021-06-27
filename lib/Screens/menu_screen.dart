import 'package:flutter/material.dart';

import 'package:shop_app/Screens/cart_screen.dart';
import 'package:shop_app/Screens/search_items_screen.dart';

import 'package:shop_app/Widgets/essentials_menu_list.dart';
import 'package:shop_app/Widgets/menu_list.dart';

class MenuScreen extends StatelessWidget {
  final String categoryTitle;
  final bool categoryOpen;
  final String offer;
  final String type;

  MenuScreen(this.categoryTitle, this.categoryOpen, this.offer, this.type);

  void searchItem(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return SearchItemScreen();
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          type == "Essentials"
              ? IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchItem(context);
                  })
              : Container(),
        ],
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          categoryTitle,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: type == "Restaurant"
          ? MenuList(categoryTitle, categoryOpen, offer)
          : EssentialMenuList(categoryTitle),
    );
  }
}

//

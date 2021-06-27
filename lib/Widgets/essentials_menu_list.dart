import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Screens/cart_screen.dart';
import 'package:shop_app/Widgets/single_essential_menu.dart';

import 'package:sizer/sizer.dart';

import '../main.dart';

class EssentialMenuList extends StatefulWidget {
  final String categoryTitle;
  //final bool categoryOpen;
  //final String offer;

  EssentialMenuList(this.categoryTitle);
  @override
  _EssentialMenuListState createState() => _EssentialMenuListState();
}

class _EssentialMenuListState extends State<EssentialMenuList> {
  bool categoryOpen1 = true;
  Stream<QuerySnapshot> stream;

  @override
  void initState() {
    super.initState();
    stream = FirebaseFirestore.instance
        .collection('Branches')
        .doc('Branch1')
        .collection('essentials')
        .where('type', isEqualTo: widget.categoryTitle)
        .orderBy('isAvailable', descending: true)
        .snapshots();
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

  void showDish(BuildContext ctx, String title, double price, String content) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: ctx,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(15),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    child: Image.asset(
                      "assets/images/essentials/$title.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: MediaQuery.of(ctx).size.height * 0.3,
                    ),
                    // CachedNetworkImage(
                    //   imageUrl: imageUrl,
                    //   errorWidget: (context, url, error) => Image.asset(
                    //     'assets/images/food.jpg',
                    //     fit: BoxFit.cover,
                    //   ),
                    //   height: MediaQuery.of(ctx).size.height * 0.3,
                    //   width: double.infinity,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Text(
                                    "₹" + price.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          content,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: cart.itemCount == 0
          ? Container(
              height: 0,
            )
          : Container(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              color:
                  cartName == "Essentials" ? Colors.green : Colors.deepOrange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cart.itemCount < 2
                      ? Text(
                          cart.itemCount.toString() +
                              ' item  |  ₹' +
                              cart.totalAmount.toStringAsFixed(0),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0.sp,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          cart.itemCount.toString() +
                              ' items  |  ₹' +
                              cart.totalAmount.toStringAsFixed(0),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0.sp,
                            color: Colors.white,
                          ),
                        ),
                  Container(
                    child: Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'VIEW CART',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.0.sp,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                cartScreen(context);
                              },
                          ),
                        ),
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      body: SingleEssentialMenu(stream),
    );
  }
}

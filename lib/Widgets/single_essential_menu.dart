import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:sizer/sizer.dart';

import '../main.dart';

class SingleEssentialMenu extends StatefulWidget {
  final Stream<QuerySnapshot> stream;

  SingleEssentialMenu(this.stream);
  @override
  _SingleEssentialMenuState createState() => _SingleEssentialMenuState();
}

class _SingleEssentialMenuState extends State<SingleEssentialMenu> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return StreamBuilder(
        stream: widget.stream,
        builder: (ctx, menuSnapshot) {
          if (menuSnapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          final menuData = menuSnapshot.data.docs;
          return ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final menuTitle = menuData[index]['title'];
              final menuId = menuData[index]['id'];
              final menuContent = menuData[index]['pack'];
              final isAva = menuData[index]['isAvailable'];
              final url = menuData[index]['url'];

              final price1 = menuData[index]['price'];
              final pack = menuData[index]['pack'];
              double price = double.parse(price1);

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                child: Text(
                                  menuTitle,
                                  style: TextStyle(
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                child: Text(
                                  '₹' + price.toStringAsFixed(0) + "/Pack",
                                  style: TextStyle(
                                    fontSize: 10.0.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                "Pack: " + menuContent,
                                style: TextStyle(
                                  fontSize: 9.0.sp,
                                  color: Colors.grey,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Stack(
                              alignment: AlignmentDirectional.topCenter,
                              children: [
                                Container(
                                  height: 130,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  child: !isAva || distance > 3
                                      ? ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                              Colors.grey,
                                              BlendMode.saturation),
                                          child: CachedNetworkImage(
                                            imageUrl: url,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/food.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: url,
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            'assets/images/food.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      distance > 3
                                          ? Stack(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.25,
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              8, 4, 8, 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              "Coming Soon",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: Container(
                                                    padding: EdgeInsets.all(4),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () {},
                                                        splashColor:
                                                            Colors.white54,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : !isAva
                                              ? Stack(
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                      child: Card(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  8, 4, 8, 4),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  "Out of Stock",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: InkWell(
                                                            onTap: () {},
                                                            splashColor:
                                                                Colors.white54,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : !cart.items.any((element) =>
                                                      element.id == menuId)
                                                  ? Stack(
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                          child: Card(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .green),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          8,
                                                                          4,
                                                                          8,
                                                                          4),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    child: Icon(
                                                                      Icons
                                                                          .shopping_bag_outlined,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Text(
                                                                      "Add+",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .green,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned.fill(
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    if (cartName ==
                                                                        "Food") {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (_) {
                                                                            return AlertDialog(
                                                                              title: Text(
                                                                                "Replace Cart Item?",
                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                              ),
                                                                              content: Text(
                                                                                "Your cart contains items from Food Delivery. Do you want to discard the selection and add items from Fruits/Vegetables?",
                                                                                style: TextStyle(color: Colors.grey),
                                                                              ),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    cart.clear();
                                                                                    cart.addItem(menuId, price, menuTitle, true, index, pack, false);
                                                                                    cartName = "Essentials";
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: Text(
                                                                                    "YES",
                                                                                    style: TextStyle(
                                                                                      color: Colors.green,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: Text(
                                                                                    "NO",
                                                                                    style: TextStyle(
                                                                                      color: Colors.green,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          });
                                                                    } else {
                                                                      cart.addItem(
                                                                        menuId,
                                                                        price,
                                                                        menuTitle,
                                                                        true,
                                                                        index,
                                                                        pack,
                                                                        false,
                                                                      );
                                                                      cartName =
                                                                          "Essentials";
                                                                    }
                                                                  });
                                                                },
                                                                splashColor:
                                                                    Colors
                                                                        .white54,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                      child: Card(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  Colors.green),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            8,
                                                                            4,
                                                                            0,
                                                                            4),
                                                                constraints:
                                                                    BoxConstraints(),
                                                                icon: Icon(
                                                                  Icons.remove,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                onPressed: () {
                                                                  setState(
                                                                    () {
                                                                      cart.removeItem(
                                                                          menuId,
                                                                          pack);
                                                                    },
                                                                  );
                                                                }),
                                                            Text(
                                                              cart.items
                                                                  .where((element) =>
                                                                      element
                                                                          .id ==
                                                                      menuId)
                                                                  .fold(
                                                                      0,
                                                                      (previousValue,
                                                                              element) =>
                                                                          previousValue +
                                                                          element
                                                                              .quantity)
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            4,
                                                                            8,
                                                                            4),
                                                                constraints:
                                                                    BoxConstraints(),
                                                                icon: Icon(
                                                                  Icons.add,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                onPressed: () {
                                                                  setState(
                                                                    () {
                                                                      cart.addItem(
                                                                        menuId,
                                                                        price,
                                                                        menuTitle,
                                                                        true,
                                                                        index,
                                                                        pack,
                                                                        false,
                                                                      );
                                                                    },
                                                                  );
                                                                }),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              );
            },
            itemCount: menuData.length,
          );
        });
  }
}

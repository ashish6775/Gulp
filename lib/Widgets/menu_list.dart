import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Screens/cart_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shop_app/Widgets/add_or_remove_option.dart';
import 'package:sizer/sizer.dart';

import '../main.dart';

class MenuList extends StatefulWidget {
  final String categoryTitle;
  final bool categoryOpen;
  final String offer;

  MenuList(this.categoryTitle, this.categoryOpen, this.offer);
  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  bool categoryOpen1 = true;
  Stream<QuerySnapshot> stream;
  Stream<QuerySnapshot> stream2;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    stream = FirebaseFirestore.instance
        .collection('Branches')
        .doc('Branch1')
        .collection('categories')
        .doc(widget.categoryTitle)
        .collection('subCategory')
        .orderBy('rank')
        .snapshots();
    stream2 = FirebaseFirestore.instance
        .collection('Branches')
        .doc('Branch1')
        .collection('categories')
        .doc(widget.categoryTitle)
        .collection('menu')
        .orderBy('rank')
        .snapshots();
    FirebaseFirestore.instance
        .collection('Branches')
        .doc('Branch1')
        .collection('categories')
        .doc(widget.categoryTitle)
        .get()
        .then((value) {
      setState(() {
        categoryOpen1 = value['categoryOpen'];
      });
    });

    _scrollController = new ScrollController();
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

  void addOrRemove(Cart cart, String menuID, String menuTitle, double halfPlate,
      double fullPlate, bool isVeg, int index) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  ListTile(
                    title: Text('Half Plate'),
                    subtitle: Text('₹${halfPlate.toStringAsFixed(0)}'),
                    trailing: AddOrRemoveOption(menuID, halfPlate, menuTitle,
                        isVeg, index, "Half Plate", true),
                  ),
                  ListTile(
                    title: Text('Full Plate'),
                    subtitle: Text('₹${fullPlate.toStringAsFixed(0)}'),
                    trailing: AddOrRemoveOption(menuID, fullPlate, menuTitle,
                        isVeg, index, "Full Plate", true),
                  ),
                ],
              );
            }),
          );
        });
  }

  void chooseOption(Cart cart, String menuID, String menuTitle,
      double halfPlate, double fullPlate, bool isVeg, int index) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (_) {
          String radioItem = halfPlate.toStringAsFixed(0);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  ListTile(
                    onTap: () {
                      setModalState(() {
                        radioItem = halfPlate.toStringAsFixed(0);
                      });
                    },
                    title: Text('Half Plate'),
                    subtitle: Text('₹${halfPlate.toStringAsFixed(0)}'),
                    trailing: Radio(
                        value: halfPlate.toStringAsFixed(0),
                        toggleable: true,
                        groupValue: radioItem,
                        onChanged: (val) {
                          setModalState(() {
                            radioItem = val;
                          });
                        }),
                  ),
                  ListTile(
                    onTap: () {
                      setModalState(() {
                        radioItem = fullPlate.toStringAsFixed(0);
                      });
                    },
                    title: Text('Full Plate'),
                    subtitle: Text('₹${fullPlate.toStringAsFixed(0)}'),
                    trailing: Radio(
                        value: fullPlate.toStringAsFixed(0),
                        toggleable: true,
                        groupValue: radioItem,
                        onChanged: (val) {
                          setModalState(() {
                            radioItem = val;
                          });
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.orange[900]),
                        ),
                        onPressed: () {
                          if (radioItem == halfPlate.toStringAsFixed(0)) {
                            setState(() {
                              cart.addItem(
                                menuID,
                                halfPlate,
                                menuTitle,
                                isVeg,
                                index,
                                "Half Plate",
                                true,
                              );
                            });
                          } else {
                            setState(() {
                              cart.addItem(
                                menuID,
                                fullPlate,
                                menuTitle,
                                isVeg,
                                index,
                                "Full Plate",
                                true,
                              );
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ADD ₹$radioItem',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          );
        });
  }

  void showDish(BuildContext ctx, bool isVeg, String imageUrl, String title,
      double price, String content) {
    Color showColor;
    if (isVeg) {
      showColor = Colors.green;
    } else {
      showColor = Colors.red[600];
    }
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
                    child: imageUrl != ""
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: MediaQuery.of(ctx).size.height * 0.3,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(),
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
                                Icon(
                                  Icons.adjust_outlined,
                                  color: showColor,
                                ),
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
      floatingActionButton: Padding(
        padding: cart.totalAmount == 0
            ? EdgeInsets.all(0)
            : EdgeInsets.only(bottom: 50),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
              backgroundColor: Colors.orange[900],
              icon: Icon(Icons.fastfood),
              label: Text(
                'MENU',
                style: TextStyle(
                  fontSize: 8.0.sp,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: StreamBuilder(
                              stream: stream,
                              builder: (ctx, subCategorySnapshot) {
                                if (subCategorySnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container();
                                }
                                final subCategoryData =
                                    subCategorySnapshot.data.docs;
                                return ListView.builder(
                                  itemBuilder: (ctx2, index) {
                                    final subCategoryTitle =
                                        subCategoryData[index]['title'];
                                    final subCategoryItems =
                                        subCategoryData[index]['items'];
                                    return ListTile(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        double items = 0;
                                        for (int i = 0; i < index; i++) {
                                          items = items +
                                              subCategoryData[i]['items'];
                                        }
                                        _scrollController.animateTo(
                                            (items * 146.0) + (index * 40.0),
                                            duration: Duration(seconds: 2),
                                            curve: Curves.ease);
                                      },
                                      title: Text(
                                        subCategoryTitle,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                        subCategoryItems.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: subCategoryData.length,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    });
              }),
        ),
      ),
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
      body: StreamBuilder(
          stream: stream2,
          builder: (ctx, menuSnapshot) {
            if (menuSnapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            final menuData = menuSnapshot.data.docs;
            return ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
                final subCategory = menuData[index]['subCategory'];
                final menuTitle = menuData[index]['title'];
                final menuId = menuData[index]['id'];
                final menuContent = menuData[index]['content'];
                final isVeg = menuData[index]['isVeg'];
                //final price = double.parse(menuData[index]['price']);

                final isAva = menuData[index]['isAvailable'];
                final url = menuData[index]['url'];
                final price = menuData[index]['price'];
                final priceList = price.split('_');
                final originalHalfPlate = double.parse(priceList[0]);
                final halfPlate = originalHalfPlate -
                    originalHalfPlate * double.parse(widget.offer) / 100;

                Color showColor;
                if (isVeg) {
                  showColor = Colors.green;
                } else {
                  showColor = Colors.red[600];
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    subCategory == ""
                        ? Container()
                        : Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              subCategory,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.adjust_outlined,
                                  color: showColor,
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Text(
                                    menuTitle,
                                    style: TextStyle(
                                      fontSize: 10.0.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 10.0.sp,
                                        color: Colors.black54,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '₹' +
                                              originalHalfPlate
                                                  .toStringAsFixed(0),
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '  ₹' +
                                              halfPlate.toStringAsFixed(0),
                                          style: TextStyle(
                                            fontSize: 10.0.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  menuContent,
                                  style: TextStyle(
                                    fontSize: 8.0.sp,
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
                                  GestureDetector(
                                    onTap: () {
                                      showDish(context, isVeg, url, menuTitle,
                                          halfPlate, menuContent);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      child: !isAva ||
                                              distance > 3 ||
                                              !widget.categoryOpen ||
                                              !restaurantOpen ||
                                              !categoryOpen1
                                          ? ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                  Colors.grey,
                                                  BlendMode.saturation),
                                              child: url != ""
                                                  ? CachedNetworkImage(
                                                      imageUrl: url,
                                                      height: 100,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(),
                                            )
                                          : url != ""
                                              ? CachedNetworkImage(
                                                  imageUrl: url,
                                                  height: 100,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        !isAva || distance > 3
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
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
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
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
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
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
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
                                            : !widget.categoryOpen ||
                                                    !restaurantOpen ||
                                                    !categoryOpen1
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
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
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
                                                                    "Closed",
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
                                                                            .orange[
                                                                        900]),
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
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .shopping_bag_outlined,
                                                                        color: Colors
                                                                            .orange[900],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          Text(
                                                                        "Add+",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.orange[900],
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
                                                                  EdgeInsets
                                                                      .all(4),
                                                              child: Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    if (cartName ==
                                                                        "Essentials") {
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
                                                                                "Your cart contains items from Fruits/Vegetables. Do you want to discard the selection and add items from Food Delivery?",
                                                                                style: TextStyle(color: Colors.grey),
                                                                              ),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    cart.clear();
                                                                                    if (priceList.length == 2) {
                                                                                      chooseOption(cart, menuId, menuTitle, halfPlate, double.parse(priceList[1]) - double.parse(priceList[1]) * double.parse(widget.offer) / 100, isVeg, index);
                                                                                    } else {
                                                                                      setState(() {
                                                                                        cart.addItem(menuId, halfPlate, menuTitle, isVeg, index, "Half Plate", false);
                                                                                      });
                                                                                    }
                                                                                    cartName = "Food";
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: Text(
                                                                                    "YES",
                                                                                    style: TextStyle(
                                                                                      color: Colors.deepOrange,
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
                                                                                      color: Colors.deepOrange,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          });
                                                                    } else {
                                                                      if (priceList
                                                                              .length ==
                                                                          2) {
                                                                        chooseOption(
                                                                            cart,
                                                                            menuId,
                                                                            menuTitle,
                                                                            halfPlate,
                                                                            double.parse(priceList[1]) -
                                                                                double.parse(priceList[1]) * double.parse(widget.offer) / 100,
                                                                            isVeg,
                                                                            index);
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          cart.addItem(
                                                                            menuId,
                                                                            halfPlate,
                                                                            menuTitle,
                                                                            isVeg,
                                                                            index,
                                                                            "Half Plate",
                                                                            false,
                                                                          );
                                                                        });
                                                                      }
                                                                      cartName =
                                                                          "Food";
                                                                    }
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
                                                                        .orange[
                                                                    900]),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              IconButton(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          8,
                                                                          4,
                                                                          0,
                                                                          4),
                                                                  constraints:
                                                                      BoxConstraints(),
                                                                  icon: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    size: 15,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    if (priceList
                                                                            .length ==
                                                                        2) {
                                                                      addOrRemove(
                                                                          cart,
                                                                          menuId,
                                                                          menuTitle,
                                                                          halfPlate,
                                                                          double.parse(priceList[1]) -
                                                                              double.parse(priceList[1]) * double.parse(widget.offer) / 100,
                                                                          isVeg,
                                                                          index);
                                                                    } else {
                                                                      setState(
                                                                        () {
                                                                          cart.removeItem(
                                                                              menuId,
                                                                              "Half Plate");
                                                                        },
                                                                      );
                                                                    }
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
                                                                            element.quantity)
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                          .orange[
                                                                      900],
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                  padding: EdgeInsets
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
                                                                            .orange[
                                                                        900],
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    if (priceList
                                                                            .length ==
                                                                        2) {
                                                                      addOrRemove(
                                                                          cart,
                                                                          menuId,
                                                                          menuTitle,
                                                                          halfPlate,
                                                                          double.parse(priceList[1]) -
                                                                              double.parse(priceList[1]) * double.parse(widget.offer) / 100,
                                                                          isVeg,
                                                                          index);
                                                                    } else {
                                                                      setState(
                                                                        () {
                                                                          cart.addItem(
                                                                            menuId,
                                                                            halfPlate,
                                                                            menuTitle,
                                                                            isVeg,
                                                                            index,
                                                                            "Half Plate",
                                                                            false,
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  }),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                      ],
                                    ),
                                  ),
                                  if (priceList.length == 2)
                                    Positioned(
                                      bottom: 0,
                                      child: Text(
                                        "Customizable",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
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
          }),
    );
  }
}

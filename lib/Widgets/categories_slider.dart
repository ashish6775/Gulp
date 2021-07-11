import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../slide_indicator.dart';
import 'add_slide_card2.dart';

class CategoriesSlider extends StatefulWidget {
  final Color color;

  CategoriesSlider(this.color);
  @override
  _CategoriesSliderState createState() => _CategoriesSliderState();
}

class _CategoriesSliderState extends State<CategoriesSlider> {
  CarouselController _controller = CarouselController();
  int _current = 0;
  int pagecount = 0;

  Stream<QuerySnapshot> stream;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance.collection('adds').get().then((value) {
      setState(() {
        pagecount = value.size;
      });
    });

    // Timer.periodic(Duration(seconds: 5), (timer) {
    //   if (!pageController.hasClients) {
    //     return;
    //   }
    //   if (pageController.page >= pagecount - 1) {
    //     pageController.animateToPage(0,
    //         duration: Duration(milliseconds: 1000),
    //         curve: Curves.fastLinearToSlowEaseIn);
    //   } else {
    //     pageController.nextPage(
    //         duration: Duration(milliseconds: 1000),
    //         curve: Curves.fastLinearToSlowEaseIn);
    //   }
    // });
    stream = FirebaseFirestore.instance
        .collection('adds')
        .orderBy('rank', descending: false)
        .snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LimitedBox(
          maxHeight: 200,
          child: StreamBuilder(
              stream: stream,
              builder: (context, addSnapshot) {
                if (addSnapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                final addItems = addSnapshot.data.docs;
                int pagecount = addItems.length;
                return CarouselSlider.builder(
                  carouselController: _controller,
                  options: CarouselOptions(
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                    height: MediaQuery.of(context).size.height * 0.4,
                    viewportFraction: 0.95,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  itemBuilder: (context, index, index2) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: addItems[index]['url'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: addItems.length,
                );
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(pagecount, buildIndicator),
        ),
      ],
    );
  }

  Widget buildIndicator(int index) {
    return Container(
      width: 12.0,
      height: 12.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : widget.color)
              .withOpacity(_current == index ? 0.9 : 0.4)),
    );
  }
}

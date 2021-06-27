import 'dart:async';

import 'package:flutter/material.dart';

import '../slide_indicator.dart';
import 'add_slide_card2.dart';

class CategoriesSlider extends StatefulWidget {
  final Color color;

  CategoriesSlider(this.color);
  @override
  _CategoriesSliderState createState() => _CategoriesSliderState();
}

class _CategoriesSliderState extends State<CategoriesSlider> {
  PageController pageController = PageController();
  int pagecount = 3;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 4), (timer) {
      if (!pageController.hasClients) {
        return;
      }
      if (pageController.page >= pagecount - 1) {
        pageController.animateToPage(0,
            duration: Duration(milliseconds: 1000),
            curve: Curves.fastLinearToSlowEaseIn);
      } else {
        pageController.nextPage(
            duration: Duration(milliseconds: 1000),
            curve: Curves.fastLinearToSlowEaseIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LimitedBox(
          maxHeight: 200,
          child: PageView(
            controller: pageController,
            children: [
              AddSlideCard2(
                slideImage: "assets/images/1.jpg",
              ),
              AddSlideCard2(
                slideImage: "assets/images/2.jpg",
              ),
              AddSlideCard2(
                slideImage: "assets/images/3.jpg",
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: SlideIndicator(
            pageController: pageController,
            selectedColor: widget.color,
          ),
        ),
      ],
    );
  }
}

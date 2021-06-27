import 'dart:async';

import 'package:flutter/material.dart';

import '../slide_indicator.dart';
import 'add_slide_card.dart';

class LoginSlider extends StatefulWidget {
  @override
  _LoginSliderState createState() => _LoginSliderState();
}

class _LoginSliderState extends State<LoginSlider> {
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
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: PageView(
            controller: pageController,
            children: [
              AddSlideCard(
                slideImage: "assets/images/image1.jpg",
              ),
              AddSlideCard(
                slideImage: "assets/images/image2.jpg",
              ),
              AddSlideCard(
                slideImage: "assets/images/image3.jpg",
              )
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(10.0),
          child: SlideIndicator(
            pageController: pageController,
            selectedColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

class SlideIndicator extends AnimatedWidget {
  final PageController pageController;
  final Color selectedColor;

  SlideIndicator({this.selectedColor, this.pageController}) : super(listenable: pageController);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, buildIndicator),
    );
  }

  Widget buildIndicator(int index) {
    double select = max(
      0.0,
      1.0 - ((pageController.page ?? pageController.initialPage) - index).abs(),
    );

    double decrease = 10 * select;

    return Container(
      width: 30,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 20 - decrease,
          height: 5,
          decoration: BoxDecoration(
              color: decrease == 10.0 ? selectedColor: selectedColor,
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

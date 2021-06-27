import 'package:flutter/material.dart';

class AddSlideCard extends StatelessWidget {
  final String slideImage;

  AddSlideCard({this.slideImage});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        slideImage,
        fit: BoxFit.cover,
      ),
    );
  }
}

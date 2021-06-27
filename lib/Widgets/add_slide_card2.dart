import 'package:flutter/material.dart';

class AddSlideCard2 extends StatelessWidget {
  final String slideImage;

  AddSlideCard2({this.slideImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,0,8,8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              slideImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

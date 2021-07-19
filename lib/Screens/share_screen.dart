import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:share/share.dart';

class ShareScreen extends StatefulWidget {
  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Refer and Earn"),
      ),
      body: ListView(
        children: [
          Image.asset("assets/images/refer_earn.png"),
          Column(
            children: [
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: "REFER AND EARN",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " ₹50",
                  style: TextStyle(
                    color: Colors.lightGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: " EACH",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ])),
              SizedBox(
                height: 20,
              ),
              Text(
                "YOUR REFERRAL CODE:",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              FDottedLine(
                color: Colors.lightGreen,
                strokeWidth: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _auth.currentUser.phoneNumber.substring(3),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 10),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Steps to claim referral:",
                  style: TextStyle(
                      color: Colors.lightGreen, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "1. Your referred friend puts your referral code while registering on the Gulp app.",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "2. Referred customer must not already be registered on Gulp.",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "3. You get ₹25 each time in your Gulp wallet on first and second order by your referee.",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "4. Your friend will get ₹50 instantly once they successfully sign up with your referral code",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.lightGreen),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.lightGreen),
                  ),
                  icon: Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Share.share(
                        'Hi, I am using *Gulp* for direct restaurants orders and farm fresh groceries.\nUse my referral code *${_auth.currentUser.phoneNumber.substring(3)}* to recieve ₹50 on the signup.\n*ORDER NOW*\nhttp://onelink.to/epnywn');
                  },
                  label: Text(
                    "REFER NOW",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

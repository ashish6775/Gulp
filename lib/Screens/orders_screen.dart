import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shop_app/Widgets/order_item.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Stream<QuerySnapshot> stream;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    stream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: _auth.currentUser.uid)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.call,
                    size: 20,
                    color: Colors.green,
                  ),
                  TextButton(
                    onPressed: () {
                      launch("tel:+918882644409");
                    },
                    child: Text('Contact Us',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Past Orders',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: StreamBuilder(
          stream: stream,
          builder: (context, orderSnapshot) {
            if (orderSnapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (orderSnapshot.data.docs.length != 0) {
              final orderData = orderSnapshot.data.docs;
              return ListView.builder(
                itemBuilder: (context, index) {
                  return OrderItem(orderData, index);
                },
                itemCount: orderData.length,
              );
            } else {
              return Center(
                child: Text(
                  'No past orders found!',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              );
            }
          },
        ));
  }
}

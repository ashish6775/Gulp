import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleOrderScreen extends StatelessWidget {
  final double amount;
  final DateTime dateTime;
  final DateTime deliveryBy;
  final String address;
  final double tip;
  final double packaging;
  final String payment;
  final String orderId;
  final String status;
  final List items;

  SingleOrderScreen(
      this.amount,
      this.dateTime,
      this.deliveryBy,
      this.address,
      this.tip,
      this.packaging,
      this.payment,
      this.orderId,
      this.status,
      this.items);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child:
                      Text('Contact Us', style: TextStyle(color: Colors.black)),
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
          'ORDER #${orderId.toString().substring(0, 6).toUpperCase()}',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            status == 'Waiting for Approval'
                                ? Icon(
                                    Icons.timer,
                                    color: Colors.red,
                                  )
                                : status == 'Preparing'
                                    ? Image.asset(
                                        "assets/images/cooking.png",
                                        color: Colors.red,
                                        width: 24,
                                        height: 24,
                                      )
                                    : status == 'Out for Delivery'
                                        ? Icon(
                                            Icons.delivery_dining,
                                            color: Colors.lightGreen,
                                          )
                                        : status == 'Cancelled'
                                            ? Icon(
                                                Icons.cancel_outlined,
                                                color: Colors.red,
                                              )
                                            : status == 'Order Placed'
                                                ? Image.asset(
                                                    "assets/images/shopping.png",
                                                    color: Colors.red,
                                                    width: 24,
                                                    height: 24,
                                                  )
                                                : Icon(
                                                    Icons.done_all,
                                                    color: Colors.green,
                                                  ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              status,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Text(
                              'Items Count',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Spacer(),
                            Text(
                              '${items.length}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              'Items Total',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Spacer(),
                            Text(
                              '₹${amount - packaging - tip}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              'Eco-friendly Packaging Fee',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Spacer(),
                            Text(
                              '₹$packaging',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              'Tip to Delivery Person',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Spacer(),
                            Text(
                              '₹$tip',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              'Total Bill',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              '₹$amount',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Divider(
                  thickness: 3,
                  color: Colors.grey[700],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Delivery Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(
                  'Address: ' + address,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(
                  'Ordered on: ${DateFormat('MMM dd, hh:mm aa').format(dateTime)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(
                  'Delivery by: ${DateFormat('MMM dd, hh:mm aa').format(deliveryBy)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Divider(
                  thickness: 3,
                  color: Colors.grey[700],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Items Ordered:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: items
                      .map(
                        (prod) => Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.navigate_next,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                  Text(
                                    '${prod.toString().split("_")[0]} x ${prod.toString().split("_")[1]}',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '₹${(double.parse(prod.toString().split("_")[2]) * double.parse(prod.toString().split("_")[1]))}',
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Divider(
                  thickness: 3,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

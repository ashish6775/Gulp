import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/Screens/single_order_screen.dart';

class OrderItem extends StatefulWidget {
  final dynamic orderData;
  final int index;

  OrderItem(this.orderData, this.index);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var difference = 0;
  Timer _timer;
  final oneSec = const Duration(seconds: 1);

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(oneSec, (timer) {
      if (difference > 60) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          difference--;
        });
      }
    });
  }

  void singleOrderScreen(BuildContext ctx, amount, dateTime, deliveryBy,
      address, tip, packaging, payment, orderId, status, items) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return SingleOrderScreen(amount, dateTime, deliveryBy, address, tip,
              packaging, payment, orderId, status, items);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double amount = widget.orderData[widget.index]['amount'];
    final DateTime dateTime =
        widget.orderData[widget.index]['dateTime'].toDate();
    final DateTime deliveryBy =
        widget.orderData[widget.index]['deliveryBy'].toDate();
    final String address = widget.orderData[widget.index]['address'];
    final double tip = widget.orderData[widget.index]['tip'];
    final double packaging = widget.orderData[widget.index]['packaging'];
    final String payment = widget.orderData[widget.index]['payment'];
    final String orderId = widget.orderData[widget.index]['orderId'];
    final String status = widget.orderData[widget.index]['status'];
    final List items = List.from(widget.orderData[widget.index]['items']);

    difference = DateTime.now().difference(dateTime).inSeconds;

    return Column(
      children: [
        Stack(
          children: [
            Card(
              elevation: 2,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ORDER #${orderId.toString().substring(0, 6).toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(status),
                            ],
                          ),
                          Spacer(),
                          Text(
                            items.length > 1
                                ? '₹$amount | ${items.length} Items'
                                : '₹$amount | ${items.length} Item',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          'Ordered on: ${DateFormat('MMM dd, hh:mm aa').format(dateTime)}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Text(
                        'Delivery by: ${DateFormat('MMM dd, hh:mm aa').format(deliveryBy)}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.all(4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      singleOrderScreen(
                          context,
                          amount,
                          dateTime,
                          deliveryBy,
                          address,
                          tip,
                          packaging,
                          payment,
                          orderId,
                          status,
                          items);
                    },
                    splashColor: Colors.green[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/foundation.dart';

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String address;

  OrderItem({this.id, this.amount, this.products, this.dateTime, this.address});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(
      List<CartItem> cartProducts, double total, String id, String address) {
    _orders.insert(
      0,
      OrderItem(
        id: id,
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
        address: address,
      ),
    );
    notifyListeners();
  }
}

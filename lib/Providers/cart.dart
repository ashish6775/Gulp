import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  int quantity;
  final double price;
  final bool isveg;
  final int index;
  final String pack;
  final bool isCustom;

  CartItem({
    this.id,
    this.title,
    this.quantity,
    this.price,
    this.isveg,
    this.index,
    this.pack,
    this.isCustom,
  });
}

class Cart with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items {
    return [..._items];
  }

  void addItem(String menuID, double price, String title, bool isveg, int index,
      String pack, bool isCustom) {
    if (_items.any((element) => element.id == menuID && element.pack == pack)) {
      _items.forEach((element) {
        if (element.id == menuID && element.pack == pack) {
          element.quantity = element.quantity + 1;
        }
      });
    } else {
      _items.add(CartItem(
        id: menuID,
        title: title,
        price: price,
        quantity: 1,
        isveg: isveg,
        index: index,
        pack: pack,
        isCustom: isCustom,
      ));
    }

    notifyListeners();
  }

  void removeItem(String menuID, String pack) {
    _items.forEach((element) {
      if (element.id == menuID &&
          element.quantity > 0 &&
          element.pack == pack) {
        element.quantity = element.quantity - 1;
      }
    });
    _items.removeWhere((element) => element.quantity == 0);

    notifyListeners();
  }

  int get itemCount {
    var count = 0;
    _items.forEach((cartItem) {
      count += cartItem.quantity;
    });
    return count;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void clear() {
    _items = [];
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/cart.dart';

class CartItem extends StatefulWidget {
  final String id;
  final double price;
  final int quantity;
  final String title;
  final bool isveg;
  final int index;
  final String pack;
  final bool isCustom;

  final MaterialColor colour;

  CartItem(this.id, this.price, this.quantity, this.title, this.isveg,
      this.index, this.pack, this.isCustom, this.colour);

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  bool categoryOpen = true;
  bool isAva = true;
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: widget.isveg
                ? Icon(
                    Icons.adjust_outlined,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.adjust_outlined,
                    color: Colors.red[600],
                  ),
            title: Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            subtitle: widget.isCustom && widget.pack == "Half Plate"
                ? Text(
                    'Price: ₹${(widget.price * widget.quantity).toStringAsFixed(0)} (Half Plate)',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  )
                : widget.isCustom && widget.pack != "Half Plate"
                    ? Text(
                        'Price: ₹${(widget.price * widget.quantity).toStringAsFixed(0)} (Full Plate)',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )
                    : Text(
                        'Price: ₹${(widget.price * widget.quantity).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
            trailing: Container(
              height: 35,
              width: MediaQuery.of(context).size.width * 0.20,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: widget.colour),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                        constraints: BoxConstraints(),
                        icon: Icon(
                          Icons.remove,
                          size: 15,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              cart.removeItem(
                                widget.id,
                                widget.pack,
                              );
                            },
                          );
                        }),
                    Text(
                      widget.quantity.toString(),
                      style: TextStyle(
                        color: widget.colour,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                        constraints: BoxConstraints(),
                        icon: Icon(
                          Icons.add,
                          size: 15,
                          color: widget.colour,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              cart.addItem(
                                widget.id,
                                widget.price,
                                widget.title,
                                widget.isveg,
                                widget.index,
                                widget.pack,
                                widget.isCustom,
                              );
                            },
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

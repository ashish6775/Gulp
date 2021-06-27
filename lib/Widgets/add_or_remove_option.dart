import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/cart.dart';

class AddOrRemoveOption extends StatefulWidget {
  final String id;
  final double price;

  final String title;
  final bool isveg;
  final int index;
  final String pack;
  final bool isCustom;

  AddOrRemoveOption(this.id, this.price, this.title, this.isveg, this.index,
      this.pack, this.isCustom);
  @override
  _AddOrRemoveOptionState createState() => _AddOrRemoveOptionState();
}

class _AddOrRemoveOptionState extends State<AddOrRemoveOption> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return !cart.items.any(
            (element) => element.id == widget.id && element.pack == widget.pack)
        ? Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.purple,
                          ),
                        ),
                        Container(
                          child: Text(
                            "Add+",
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                        setState(() {
                          cart.addItem(
                            widget.id,
                            widget.price,
                            widget.title,
                            widget.isveg,
                            widget.index,
                            widget.pack,
                            widget.isCustom,
                          );
                        });
                      },
                      splashColor: Colors.white54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          )
        : Container(
            height: 40,
            width: MediaQuery.of(context).size.width * 0.25,
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.purple),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      padding: EdgeInsets.fromLTRB(8, 4, 0, 4),
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
                    cart.items
                        .firstWhere((element) =>
                            element.id == widget.id &&
                            element.pack == widget.pack)
                        .quantity
                        .toString(),
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                      padding: EdgeInsets.fromLTRB(0, 4, 8, 4),
                      constraints: BoxConstraints(),
                      icon: Icon(
                        Icons.add,
                        size: 15,
                        color: Colors.purple,
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
          );
  }
}

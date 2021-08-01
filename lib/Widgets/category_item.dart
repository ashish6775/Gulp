import 'package:flutter/material.dart';
import 'package:shop_app/Screens/menu_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String url;
  final bool categoryOpen;
  final String offer;
  final bool restOpen;
  final String type;
  final String from;

  CategoryItem(this.title, this.url, this.categoryOpen, this.offer, this.type,
      this.from, this.restOpen);

  void selectCategories(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return MenuScreen(title, categoryOpen, offer, type);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                child: restOpen
                    ? categoryOpen
                        ? CachedNetworkImage(
                            imageUrl: url,
                            height: MediaQuery.of(context).size.width * 0.8,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.grey,
                              BlendMode.saturation,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              height: MediaQuery.of(context).size.width * 0.8,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                    : ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          height: MediaQuery.of(context).size.width * 0.8,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              if (title != "" && offer != "0")
                Positioned(
                    top: -7,
                    left: -11,
                    child: Icon(
                      Icons.bookmark_sharp,
                      size: 50,
                      color: Colors.deepOrange,
                    )),
              if (title != "" && offer != "0")
                Positioned(
                  top: 1,
                  left: 4,
                  child: Text(
                    offer + '%\nOFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                    if (from != "")
                      Text(
                        from,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (title == "") {
                    return;
                  } else {
                    selectCategories(context);
                  }
                },
                splashColor: Colors.white54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

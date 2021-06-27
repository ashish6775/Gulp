import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Screens/orders_screen.dart';
import 'package:shop_app/Screens/privacy_policy.dart';
import 'package:shop_app/Screens/delivery_policy.dart';
import 'package:sizer/sizer.dart';

import '../main.dart';
import 'address_screen.dart';

class AccountScreen extends StatelessWidget {
  void ordersScreen(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return OrdersScreen();
        },
      ),
    );
  }

  void addressScreen(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return AddressScreen();
        },
      ),
    );
  }

  void privacyPolicy(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return PrivacyPolicy();
        },
      ),
    );
  }

  void deliveryPolicy(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return DeliveryPolicy();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    Cart cart = Provider.of<Cart>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your Account',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.person_outline_sharp,
              color: Colors.purple,
            ),
            title: Text(
              _auth.currentUser.phoneNumber,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            // trailing: TextButton(
            //   onPressed: () {},
            //   child: Text(
            //     'EDIT',
            //     style: TextStyle(
            //       color: Colors.purple,
            //     ),
            //   ),
            // ),
          ),
          Divider(),
          ListTile(
            onTap: () {
              addressScreen(context);
            },
            leading: Icon(
              Icons.home_outlined,
              color: Colors.purple,
            ),
            title: Text(
              'Manage Address',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Add Multiple Address',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              ordersScreen(context);
            },
            leading: Icon(
              Icons.history,
              color: Colors.purple,
            ),
            title: Text(
              'Past Orders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Track your Past Orders',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
          ListTile(
            onTap: () async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();
              showAboutDialog(
                context: context,
                applicationName: 'Gulp',
                applicationVersion: 'v' + packageInfo.version,
                applicationIcon: Image.asset(
                  "assets/images/logo.png",
                  height: 40,
                  width: 40,
                ),
                children: [
                  Row(
                    children: [
                      Text('Created with '),
                      Icon(
                        Icons.favorite,
                        color: Colors.pink,
                      ),
                      Text(' in India'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No animal was harmed in the process of making this app. In fact, quite a few pets were fed and petted :)',
                    style: TextStyle(
                      fontSize: 8.0.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Contact No.: +91 8373907868',
                    style: TextStyle(
                      fontSize: 8.0.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Email: dosaadda@gmail.com',
                    style: TextStyle(
                      fontSize: 8.0.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          privacyPolicy(context);
                        },
                        child: Text("Privacy Policy",
                            style: TextStyle(
                              color: Colors.purple,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dashed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          deliveryPolicy(context);
                        },
                        child: Text("Delivery Policy",
                            style: TextStyle(
                              color: Colors.purple,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dashed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                ],
              );
            },
            leading: Icon(
              Icons.info_outline,
              color: Colors.purple,
            ),
            title: Text(
              'About Us',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Contact us/Terms & Links',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text('Do you want to logout?'),
                          contentPadding: EdgeInsets.fromLTRB(24, 5, 24, 24),
                          content: Text(
                            'We will miss you :(',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                cart.clear();

                                //selectedLocation = "";
                                coordinates = LatLng(0, 0);
                                // FirebaseAuth.instance.signOut();
                                // GoogleSignIn googleSignIn = GoogleSignIn();
                                // if (googleSignIn != null) {
                                //   googleSignIn.signOut();
                                // } else if (FacebookAuth.instance != null) {
                                //   FacebookAuth.instance.logOut();
                                // }
                                // FacebookAuth.instance.logOut();
                              },
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('No'),
                            )
                          ],
                        );
                      });
                },
                child: Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}

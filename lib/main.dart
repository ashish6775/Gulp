import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Providers/cart.dart';
import 'package:shop_app/Providers/orders.dart';
import 'package:shop_app/Screens/berfore_signup.dart';
import 'package:shop_app/Screens/navigation_screen.dart';
import 'package:shop_app/Widgets/login_options.dart';
import 'package:shop_app/Widgets/login_slider.dart';
import 'package:sizer/sizer_util.dart';

import 'Screens/splash_screen.dart';

double distance = 0;

//To show on Navigation bar
//String selectedLocation = "";

//Essentials or Food
String cartName = "";

//To show on Navigation bar
String selectedAddress = "";
LatLng coordinates = LatLng(0, 0);

bool restaurantOpen = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //VideoPlayerController _controller;
  //bool done = true;

  @override
  void initState() {
    super.initState();

    // Pointing the video controller to our local asset.
    // _controller = VideoPlayerController.asset('assets/images/splash.mp4')
    //   ..initialize().then((_) {
    //     // Once the video has been loaded we play the video and set looping to true.
    //     _controller.play();
    //     _controller.setLooping(false);
    //     _controller.setVolume(0.0);
    //     _controller.play();
    //     // Ensure the first frame is shown after the video is initialized.
    //     setState(() {});
    //   });
    // _controller.addListener(checkVideo);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizerUtil().init(constraints, orientation);
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (ctx) => Cart(),
                ),
                ChangeNotifierProvider(
                  create: (ctx) => Orders(),
                ),
              ],
              child: MaterialApp(
                theme: ThemeData(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: Colors.orange,
                  ),
                  primarySwatch: Colors.orange,
                  accentColor: Colors.deepOrange,
                ),
                debugShowCheckedModeBanner: false,
                title: 'Shop App',
                home: StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (ctx, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SplashScreen();
                    }
                    if (userSnapshot.hasData) {
                      if (FirebaseAuth.instance.currentUser.displayName ==
                              null ||
                          FirebaseAuth.instance.currentUser.displayName == "") {
                        return BeforeSignup();
                      }

                      return NavigationScreen();
                    }
                    return LoginPage();
                    // else {
                    //   return SizedBox.expand(
                    //     child: FittedBox(
                    //       // If your background video doesn't look right, try changing the BoxFit property.
                    //       // BoxFit.fill created the look I was going for.
                    //       fit: BoxFit.fill,
                    //       child: SizedBox(
                    //         width: _controller.value.size?.width ?? 0,
                    //         height: _controller.value.size?.height ?? 0,
                    //         child: VideoPlayer(_controller),
                    //       ),
                    //     ),
                    //   );
                    // }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // void checkVideo() {
  //   // Implement your calls inside these conditions' bodies :
  //   if (_controller.value.position ==
  //       Duration(seconds: 0, minutes: 0, hours: 0)) {
  //     print('video Started');
  //     setState(() {
  //       done = false;
  //     });
  //   }

  //   if (_controller.value.position == _controller.value.duration) {
  //     print('video Ended');
  //     setState(() {
  //       done = true;
  //     });
  //   }
  // }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LoginSlider(),
              LoginOptions(),
            ],
          ),
        ),
      ),
    );
  }
}

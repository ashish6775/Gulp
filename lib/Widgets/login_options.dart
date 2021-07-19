import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shop_app/Screens/navigation_screen.dart';
import 'package:shop_app/Screens/privacy_policy.dart';
import 'package:shop_app/Screens/delivery_policy.dart';
import 'package:shop_app/Widgets/login_otp.dart';

class LoginOptions extends StatefulWidget {
  @override
  _LoginOptionsState createState() => _LoginOptionsState();
}

class _LoginOptionsState extends State<LoginOptions> {
  //TextEditingController _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  var _userNumber = "";

  StreamSubscription<DataConnectionStatus> listener;

  checkInternet(ctx, number) async {
    // Simple check to see if we have internet
    print("The statement 'this machine is connected to the Internet' is: ");
    print(await DataConnectionChecker().hasConnection);
    // returns a bool

    // We can also get an enum value instead of a bool
    print("Current status: ${await DataConnectionChecker().connectionStatus}");
    // prints either DataConnectionStatus.connected
    // or DataConnectionStatus.disconnected

    // This returns the last results from the last call
    // to either hasConnection or connectionStatus
    print("Last results: ${DataConnectionChecker().lastTryResults}");

    // actively listen for status updates
    // this will cause DataConnectionChecker to check periodically
    // with the interval specified in DataConnectionChecker().checkInterval
    // until listener.cancel() is called
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          loginWithOtp(ctx, number);
          break;
        case DataConnectionStatus.disconnected:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please check your Internet Connection'),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    });

    // close listener after 30 seconds, so the program doesn't run forever
    await Future.delayed(Duration(seconds: 30));
    await listener.cancel();
  }

  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    try {
      if (isValid) {
        setState(() {
          _isLoading = true;
        });
        _formKey.currentState.save();
        UserCredential authResult;
        if (_isLogin) {
          setState(() {
            _isLoading = true;
          });
          Navigator.of(context).pop();
          authResult = await _auth.signInWithEmailAndPassword(
            email: _userEmail,
            password: _userPassword,
          );
        } else {
          setState(() {
            _isLoading = true;
          });
          Navigator.of(context).pop();
          authResult = await _auth.createUserWithEmailAndPassword(
            email: _userEmail,
            password: _userPassword,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(authResult.user.uid)
              .set({
            'username': _userName,
            'email': _userEmail,
            'address': '',
          });
        }
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';
      if (err.message != null) {
        message = err.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<User> signInWithFacebook() async {
  //   try {
  //     await FacebookAuth.instance.logOut();
  //     final AccessToken result = await FacebookAuth.instance.login();

  //     setState(() {
  //       _isLoading = true;
  //     });

  //     final AuthCredential facebookAuthCredential =
  //         FacebookAuthProvider.credential(result.token);

  //     var user = (await FirebaseAuth.instance
  //             .signInWithCredential(facebookAuthCredential))
  //         .user;
  //     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  //       'username': user.displayName,
  //       'email': user.email,
  //       'address': '',
  //     });
  //     return user;
  //   } on PlatformException catch (err) {
  //     var message = 'An error occurred, please check your credentials!';
  //     if (err.message != null) {
  //       message = err.message;
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(message),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   } catch (err) {
  //     print(err);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // Future<User> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  //     setState(() {
  //       _isLoading = true;
  //     });

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     var user =
  //         (await FirebaseAuth.instance.signInWithCredential(credential)).user;
  //     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  //       'username': user.displayName,
  //       'email': user.email,
  //       'address': '',
  //     });
  //     return user;
  //   } on PlatformException catch (err) {
  //     var message = 'An error occurred, please check your credentials!';
  //     if (err.message != null) {
  //       message = err.message;
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(message),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   } catch (err) {
  //     print(err);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  void loginWithOtp(BuildContext ctx, String number) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return LoginOtp(ctx, number);
        },
      ),
    );
  }

  void loginWithEmail(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: ctx,
      builder: (context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Colors.purple,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('email'),
                            validator: (value) {
                              if (value.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email address',
                            ),
                            onSaved: (value) {
                              _userEmail = value.trim();
                            },
                          ),
                        ),
                      ],
                    ),
                    if (!_isLogin)
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.purple,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              key: ValueKey('username'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Username cannot be empty';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Username',
                              ),
                              onSaved: (value) {
                                _userName = value.trim();
                              },
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outlined,
                          color: Colors.purple,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('password'),
                            validator: (value) {
                              if (value.isEmpty || value.length < 7) {
                                return 'Password must be atleast 7 characters long.';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                            onSaved: (value) {
                              _userPassword = value.trim();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (_isLoading) CircularProgressIndicator(),
                    if (!_isLoading)
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.purple),
                        ),
                        onPressed: _trySubmit,
                        child: Text(
                          _isLogin ? 'Login' : 'Signup',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (!_isLoading)
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Create new account?'
                              : 'I already have an account!',
                          style: TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void login(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return NavigationScreen();
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOGIN',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      'Enter your Mobile number to proceed',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Form(
                      key: _formKey1,
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500),
                        onSaved: (value) {
                          _userNumber = value.trim();
                        },
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefix: Text(
                            "+91 ",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500),
                          ),
                          icon: Icon(
                            Icons.call,
                            color: Colors.green,
                          ),
                          labelText: '10 digit Mobile number',
                          labelStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                              side: BorderSide(color: Colors.orange),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.orange),
                        ),
                        onPressed: () {
                          _formKey1.currentState.save();
                          if (_userNumber.length == 10) {
                            checkInternet(context, _userNumber);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Please enter a valid Phone number'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Text(
                                  "CONTINUE",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Container(
              //       height: 0.5,
              //       width: 160,
              //       color: Colors.white,
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.only(top: 0),
              //       child: Text(
              //         "OR",
              //         style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 10,
              //             fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //     Container(
              //       height: 0.5,
              //       width: 160,
              //       color: Colors.white,
              //     ),
              //   ],
              // ),
              // Column(
              //   children: [
              //     Container(
              //       width: MediaQuery.of(context).size.width * 0.90,
              //       child: TextButton(
              //         style: ButtonStyle(
              //           backgroundColor:
              //               MaterialStateProperty.all<Color>(Colors.white),
              //         ),
              //         //padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),

              //         onPressed: () {
              //           loginWithEmail(context);
              //         },
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           children: [
              //             Container(
              //               width: MediaQuery.of(context).size.width * 0,
              //               padding: const EdgeInsets.only(left: 15.0),
              //               child: Icon(
              //                 Icons.email_outlined,
              //                 color: Colors.black,
              //               ),
              //             ),
              //             Container(
              //                 width: MediaQuery.of(context).size.width * 0.80,
              //                 child: Align(
              //                     alignment: Alignment.center,
              //                     child: Text(
              //                       "Continue with Email",
              //                       style: TextStyle(color: Colors.black),
              //                     )))
              //           ],
              //         ),
              //       ),
              //     ),
              //     SizedBox(
              //       height: 5,
              //     ),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Container(
              //           padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
              //           width: MediaQuery.of(context).size.width * 0.45,
              //           child: TextButton(
              //               style: ButtonStyle(
              //                 backgroundColor:
              //                     MaterialStateProperty.all<Color>(Colors.white),
              //               ),
              //               //padding:EdgeInsets.symmetric(vertical: 10, horizontal: 0),

              //               onPressed: signInWithFacebook,
              //               child: Row(
              //                 children: [
              //                   Container(
              //                     padding: const EdgeInsets.only(
              //                         left: 15.0, right: 15.0),
              //                     child: SvgPicture.asset(
              //                       "assets/icons/facebook.svg",
              //                       height: 20,
              //                       width: 20,
              //                       color: Colors.blue[800],
              //                     ),
              //                   ),
              //                   Container(
              //                     child: Text(
              //                       "Facebook",
              //                       style: TextStyle(color: Colors.black),
              //                     ),
              //                   ),
              //                 ],
              //               )),
              //         ),
              //         Container(
              //           padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              //           width: MediaQuery.of(context).size.width * 0.45,
              //           child: TextButton(
              //             style: ButtonStyle(
              //               backgroundColor:
              //                   MaterialStateProperty.all<Color>(Colors.white),
              //             ),
              //             //padding:EdgeInsets.symmetric(vertical: 10, horizontal: 0),

              //             onPressed: signInWithGoogle,
              //             child: Row(
              //               children: [
              //                 Container(
              //                   padding:
              //                       const EdgeInsets.only(left: 15.0, right: 15.0),
              //                   child: SvgPicture.asset(
              //                     "assets/icons/google.svg",
              //                     height: 20,
              //                     width: 20,
              //                   ),
              //                 ),
              //                 Container(
              //                     child: Text(
              //                   "Google",
              //                   style: TextStyle(color: Colors.black),
              //                 ))
              //               ],
              //             ),
              //           ),
              //         )
              //       ],
              //     ),
              //   ],
              // ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "By continuing, you agree to our",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            privacyPolicy(context);
                          },
                          child: Text("TnC/Privacy Policy",
                              style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dashed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        InkWell(
                          onTap: () {
                            deliveryPolicy(context);
                          },
                          child: Text(
                            "Delivery Policy",
                            style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dashed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

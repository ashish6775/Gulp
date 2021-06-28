import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class LoginOtp extends StatefulWidget {
  final String phone;
  final BuildContext ctx;

  LoginOtp(this.ctx, this.phone);

  @override
  _LoginOtpState createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  final _auth = FirebaseAuth.instance;
  bool error = false;
  bool loading = false;
  String _verificationCode;
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: Colors.orange[700],
    borderRadius: BorderRadius.circular(10.0),
  );
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter Verification Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('We have sent a verification code to'),
            Text('+91-${widget.phone}'),
            if (error)
              Text(
                'OTP entered was wrong!',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            SizedBox(
              height: 10,
            ),
            Card(
              elevation: 4,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: "Enter OTP here",
                  ),
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(6),
                  ],
                  keyboardType: TextInputType.number,
                  controller: _codeController,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: loading
                  ? Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : TextButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        await _auth
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: _verificationCode,
                                smsCode: _codeController.text.trim()))
                            .onError((error1, stackTrace) {
                          setState(() {
                            loading = false;
                            error = true;
                          });
                          return error1;
                        });

                        try {
                          Navigator.of(context).pop();

                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(_auth.currentUser.uid)
                              .set({
                            'phone': widget.phone,
                            'name': _auth.currentUser.displayName == null
                                ? "Stranger"
                                : _auth.currentUser.displayName,
                          }, SetOptions(merge: true));
                          if (_auth.currentUser.displayName == null) {
                            _auth.currentUser.updateDisplayName("Stranger");
                          }
                        } on PlatformException catch (err) {
                          var message =
                              'An error occurred, please check your credentials!';
                          if (err.message != null) {
                            message = err.message;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } catch (err) {
                          setState(() {
                            error = true;
                            loading = false;
                          });
                          print(err);
                        }
                      },
                      child: Text(
                        "   CONFIRM OTP   ",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(color: Colors.orange),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.orange),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  _verifyPhone() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${widget.phone}',
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        try {
          Navigator.of(context).pop();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser.uid)
              .set({
            'phone': widget.phone,
            'name': _auth.currentUser.displayName == null
                ? "Stranger"
                : _auth.currentUser.displayName,
          }, SetOptions(merge: true));
          if (_auth.currentUser.displayName == null) {
            _auth.currentUser.updateDisplayName("Stranger");
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
        } catch (err) {
          print(err);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          error = true;
          loading = false;
        });
        if (e.code == 'invalid-phone-number') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The provided phone number is not valid.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      codeSent: (String verificationID, int resendToken) async {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      codeAutoRetrievalTimeout: (verificationID) {},
    );
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
}

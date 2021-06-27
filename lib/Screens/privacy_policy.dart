import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const WebView(
        initialUrl:
            "https://sites.google.com/view/dosaadda-gulp/privacy-policy",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

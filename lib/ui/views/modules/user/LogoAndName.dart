import 'package:flutter/material.dart';

class LogoAndName extends StatelessWidget {
  bool _keyboardVisible = false;

  LogoAndName({keyboardVisible = false}) {
    this._keyboardVisible = keyboardVisible;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: this._keyboardVisible
            ? EdgeInsets.only(top: 30.0, bottom: 30.0)
            : EdgeInsets.only(top: 150.0, bottom: 50.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                  child: Image(
                image: AssetImage("assets/images/logo-no-bg.png"),
                height: 150,
              )),
            ),
          ],
        ));
  }
}

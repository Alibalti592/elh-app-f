import 'package:flutter/material.dart';
import 'package:elh/ui/views/modules/user/loginModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

//eventuellemnt ajouter un btn restart :https://mobikul.com/reload-restart-app-in-flutter/
class NoConnexion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return ViewModelBuilder<LoginModel>.reactive(
        builder: (context, model, child) => Container(
            height: MediaQuery.of(context).size.height,
            child: Scaffold(
                body: Container(
              height: MediaQuery.of(context).size.height,
              decoration: _backgroundImageGradient(
                  Colors.white, Colors.white, Colors.white, 0.1),
              child: AutofillGroup(
                child: ListView(
                  children: <Widget>[
                    _LogoAndNameNo(model, keyboardVisible: _keyboardVisible),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1, horizontal: 25),
                      child: Text(
                        "Aucune connexion possible, veuillez vérifier votre connexion internet et redémarrer l'application.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ))),
        viewModelBuilder: () => LoginModel());
  }

  _backgroundImageGradient(color1, color2, color3, blend) {
    return BoxDecoration(
      gradient: new LinearGradient(
          colors: [color3, color2, color1],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 1.0),
          stops: [0.0, 0.5, 1.0],
          tileMode: TileMode.clamp),
      image: DecorationImage(
        colorFilter: new ColorFilter.mode(
            Colors.black.withOpacity(blend), BlendMode.dstATop),
        image: AssetImage('assets/images/bg_home.jpg'),
        fit: BoxFit.cover,
      ),
    );
  }
}

class _LogoAndNameNo extends StatelessWidget {
  late LoginModel model;
  bool _keyboardVisible = false;
  _LogoAndNameNo(model, {keyboardVisible = false}) {
    this.model = model;
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
                      height: 55)),
            ),
            Container(
              padding: EdgeInsets.only(top: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[],
              ),
            ),
          ],
        ));
  }
}

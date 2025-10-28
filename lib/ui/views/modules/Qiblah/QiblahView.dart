import 'dart:async';
import 'dart:math' show pi;
import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Qiblah/LocationErrorWidgget.dart';
import 'package:elh/ui/views/modules/Qiblah/QiblahController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stacked/stacked.dart';

class QiblahView extends StatefulWidget {
  const QiblahView({Key? key}) : super(key: key);

  @override
  State<QiblahView> createState() => _QiblahViewState();
}

class _QiblahViewState extends State<QiblahView> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();
  get stream => _locationStreamController.stream;

  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //only portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ViewModelBuilder<QiblahController>.reactive(
        viewModelBuilder: () => QiblahController(),
        builder: (context, controller, child) => Scaffold(
              appBar: AppBar(
                leadingWidth: 60,
                toolbarHeight: 60,
                titleSpacing: 0,
                elevation: 0,
                iconTheme: new IconThemeData(color: Colors.white),
                backgroundColor:
                    Colors.transparent, // 🔑 transparent pour voir le gradient
                title: Text("Qiblah", style: headerTextWhite),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(220, 198, 169, 1.0), // light beige
                        Color.fromRGBO(143, 151, 121, 1.0), // olive green
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              body: Container(
                color: bgLight,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: stream,
                  builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return BBloader();
                    }
                    if (snapshot.data!.enabled == true) {
                      switch (snapshot.data!.status) {
                        case LocationPermission.always:
                        case LocationPermission.whileInUse:
                          return QiblahCompassWidget();
                        case LocationPermission.denied:
                          return LocationErrorWidget(
                            error:
                                "Tu n'as pas activé la localisation pour cette application !",
                            callback: _checkLocationStatus,
                          );
                        case LocationPermission.deniedForever:
                          return LocationErrorWidget(
                            error:
                                "Tu as refusé la localisation pour cette application !",
                            callback: _checkLocationStatus,
                          );
                        // case GeolocationStatus.unknown:
                        //   return LocationErrorWidget(
                        //     error: "Unknown Location service error",
                        //     callback: _checkLocationStatus,
                        //   );
                        default:
                          return Container();
                      }
                    } else {
                      return LocationErrorWidget(
                        error:
                            "Pour activer la fonctionnalité de la Qiblah, autorisez la géolocalisation dans les paramètres de votre téléphone",
                        callback: _checkLocationStatus,
                      );
                    }
                  },
                ),
              ),
            ));
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
  }
}

class QiblahCompassWidget extends StatelessWidget {
  QiblahCompassWidget({Key? key}) : super(key: key);
  ValueNotifier<int> refreshInt = ValueNotifier<int>(1);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        builder: (BuildContext context, int pageIndexColor, Widget? child) {
          return StreamBuilder(
            stream: FlutterQiblah.qiblahStream,
            builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    UIHelper.verticalSpace(50),
                    BBloader(),
                    UIHelper.verticalSpace(50),
                    // GestureDetector(
                    //   onTap: () {
                    //     refreshInt.value = refreshInt.value + 1;
                    //     Navigator.popAndPushNamed(context,'/');
                    //   },
                    //   child:Text('Relancer', style: linkStyleBold)
                    // )
                  ],
                ); //load infini ici si pas de rebuild
              }
              if (snapshot.data == null) {
                return Text("Merci d'activer la localisation");
              } else {
                final qiblahDirection = snapshot.data!;
                var angle = ((qiblahDirection.qiblah) * (pi / 180) * -1);
                if (angle < 5 && angle > -5) {
                  // aligne = true;
                }
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                        top: 70,
                        child: SvgPicture.asset(
                          'assets/images/qiblah/externe-ring.svg',
                          width: 320,
                        )),
                    Transform.rotate(
                      angle: angle,
                      child: SvgPicture.asset(
                          'assets/images/qiblah/qib-interne-3.svg',
                          width: 160),
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 50.0),
                        child: Text(
                          "Aligne les deux pointes pour trouver la direction",
                          textAlign: TextAlign.center,
                          style: textDescription,
                        ),
                      ),
                    )
                  ],
                );
              }
            },
          );
        },
        valueListenable: refreshInt);
  }
}

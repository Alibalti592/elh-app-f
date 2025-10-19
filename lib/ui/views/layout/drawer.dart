import 'package:elh/ui/views/modules/Faq/QsnView.dart';
import 'package:elh/ui/views/modules/Relation/RelationView.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/layout/drawerModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class BBNavigationDrawer extends StatefulWidget {
  const BBNavigationDrawer({Key? key}) : super(key: key);
  @override
  NavigationDrawerState createState() => NavigationDrawerState();
}

class NavigationDrawerState extends State<BBNavigationDrawer>
    with AutomaticKeepAliveClientMixin<BBNavigationDrawer> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DrawerViewModel>.reactive(
      builder: (context, model, child) => Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
                height: 150,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(220, 198, 169, 1),
                      Color.fromRGBO(143, 151, 121, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 5, top: 35, bottom: 10),
                  child: Center(
                    child: Image(
                        image: AssetImage("assets/images/logo-no-bg.png"),
                        height: 90),
                  ),
                )),
            UIHelper.verticalSpace(50),

            createDrawerBodyItemSvg(
                imageName: 'users.svg',
                size: 25.0,
                text: 'Ma communauté',
                onTap: () {
                  Navigator.pop(context); //close drawer
                  model.navigateToView(RelationView());
                }),

            createDrawerBodyItemSvg(
                imageName: 'Icon_Settings.svg',
                size: 25.0,
                text: 'Mon compte',
                onTap: () {
                  if (model.userInfos != null) {
                    Navigator.pop(context); //close drawer
                    model.navigateToViewByName('profileInfos',
                        arguments: {"userInfos": model.userInfos});
                  }
                }),

            // createDrawerBodyItemSvg(
            //     imageName:  'icon/salat-icon.png',
            //     size: 30.0,
            //     type: 'png',
            //     text: model.pfLabel(),
            //     onTap: () {
            //       Navigator.pop(context); //close drawer
            //       if( model.isPF){
            //         model.navigateToView(MyPompeView());
            //       } else {
            //         model.navigateToView(AddPompeView());
            //       }
            //
            //     }
            // ),

            createDrawerBodyItemSvg(
                imageName: 'Icon_Details.svg',
                size: 25.0,
                text: 'FAQ',
                onTap: () {
                  Navigator.pop(context); //close drawer
                  model.navigateToFaq();
                }),

            createDrawerBodyItem(
                iconData: Icons.call_missed_outgoing,
                text: 'À propos de nous',
                onTap: () {
                  Navigator.pop(context); //close drawer
                  model.navigateToView(QsnView());
                }),

            createDrawerBodyItem(
                iconData: Icons.exit_to_app,
                text: 'Se déconnecter',
                onTap: () {
                  model.logout();
                }),

            // Divider(),
            UIHelper.verticalSpace(200),

            GestureDetector(
              child: Center(
                child: Text('Conditions générales d’utilisation',
                    style: TextStyle(color: primaryColor, fontSize: 12)),
              ),
              onTap: () {
                Uri _url = Uri.parse('https://test.muslim-connect.fr/cgu');
                launchUrl(_url);
              },
            ),
            UIHelper.verticalSpaceSmall(),
            GestureDetector(
              child: Center(
                child: Text('Mentions légales',
                    style: TextStyle(color: primaryColor, fontSize: 12)),
              ),
              onTap: () {
                Uri _url = Uri.parse(
                    'https://test.muslim-connect.fr/mentions-legales');
                launchUrl(_url);
              },
            ),
            UIHelper.verticalSpaceSmall(),
            Center(
              child: Text(
                'Version ${model.versionName}',
              ),
            ),
          ],
        ),
      ),
      viewModelBuilder: () => DrawerViewModel(),
    );
  }
}

Widget createDrawerHeader() {
  return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill, image: AssetImage('images/bg_header.jpeg'))),
      child: Stack(children: <Widget>[
        Positioned(
            bottom: 12.0,
            left: 16.0,
            child: Text("",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500))),
      ]));
}

Widget createDrawerBodyItemSvg(
    {required String imageName,
    required String text,
    required GestureTapCallback onTap,
    size = 30.0,
    type = 'svg'}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        UIHelper.horizontalSpace(6),
        SizedBox(
          width: 35,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: type == 'svg'
                ? SvgPicture.asset(
                    'assets/icon/$imageName',
                    color: fontGreyDark,
                    height: size,
                    width: 20.0,
                    // fit: BoxFit.fill,
                  )
                : Image(
                    image: AssetImage("assets/$imageName"),
                    height: size,
                    width: 28.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 25.0),
          child: SizedBox(width: 180, child: Text(text)),
        )
      ],
    ),
    onTap: onTap,
  );
}

Widget createDrawerBodyItem(
    {required IconData iconData,
    required String text,
    required GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        UIHelper.horizontalSpace(6),
        SizedBox(
          width: 40,
          child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Icon(iconData, color: fontGrey, size: 24)),
        ),
        Padding(
          padding: EdgeInsets.only(left: 25.0),
          child: SizedBox(width: 180, child: Text(text)),
        )
      ],
    ),
    onTap: onTap,
  );
}

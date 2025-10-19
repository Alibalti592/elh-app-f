import 'package:elh/models/mosque.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Mosque/MosqueController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class MosqueView extends StatefulWidget {
  bool isForSelect = false;

  MosqueView({isForSelect = false}) {
    this.isForSelect = isForSelect;
  }

  @override
  MosqueViewState createState() => MosqueViewState(isForSelect);
}

class MosqueViewState extends State<MosqueView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool isForSelect = false;

  MosqueViewState(isForSelect) {
    this.isForSelect = isForSelect;
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MosqueController>.reactive(
      builder: (context, controller, child) => Scaffold(
        backgroundColor: bgLight,
        body: Scaffold(
          appBar: AppBar(
            leadingWidth: 60,
            toolbarHeight: 60,
            titleSpacing: 0,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            title: Text("Mosquées", style: headerTextWhite),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(220, 198, 169, 1.0),
                    Color.fromRGBO(143, 151, 121, 1.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                color: bgLight,
                padding:
                    EdgeInsets.only(bottom: 15, top: 20, left: 20, right: 20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        TextFormField(
                          controller: controller.cityTextController,
                          onTap: () {
                            controller.openSearchLocation(context);
                          },
                          readOnly: true,
                          maxLines: 1,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: bgGrey, width: 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                              borderSide: BorderSide(color: bgGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                              borderSide: BorderSide(color: bgGrey),
                            ),
                            filled: true,
                            fillColor: white,
                            labelText: "Saisir la ville ...",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.isLoading
                    ? Center(child: BBloader())
                    : RefreshIndicator(
                        color: primaryColor,
                        child: ListView(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          children: mosques(controller),
                        ),
                        onRefresh: controller.refreshData,
                      ),
              ),
              Container(
                color: bgLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      "Votre mosquée n’est pas répertoriée ?",
                      style: TextStyle(
                        color: fontGreyDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.contact();
                      },
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 15),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Contactez nous',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Karla',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      viewModelBuilder: () => MosqueController(isForSelect),
    );
  }

  List<Widget> mosques(MosqueController mosqueController) {
    List<Widget> mosqueList = [];
    if (mosqueController.hasSearch && mosqueController.isForSelect) {
      mosqueList.add(
        Container(
            color: bgLight,
            padding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
            child: Column(
              children: [
                Text("Vous n'avez pas trouvé votre mosquée ?",
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center),
                UIHelper.verticalSpace(5),
                GestureDetector(
                  onTap: () {
                    mosqueController.manualAdd();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Saisir ma mosquée manuellement",
                        style: TextStyle(
                            fontSize: 15,
                            color: fontDark,
                            fontWeight: FontWeight.w700),
                      ),
                      Icon(
                        Icons.arrow_forward_outlined,
                        size: 17,
                      )
                    ],
                  ),
                ),
              ],
            )),
      );
    }
    mosqueController.mosques.forEach((Mosque mosque) {
      mosqueList.add(_mosque(mosqueController, mosque));
      mosqueList.add(UIHelper.verticalSpace(10));
    });
    mosqueList.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        children: [
          Text('Mes mosquées favorites', style: inTitleStyle),
          UIHelper.horizontalSpace(5),
          GestureDetector(
            onTap: () {
              mosqueController.showInfo();
            },
            child: Icon(MdiIcons.informationOutline),
          )
        ],
      ),
    ));
    mosqueController.myMosques.forEach((Mosque mosque) {
      mosqueList.add(_mosque(mosqueController, mosque));
      mosqueList.add(UIHelper.verticalSpace(10));
    });

    if (mosqueController.isOwner) {
      mosqueList.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Text('Gestion', style: inTitleStyle),
      ));
      mosqueController.ownMosques.forEach((Mosque mosque) {
        mosqueList.add(_mosque(mosqueController, mosque, isOwner: true));
        mosqueList.add(UIHelper.verticalSpace(10));
      });
    }
    return mosqueList;
  }

  Widget _mosque(MosqueController mosqueController, Mosque mosque,
      {isOwner = false}) {
    Widget tileContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mosque.name,
            style: TextStyle(
                fontSize: 15.0,
                color: fontDark,
                fontWeight: FontWeight.w700,
                height: 1.3)),
        RichText(
          text: TextSpan(
              text: "${mosque.location.adress}, ${mosque.location.city}",
              style: TextStyle(color: fontGreyDark, fontSize: 12),
              children: [
                TextSpan(
                    text: mosque.distance > 0 ? " (${mosque.distance}km)" : "",
                    style: TextStyle(color: fontGrey, fontSize: 13)),
              ]),
        ),
      ],
    );

    if (mosqueController.isForSelect) {
      return GestureDetector(
        child: ListTile(
          onTap: () {
            mosqueController.selectMosque(mosque);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding:
              EdgeInsets.only(left: 20, right: 15, top: 5, bottom: 5),
          tileColor: Colors.white,
          title: tileContent,
          trailing: Icon(MdiIcons.chevronRight, color: fontDark),
        ),
      );
    }
    List<PopupMenuItem> menuItems = [];
    menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(MdiIcons.mapMarker),
            UIHelper.horizontalSpace(8),
            Text('Naviguer vers la destination'),
          ],
        ),
        value: "map"));
    menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Icon(mosque.isFavorite
                ? MdiIcons.thumbDownOutline
                : MdiIcons.thumbUpOutline),
            UIHelper.horizontalSpace(8),
            Text(mosque.isFavorite
                ? 'Retirer des favoris'
                : 'Ajouter en favoris'),
          ],
        ),
        value: "favoris"));
    menuItems.add(PopupMenuItem(
        child: Row(
          children: [
            Image(
                image: AssetImage("assets/icon/salat-icon.png"),
                height: 20.0,
                width: 25),
            UIHelper.horizontalSpace(8),
            Text("Salât Al-Janaza annoncées"),
          ],
        ),
        value: "death"));
    if (isOwner) {
      menuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.shareVariantOutline),
              UIHelper.horizontalSpace(8),
              Text("Gestion"),
            ],
          ),
          value: "gestion"));
    }

    return Card(
        elevation: 0.0,
        color: const Color(0xFFFFFFFF),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 10,
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tileContent,
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: PopupMenuButton(
                  elevation: 3,
                  offset: Offset(30, 35),
                  child: Icon(MdiIcons.dotsVerticalCircleOutline),
                  itemBuilder: (BuildContext bc) => menuItems,
                  onCanceled: () {},
                  onSelected: (val) {
                    if (val == 'gestion') {
                      mosqueController.editMosque(mosque);
                    } else if (val == 'death') {
                      mosqueController.gotToDeceMosque(mosque);
                    } else if (val == 'favoris') {
                      mosqueController.markFavorite(mosque);
                    } else if (val == 'map') {
                      mosqueController.gotToMap(mosque);
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}

import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Deuil/DeuilController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class DeuilView extends StatefulWidget {
  @override
  DeuilViewState createState() => DeuilViewState();
}

class DeuilViewState extends State<DeuilView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeuilController>.reactive(
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLightV2,
            appBar: AppBar(
              title:
                  Text("${controller.getBarLAbel()}", style: headerTextWhite),
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor:
                  Colors.transparent, // 🔑 transparent pour voir le gradient
              leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    controller.goBack();
                    //Navigator.of(context).pop('donothing');
                  }),
              actions: [],
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
            body: SafeArea(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                children: [
                  UIHelper.verticalSpace(50),
                  controller.step == 1
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20), // add space from edges
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 25, // horizontal space between cards
                              runSpacing: 25, // vertical space between rows
                              children: [
                                __navCard(
                                  SvgPicture.asset('assets/icon/family.svg',
                                      color: fontGreyDark,
                                      height: 38,
                                      width: 25.0),
                                  'Pour la famille',
                                  controller,
                                  'family',
                                ),
                                __navCard(
                                  SvgPicture.asset('assets/icon/women2.svg',
                                      color: fontGreyDark,
                                      height: 38,
                                      width: 25.0),
                                  "Pour l'épouse",
                                  controller,
                                  'epouse',
                                ),
                                __navCard(
                                  SvgPicture.asset('assets/icon/women1.svg',
                                      color: fontGreyDark,
                                      height: 38,
                                      width: 25.0),
                                  "Pour l'épouse enceinte",
                                  controller,
                                  'enceinte',
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(controller.getLabelDate(),
                                  style: noResultStyle),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                controller: controller.dateController,
                                onTap: () {
                                  picker.DatePicker.showDatePicker(
                                    context,
                                    showTitleActions: true,
                                    onConfirm: (date) {
                                      controller.updateDate(date);
                                    },
                                    currentTime: DateTime.now(),
                                    maxTime: controller.maxTime,
                                    locale: picker.LocaleType.fr,
                                  );
                                },
                                readOnly: true,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Saisir la date ...',
                                  hintStyle: TextStyle(
                                      color: fontGreyLight, fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                        color: Color.fromRGBO(229, 231, 235, 1),
                                        width: 2),
                                  ),
                                  filled: true,
                                  fillColor: white,
                                ),
                              ),
                            ),
                            //view result
                            UIHelper.verticalSpace(5),
                            controller.isSsaving ? BBloader() : Container(),
                            UIHelper.verticalSpace(10),
                            controller.isSsaving ||
                                    controller.isLoading ||
                                    controller.ref == 'na'
                                ? Container()
                                : Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                            "Épingler la période de deuil",
                                            style: labelSmallStyle),
                                      ),
                                      UIHelper.verticalSpace(10),
                                      GestureDetector(
                                        onTap: () {
                                          controller
                                              .savePeriode(controller.endDate);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Période jusqu'au ${controller.endDate}",
                                                style: TextStyle(
                                                    fontSize: 16, color: white),
                                              ),
                                              UIHelper.horizontalSpace(10),
                                              Icon(Icons.save_outlined,
                                                  color: bgLightV2, size: 18)
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                            UIHelper.verticalSpace(20),
                            _deuilContent(controller),
                            UIHelper.verticalSpace(10),
                          ],
                        ),
                  UIHelper.verticalSpace(30),
                  controller.deuilDates.length > 0 && controller.step == 1
                      ? Column(
                          children: [
                            Center(
                                child: Text(
                                    'Mes périodes de deuil enregistrées',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: fontDark,
                                        fontFamily: 'Karla'))),
                            __deuidates(controller)
                          ],
                        )
                      : Container(),
                ],
              ),
            )),
        viewModelBuilder: () => DeuilController());
  }

  Widget _deuilContent(DeuilController controller) {
    if (controller.step == 1 || controller.startDate == null) {
      return Container();
    }
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: controller.isLoading
            ? UIHelper.lineLoaders(5, 4)
            : HtmlWidget(controller.content,
                onTapUrl: (url) => controller.openUrl(url)));
  }

  __navCard(icon, label, controller, type,
      {double iconWrapHeight = 50.0, double fontSize = 15.0}) {
    const bgWhite = Color(0xffffffff);

    return GestureDetector(
      onTap: () {
        controller.selectType(type);
      },
      child: Material(
        elevation: 4, // Added elevation
        borderRadius: BorderRadius.circular(10),
        color: bgWhite,
        child: Container(
          width: 124,
          height: 120,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 55,
                    height: iconWrapHeight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: icon,
                    ),
                  ),
                  UIHelper.verticalSpace(10),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize,
                      color: Colors.black,
                      fontFamily: 'inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  __deuidates(DeuilController controller) {
    if (controller.deuilDates.length == 0 || controller.isLoadingdeuilsdates) {
      return Container();
    }
    List<Widget> listWigets = [];
    controller.deuilDates.forEach((deuilDate) {
      listWigets.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Période de deuil jusqu'au ${deuilDate.date}",
              style: TextStyle(color: fontDark),
            ),
            GestureDetector(
              onTap: () {
                controller.deleteDeuildate(deuilDate);
              },
              child: Icon(MdiIcons.close, size: 15, color: fontGrey),
            )
          ],
        ),
      ));
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      width: double.infinity,
      child: Column(children: listWigets),
    );
  }
}

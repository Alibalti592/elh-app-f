import 'package:elh/common/theme.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Dette/ListPhoneContactController.dart';
import 'package:elh/ui/views/modules/Dette/ObligationCard.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class ListPhoneContactView extends StatefulWidget {
  ListPhoneContactView();
  @override
  ListPhoneContactViewState createState() => ListPhoneContactViewState();
}

class ListPhoneContactViewState extends State<ListPhoneContactView> {
  ListPhoneContactViewState();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListPhoneContactController>.reactive(
        viewModelBuilder: () => ListPhoneContactController(),
        builder: (context, controller, child) => Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              elevation: 0,
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              title: Text("Contacts du téléphone", style: headerTextWhite),
              actions: [],
              flexibleSpace: Container(
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
              ),
            ),
            extendBody: true,
            body: controller.isLoading
                ? Center(child: BBloader())
                : SafeArea(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: TextFormField(
                              style: TextStyle(color: fontDark),
                              controller: controller.searchController,
                              focusNode: controller.focusNode,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                fillColor: white,
                                filled: true,
                                hintText: "Rechercher...",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: bgLight),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: bgLight),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintStyle: TextStyle(color: fontGreyLight),
                                suffixIcon: IconButton(
                                  onPressed: () => controller.searchContact(),
                                  icon: Icon(
                                    Icons.search,
                                    color: fontGreyLight,
                                    size: 20,
                                  ),
                                ),
                              ),
                              onChanged: (String search) {
                                controller.searchContact();
                              }),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: controller.refreshDatas,
                            child: ListView(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              children: __contacts(controller),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )));
  }

  __contacts(ListPhoneContactController controller) {
    List<Widget> contactWidgets = [];
    controller.contactsFiltered.forEach((contact) {
      contactWidgets.add(GestureDetector(
        onTap: () {
          controller.selectContact(contact);
        },
        child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                          width: 40,
                          height: 40,
                          clipBehavior: Clip.hardEdge,
                          decoration: new BoxDecoration(
                            color: Colors.black12,
                            shape: BoxShape.circle,
                          ),
                          child: contact.thumbnail != null
                              ? Image.memory(contact.thumbnail!, width: 40)
                              : Container()),
                      UIHelper.horizontalSpace(10),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${contact.displayName}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )),
                      Container(
                        width: 90,
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(MdiIcons.arrowRight,
                                  color: fontDark, size: 22)
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )),
      ));
    });
    return contactWidgets;
  }
}

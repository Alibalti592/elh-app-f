import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Dette/ListPhoneContactController.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class ListPhoneContactView extends StatefulWidget {
  ListPhoneContactView();

  @override
  ListPhoneContactViewState createState() => ListPhoneContactViewState();
}

class ListPhoneContactViewState extends State<ListPhoneContactView>
    with WidgetsBindingObserver {
  ListPhoneContactController? _vm;

  ListPhoneContactViewState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When we come back from Settings, re-check permission + reload
    if (state == AppLifecycleState.resumed && _vm != null) {
      _vm!.refreshDatas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListPhoneContactController>.reactive(
      viewModelBuilder: () => ListPhoneContactController(),
      onViewModelReady: (vm) => _vm = vm,
      builder: (context, controller, child) => Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          title: Text("Contacts du téléphone", style: headerTextWhite),
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
            ? const Center(child: BBloader())
            : SafeArea(
                child: controller.permissionGranted
                    ? Column(
                        children: [
                          // Search
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: TextFormField(
                              style: TextStyle(color: fontDark),
                              controller: controller.searchController,
                              focusNode: controller.focusNode,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
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
                                  onPressed: controller.searchContact,
                                  icon: Icon(
                                    Icons.search,
                                    color: fontGreyLight,
                                    size: 20,
                                  ),
                                ),
                              ),
                              onChanged: (_) => controller.searchContact(),
                            ),
                          ),
                          // List
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: controller.refreshDatas,
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                children: __contacts(controller),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.contacts,
                                size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text("Autorisation requise",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            const Text(
                              "Accès aux contacts désactivé.\n"
                              "Activez-le dans Réglages pour afficher vos contacts.",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: controller.openSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Ouvrir les réglages"),
                            ),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }

  List<Widget> __contacts(ListPhoneContactController controller) {
    final List<Widget> contactWidgets = [];
    for (final contact in controller.contactsFiltered) {
      contactWidgets.add(
        GestureDetector(
          onTap: () => controller.selectContact(contact),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: contact.thumbnail != null
                        ? Image.memory(contact.thumbnail!, width: 40)
                        : Container(),
                  ),
                  UIHelper.horizontalSpace(10),
                  Expanded(
                    child: Text(
                      contact.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(MdiIcons.arrowRight, color: fontDark, size: 22),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return contactWidgets;
  }
}

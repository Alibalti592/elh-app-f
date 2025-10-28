import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/Dette/ListPhoneContactController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:stacked/stacked.dart';

class ListPhoneContactView extends StatefulWidget {
  const ListPhoneContactView({super.key});

  @override
  ListPhoneContactViewState createState() => ListPhoneContactViewState();
}

class ListPhoneContactViewState extends State<ListPhoneContactView>
    with WidgetsBindingObserver {
  ListPhoneContactController? _vm;
  VoidCallback? _searchListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_vm != null && _searchListener != null) {
      _vm!.searchController.removeListener(_searchListener!);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _vm != null) {
      _vm!.refreshDatas();
    }
  }

  List<Contact> _filter(List<Contact> contacts, String qRaw) {
    final q = qRaw.trim().toLowerCase();
    if (q.isEmpty) return contacts;

    final flatQ = q.replaceAll(RegExp(r'[^0-9+]'), '');
    final checkPhones = flatQ.isNotEmpty;

    return contacts.where((c) {
      final name = c.displayName.toLowerCase();
      final nameHit = name.contains(q) ||
          (c.name.first?.toLowerCase().contains(q) ?? false) ||
          (c.name.last?.toLowerCase().contains(q) ?? false);

      bool phoneHit = false;
      if (checkPhones) {
        for (final p in c.phones) {
          final pFlat = p.number.replaceAll(RegExp(r'[^0-9+]'), '');
          if (pFlat.contains(flatQ)) {
            phoneHit = true;
            break;
          }
        }
      }
      return nameHit || phoneHit;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListPhoneContactController>.reactive(
      viewModelBuilder: () => ListPhoneContactController(),
      onViewModelReady: (vm) {
        _vm = vm;
        _searchListener ??= () {
          if (mounted) setState(() {});
        };
        vm.searchController.addListener(_searchListener!);
      },
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

        // Stable, no-flicker state machine:
        // - While checking permission: loader
        // - If denied: no-permission screen
        // - If granted & loading contacts: loader
        // - Else: content
        body: !controller.hasCheckedPermission
            ? const Center(child: BBloader())
            : !controller.permissionGranted
                ? _NoPermission(controller: controller)
                : controller.isLoading
                    ? const Center(child: BBloader())
                    : SafeArea(
                        child: Column(
                          children: [
                            // Search field
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: TextFormField(
                                controller: controller.searchController,
                                focusNode: controller.focusNode,
                                style: TextStyle(color: fontDark),
                                autocorrect: false,
                                textInputAction: TextInputAction.search,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: "Rechercher nom ou téléphone…",
                                  hintStyle: TextStyle(color: fontGreyLight),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  prefixIcon: Icon(Icons.search,
                                      color: fontGreyLight, size: 20),
                                  suffixIcon: controller
                                          .searchController.text.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip: 'Effacer',
                                          icon: Icon(Icons.clear,
                                              color: fontGreyLight, size: 20),
                                          onPressed: () {
                                            controller.searchController.clear();
                                            setState(() {});
                                          },
                                        ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // List (filtered every rebuild)
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: controller.refreshDatas,
                                child: Builder(
                                  builder: (_) {
                                    final filtered = _filter(
                                      controller.contacts,
                                      controller.searchController.text,
                                    );

                                    if (filtered.isEmpty) {
                                      return ListView(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 20),
                                        children: const [
                                          SizedBox(height: 40),
                                          Center(
                                            child: Text(
                                              "Aucun contact trouvé.",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 20),
                                      itemCount: filtered.length,
                                      itemBuilder: (_, i) => _contactTile(
                                        filtered[i],
                                        controller,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _contactTile(Contact contact, ListPhoneContactController controller) {
    return GestureDetector(
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
                    : const SizedBox.shrink(),
              ),
              UIHelper.horizontalSpace(10),
              Expanded(
                child: Text(
                  contact.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: Colors.black54, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoPermission extends StatelessWidget {
  const _NoPermission({required this.controller});
  final ListPhoneContactController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // no 'const' because primaryColor is not a compile-time const
          Icon(Icons.contacts, size: 56, color: primaryColor),
          const SizedBox(height: 12),
          const Text(
            "Autorisation requise",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            "Accès aux contacts désactivé.\n"
            "Activez-le dans Réglages pour afficher vos contacts.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.openSettings,
            child: const Text("Ouvrir les réglages"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

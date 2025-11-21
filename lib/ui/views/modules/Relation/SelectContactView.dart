import 'package:elh/locator.dart';
import 'package:elh/models/Relation.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/Dette/ListPhoneContactView.dart';
import 'package:elh/ui/views/modules/Relation/SearchRelationView.dart';
import 'package:elh/ui/views/modules/Relation/SelectContactController.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class SelectContactView extends StatefulWidget {
  final bool showContact;

  const SelectContactView({
    Key? key,
    this.showContact = false,
  }) : super(key: key);

  @override
  SelectContactViewState createState() => SelectContactViewState();
}

NavigationService _navigationService = locator<NavigationService>();

class SelectContactViewState extends State<SelectContactView> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SelectContactController>.reactive(
      viewModelBuilder: () => SelectContactController(),
      builder: (context, controller, child) => Scaffold(
        backgroundColor: bgLightV2,
        appBar: AppBar(
          title: Text(
            widget.showContact != true
                ? "Partage avec un membre mc"
                : "Ajouter un contact",
            style: headerTextWhite,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
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
        body: controller.isLoading
            ? const Center(child: BBloader())
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.refreshDatas,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    children: [
                      // --------- Section accès répertoire / créer contact ---------
                      if (widget.showContact) ...[
                        if (controller.canOpenPhoneContacts)
                          _topRow(
                            icon: Icons.search,
                            text: "Rechercher un contact du répertoire",
                            onTap: () async {
                              final value = await _navigationService
                                  .navigateWithTransition(
                                ListPhoneContactView(),
                                transitionStyle: Transition.downToUp,
                                duration: const Duration(milliseconds: 300),
                              );

                              if (value != null) {
                                UserInfos user;
                                if (value is Contact) {
                                  user = UserInfos(
                                    firstname: value.name.first,
                                    lastname: value.name.last,
                                    phone: value.phones.isNotEmpty
                                        ? value.phones.first.number
                                        : '',
                                    id: null,
                                    fullname: '',
                                    phonePrefix: '',
                                    city: '',
                                    photo: '',
                                  );
                                } else {
                                  user = value;
                                }
                                if (mounted) {
                                  Navigator.of(context).pop(user);
                                }
                              }
                            },
                          ),
                        const SizedBox(height: 10),
                        _topRow(
                          icon: Icons.add,
                          text: "Créer un contact",
                          onTap: () {
                            Navigator.of(context).pop('showForm');
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // --------- Titre Ma communauté ---------
                      const Text(
                        "Ma communauté",
                        style: TextStyle(
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color.fromRGBO(55, 65, 81, 1),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --------- Affichage conditionnel selon la présence de relations ---------
                      Builder(
                        builder: (_) {
                          final hasRelations = controller.relations.isNotEmpty;

                          if (!hasRelations) {
                            // EMPTY STATE : aucun membre
                            return _emptyCommunity(
                              onAddPressed: () async {
                                final result = await _navigationService
                                    .navigateWithTransition(
                                  SearchRelationView('select_contact'),
                                  transitionStyle: Transition.downToUp,
                                  duration: const Duration(milliseconds: 300),
                                );
                                if (result == 'updateList') {
                                  await controller.refreshDatas();
                                  if (mounted) setState(() {});
                                }
                              },
                            );
                          }

                          // LISTE NON VIDE : bouton + champ recherche + liste filtrée
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _topRow(
                                icon: Icons.add,
                                text: "Ajouter un membre à ma communauté",
                                onTap: () async {
                                  final result = await _navigationService
                                      .navigateWithTransition(
                                    SearchRelationView('select_contact'),
                                    transitionStyle: Transition.downToUp,
                                    duration: const Duration(milliseconds: 300),
                                  );

                                  if (result == 'updateList') {
                                    await controller.refreshDatas();
                                    if (mounted) setState(() {});
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: "Rechercher par nom",
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              ...relations(controller, searchQuery),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // --------- Top row réutilisable ---------
  Widget _topRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                selectionColor: const Color.fromRGBO(55, 65, 81, 1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(55, 65, 81, 1),
                ),
              ),
            ),
            Icon(MdiIcons.arrowRight, color: fontDark, size: 22),
          ],
        ),
      ),
    );
  }

  // --------- Liste des relations avec filtre ---------
  List<Widget> relations(
      SelectContactController controller, String searchQuery) {
    final List<Widget> relationList = [];

    final filteredRelations = controller.relations.where((relation) {
      final fullName =
          "${relation.user.firstname} ${relation.user.lastname}".toLowerCase();
      return fullName.contains(searchQuery.toLowerCase());
    }).toList();

    if (filteredRelations.isNotEmpty) {
      for (final relation in filteredRelations) {
        relationList.add(
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: const Color.fromRGBO(229, 231, 235, 1),
                width: 2,
              ),
            ),
            child: _userInfos(controller, relation, true),
          ),
        );
      }
    } else {
      relationList.add(
        const Padding(
          padding: EdgeInsets.all(4),
          child: Text(
            "Aucun contact trouvé",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return relationList;
  }

  // --------- Carte d'un membre ---------
  Widget _userInfos(
      SelectContactController controller, Relation relation, bool toValidate) {
    final UserInfos user = relation.user;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromRGBO(229, 231, 235, 1),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: userThumbDirect(
                      user.photo,
                      "${user.firstname.substring(0, 2)}",
                      20.0,
                    ),
                  ),
                ),
                UIHelper.horizontalSpace(20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color.fromRGBO(55, 65, 81, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _status(controller, relation, toValidate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------- Bouton sélectionner / aller à la fiche ---------
  Widget _status(
      SelectContactController controller, Relation relation, bool toValidate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () => controller.selectRelation(relation),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Icon(MdiIcons.arrowRight, color: fontDark, size: 22)],
        ),
      ),
    );
  }

  // --------- Empty State Ma communauté ---------
  Widget _emptyCommunity({required VoidCallback onAddPressed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(229, 231, 235, 1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.group_outlined,
              size: 48, color: Color.fromRGBO(107, 114, 128, 1)),
          const SizedBox(height: 12),
          const Text(
            "Tu n’as aucun membre dans ta communauté.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(55, 65, 81, 1),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "ajoute ton premier membre pour commencer.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color.fromRGBO(107, 114, 128, 1),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: onAddPressed,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text(
                "Ajouter un membre à ma communauté",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

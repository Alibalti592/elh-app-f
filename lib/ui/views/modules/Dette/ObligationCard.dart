import 'package:elh/services/TrancheService.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/CustomRectTween.dart';
import 'package:elh/ui/views/modules/Dette/ObligationCardController.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';

class ObligationCard extends StatefulWidget {
  final Obligation obligation;
  final bool directShare;

  ObligationCard({required this.obligation, this.directShare = false});

  @override
  ObligationCardState createState() =>
      ObligationCardState(obligation: obligation, directShare: directShare);
}

class ObligationCardState extends State<ObligationCard> {
  final TrancheService _trancheService = TrancheService();
  late Obligation obligation;
  bool directShare;

  ObligationCardState({required this.obligation, required this.directShare});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObligationCardController>.reactive(
      viewModelBuilder: () =>
          ObligationCardController(directShare, obligation: obligation),
      builder: (context, controller, child) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Hero(
            tag: "obligation-tag-${obligation.id}",
            createRectTween: (begin, end) =>
                CustomRectTween(begin: begin, end: end),
            child: RepaintBoundary(
              key: controller.globalKey,
              child: Material(
                color: bgLightCard,
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(image: backgroundImageSimple()),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Bismillahi R-Rahmani R-Rahim",
                                style: TextStyle(
                                    color: white,
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              ),
                              UIHelper.verticalSpace(0),
                              Text(
                                obligation.type == "amana"
                                    ? "Détails de la amana"
                                    : "Détails de la dette",
                                style: TextStyle(
                                    color: fontGreyDark,
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              UIHelper.verticalSpace(7),
                              _itemIUsers(obligation),
                              UIHelper.verticalSpace(7),
                              _item(MdiIcons.calendarOutline,
                                  obligation.dateDisplay,
                                  title: 'Date'),
                              if (obligation.type != 'amana') ...[
                                UIHelper.verticalSpace(
                                    obligation.amount != 0 ? 7 : 0),
                                if (obligation.amount != 0)
                                  _item(MdiIcons.cashCheck,
                                      "${obligation.amount} ${obligation.currency}",
                                      title: controller.montantText()),
                                UIHelper.verticalSpace(7),
                                _item(MdiIcons.cashCheck,
                                    "${obligation.remainingAmount} ${obligation.currency}",
                                    title: "Montant restant"),
                                UIHelper.verticalSpace(7),
                                if (obligation.note.isNotEmpty)
                                  _item(
                                    MdiIcons.noteOutline,
                                    obligation.note,
                                    title: controller.raisonText(obligation),
                                  ),
                                if (obligation.dateStartDisplay != null)
                                  _item(Icons.calendar_month_outlined,
                                      obligation.dateStartDisplay,
                                      title: 'Remboursement au plus tard'),
                              ],
                              if (obligation.type == 'amana') ...[
                                UIHelper.verticalSpace(7),
                                _item(MdiIcons.noteOutline, obligation.raison,
                                    title: "Se sont mis d'accord pour"),
                              ],
                              UIHelper.verticalSpace(4),
                              Center(
                                child: Image(
                                    image: AssetImage(
                                        "assets/images/logo-no-bg.png"),
                                    height: 60),
                              ),
                              UIHelper.verticalSpace(2),
                            ],
                          ),
                        ),
                      ),
                      // Close button
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.isSharing,
                        builder: (context, isSharing, child) {
                          return isSharing
                              ? Container(height: 10)
                              : Positioned(
                                  top: 10,
                                  right: 5,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 18),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 1,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(10),
                                      backgroundColor: Colors.black54,
                                    ),
                                  ),
                                );
                        },
                      ),
                      // Share button
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.isSharing,
                        builder: (context, isSharing, child) {
                          return (isSharing || directShare)
                              ? Container(height: 50)
                              : Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        controller.shareObligation(),
                                    child: Icon(MdiIcons.shareVariantOutline,
                                        color: Colors.white),
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(24),
                                      backgroundColor: Color(0xFF777777),
                                    ),
                                  ),
                                );
                        },
                      ),
                      // Add Tranche button (only for debts)
                      // if (obligation.type != 'amana')
                      //   Positioned(
                      //     bottom: 10,
                      //     left: 10,
                      //     child: ElevatedButton(
                      //       onPressed: _showAddTrancheDialog,
                      //       child: Text('Ajouter une tranche'),
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.green,
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 16, vertical: 12),
                      //         shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(8)),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTrancheDialog() {
    final amountController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une tranche'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant (€)'),
              ),
              TextField(
                controller: dateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                    labelText: 'Date de paiement (YYYY-MM-DD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                final date = dateController.text;

                if (amount == null || date.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Veuillez remplir tous les champs correctement')),
                  );
                  return;
                }

                final success = await _trancheService.createTranche(
                  obligation.id!,
                  obligation.id!,
                  amount,
                  date,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success != null
                        ? 'Tranche ajoutée avec succès !'
                        : 'Erreur lors de l’ajout'),
                  ),
                );
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Widget _itemIUsers(obligation) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Row(
          children: [
            Icon(Icons.group_outlined),
            UIHelper.horizontalSpace(15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (obligation.type != 'amana')
                      Text("Emprunteur : ",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: fontGrey)),
                    SizedBox(width: 1),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            "${obligation.preteurName}",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "${obligation.preteurNum}",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                UIHelper.verticalSpace(3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (obligation.type != 'amana')
                      Text(
                        "Prêteur: ",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: fontGrey),
                      ),
                    SizedBox(width: 1),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            "${obligation.emprunteurName}",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "${obligation.emprunteurNum}",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(icon, text, {title, extraTextWidget}) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        child: Row(
          children: [
            Icon(icon),
            UIHelper.horizontalSpace(15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Container(
                    width: 195,
                    child: Text(title,
                        style: TextStyle(color: fontGrey, fontSize: 10)),
                  ),
                Container(
                    width: 190,
                    child: Text(text,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.black))),
                if (extraTextWidget != null) extraTextWidget,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

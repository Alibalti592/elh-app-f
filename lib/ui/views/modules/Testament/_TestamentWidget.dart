import 'package:elh/common/theme.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Testament.dart';
import 'package:elh/ui/shared/text_styles.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';
import 'package:elh/ui/views/modules/Dette/ObligationCard.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class TestamentWidget extends StatelessWidget {
  final Testament testament;
  final List<Obligation> jeds;
  final List<Obligation> onms;
  final List<Obligation> amanas;
  final String joursJeun;
  const TestamentWidget(
      this.testament, this.jeds, this.onms, this.amanas, this.joursJeun,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UIHelper.verticalSpace(10),
        Text(
            "Allah le Très Haut à prescrit : « Quand la mort est proche de l'un de vous et s'il laisse des biens, de faire un testament en règle en faveur de ses père et mère et de ses plus proches. C'est un devoir pour les pieux.» (Sourate 2, verset 180)",
            style: TextStyle(
                color: Color.fromRGBO(55, 65, 81, 1),
                fontWeight: FontWeight.bold)),
        UIHelper.verticalSpace(20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: UIHelper.h1("Testament de : ${testament.from}"),
              ),
              UIHelper.verticalSpace(10),
              Text(
                  'Je souhaite être enterré(e) selon les rites musulmans dans le pays et  ou ville suivante :',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: fontGrey,
                      fontWeight: FontWeight.bold)),
              UIHelper.verticalSpace(3),
              testament.location != null
                  ? Text(testament.location!, style: TextStyle(fontSize: 14))
                  : Text("Vous n'avez rien renseigné", style: textDescription),
              UIHelper.verticalSpace(10),
              Text('Je souhaite que ma toilette mortuaire soit faite par :',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: fontGrey,
                      fontWeight: FontWeight.bold)),
              testament.toilette != null
                  ? Text(testament.toilette!, style: TextStyle(fontSize: 14))
                  : Text("Vous n'avez rien renseigné", style: textDescription),
              UIHelper.verticalSpace(8),
              Text(
                  'Je souhaite que mon enterrement se fasse sans aucune innovation et dans les conditions suivantes :',
                  style: TextStyle(
                      fontSize: 13.0,
                      color: fontGrey,
                      fontWeight: FontWeight.bold)),
              testament.family != null
                  ? Text(testament.family!, style: TextStyle(fontSize: 14))
                  : Text("Vous n'avez rien renseigné", style: textDescription),
              UIHelper.verticalSpace(8),
              Text(
                  'Je souhaite que l’on rembourse mes dettes de la manière suivante :',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: fontGrey,
                      fontWeight: FontWeight.bold)),
              testament.fixe != null
                  ? Text(testament.fixe!, style: TextStyle(fontSize: 14))
                  : Text("Vous n'avez rien renseigné", style: textDescription),
              UIHelper.verticalSpace(8),
              Text(
                  'Je souhaite que l’argent prêté et qui vous sera rendu soit utilisé de la manière suivante :',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: fontGrey,
                      fontWeight: FontWeight.bold)),
              testament.goods != null
                  ? Text(testament.goods!, style: TextStyle(fontSize: 14))
                  : Text("Vous n'avez rien renseigné", style: textDescription),
              UIHelper.verticalSpace(8),
              Text('Je souhaite laisser les recommandations suivantes :',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: fontGrey,
                      fontWeight: FontWeight.bold)),
              testament.lastwill != null
                  ? Text(testament.lastwill!, style: TextStyle(fontSize: 14))
                  : Text("Vous n'avez rien renseigné", style: textDescription),
              UIHelper.verticalSpace(8),
              Text('Jours de jeûn à rattraper :',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: fontGrey,
                      fontWeight: FontWeight.bold)),
              Text(joursJeun, style: TextStyle(fontSize: 14)),
              Center(
                child: Image(
                    image: AssetImage("assets/images/logo-no-bg.png"),
                    height: 70),
              ),
            ],
          ),
        ),
        UIHelper.verticalSpace(15),
        Column(
          children: listObligations(
              this.jeds, context, 'On me doit', "Aucun prêt en cours"),
        ),
        UIHelper.verticalSpace(15),
        Column(
          children: listObligations(
              this.onms, context, 'je dois', "Aucune dette en cours"),
        ),
        UIHelper.verticalSpace(15),
        Column(
          children: listObligations(
              this.amanas, context, 'Amanas en cours', "Aucune amana en cours"),
        ),
        UIHelper.verticalSpace(50),
      ],
    );
  }

  List<Widget> listObligations(obligations, context, title, emtyText) {
    bool isAShare = false;
    List<Widget> obligationWigets = [];

    obligationWigets.add(Text(title, style: inTitleStyle));

    if (obligations.isEmpty) {
      String text = emtyText;
      obligationWigets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Center(child: Text(text)),
      ));
    } else {
      obligationWigets.add(UIHelper.verticalSpace(10));
      obligations.forEach((obligation) {
        obligationWigets.add(_obligation(obligation, context, isAShare));
      });
    }
    return obligationWigets;
  }

  Widget _obligation(Obligation obligation, context, isAShare) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Hero(
        tag: "obligation-tag-${obligation.id}",
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (context) => Center(
                      child: ObligationCard(
                          obligation: obligation, directShare: false),
                    ),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              tileColor: Colors.white,
              title: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              obligation.cardOtherName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.black,
                                fontFamily: 'Karla',
                              ),
                              overflow:
                                  TextOverflow.ellipsis, // prevents overflow
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (obligation.fileUrl != null &&
                                  obligation.fileUrl!.isNotEmpty) {
                                try {
                                  final ref = FirebaseStorage.instance
                                      .refFromURL(obligation.fileUrl!);
                                  final downloadUrl =
                                      await ref.getDownloadURL();

                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Image.network(
                                                downloadUrl,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      child: Text(
                                                          "Impossible de charger l'image"),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Fermer"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Impossible de charger l'image")),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Pas de preuve disponible")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(143, 151, 121, 1.0),
                            ),
                            child: const Text(
                              "Voir preuve",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      // other widgets in your Column can go herer
                      UIHelper.verticalSpace(2),
                      Text("Tel : ${obligation.cardOtherTel} ",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'Karla')),
                      UIHelper.verticalSpace(2),
                      obligation.type != 'amana'
                          ? Text("Montant Initial :  ${obligation.amount} €",
                              style:
                                  TextStyle(color: fontGreyDark, fontSize: 12))
                          : Container(),
                      Text("Montant restant :  ${obligation.remainingAmount} €",
                          style: TextStyle(color: fontGreyDark, fontSize: 12)),
                      UIHelper.verticalSpace(2),
                      Text("Date : ${obligation.dateDisplay}",
                          style: TextStyle(color: fontGreyDark, fontSize: 12)),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

import 'package:elh/services/TrancheService.dart';
import 'package:elh/ui/widgets/Upload_file_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Tranche.dart'; // <-- pareil ici
import 'package:elh/ui/views/modules/Dette/AddObligationController.dart';

class ObligationView extends StatefulWidget {
  final Obligation obligation;
  final Future<void> Function()? onTrancheAdded; // 👈 Add this callback

  const ObligationView({
    super.key,
    required this.obligation,
    this.onTrancheAdded, // 👈 Include it in constructor
  });

  @override
  _ObligationViewState createState() => _ObligationViewState();
}

class _ObligationViewState extends State<ObligationView> {
  final TrancheService _trancheService = TrancheService();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final AddObligationController _controller =
      AddObligationController('onm', Obligation());

  String? _uploadedFileUrl;

  bool _isLoading = false;
  List<Tranche> _tranches = [];

  @override
  void initState() {
    super.initState();
    _loadTranches();
  }

  Future<void> _loadTranches() async {
    final tranches = await _trancheService.getTranches(widget.obligation.id!);
    setState(() => _tranches = tranches);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _showAddTrancheDialog() {
    _amountController.clear();
    _dateController.clear();

    final scaffoldContext = context; // Outer context for SnackBars

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(
            "Ajouter un versement",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(55, 65, 81, 1),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Montant
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align children to the left
                  children: [
                    Text(
                      "Montant de la tranche",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(55, 65, 81, 1),
                      ),
                    ),
                    SizedBox(height: 7),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(229, 231, 235, 1),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align children to the left
                  children: [
                    Text(
                      "Date",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(55, 65, 81, 1),
                      ),
                    ),
                    SizedBox(height: 7),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          _dateController.text =
                              pickedDate.toIso8601String().split('T')[0];
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(229, 231, 235, 1),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: primaryColor,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    //   onPressed: () async {},
                    //   child: Text(
                    //     "Attacher une preuve",
                    //     style: const TextStyle(
                    //       fontSize: 15,
                    //       fontWeight: FontWeight.w600,
                    //       color: white,
                    //     ),
                    //   ),
                    // ),
                    UploadFileWidget(controller: _controller),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (_isLoading) return;

                final amountText = _amountController.text.trim();
                final dateText = _dateController.text.trim();

                if (amountText.isEmpty || dateText.isEmpty) {
                  ScaffoldMessenger.of(scaffoldContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                          content: Text("Veuillez remplir tous les champs")),
                    );
                  return;
                }

                final amount = double.tryParse(amountText);
                if (amount == null) {
                  ScaffoldMessenger.of(scaffoldContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text("Montant invalide")),
                    );
                  return;
                }

                setStateDialog(() => _isLoading = true);

                final obligationId = widget.obligation.id;
                final emprunteurId = widget.obligation.getEmprunteurId();
                print(
                    "obligationId: $obligationId, emprunteurId: $emprunteurId, file: ${_controller.obligation.file}");
                try {
                  final newTranche = await _trancheService
                      .createTranche(
                          obligationId, emprunteurId, amount, dateText,
                          filePath: _controller.obligation.file)
                      .timeout(const Duration(seconds: 10));

                  setStateDialog(() => _isLoading = false);
                  print('amount: ${newTranche?.amount}');

                  if (newTranche != null) {
                    if (newTranche.status == 'validée') {
                      int newAmount = amount.toInt();
                      print(newAmount);
                      widget.obligation.remainingAmount =
                          (widget.obligation.remainingAmount ?? 0) - newAmount;
                    }
                    setState(() => _tranches.add(newTranche));
                    await widget.onTrancheAdded?.call();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(scaffoldContext)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                            content: Text("Tranche ajoutée avec succès !")),
                      );
                  } else {
                    ScaffoldMessenger.of(scaffoldContext)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                            content:
                                Text("Erreur lors de l'ajout de la tranche")),
                      );
                  }
                } catch (e) {
                  setStateDialog(() => _isLoading = false);
                  ScaffoldMessenger.of(scaffoldContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text("Erreur réseau : $e")),
                    );
                }
              },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white, // same as other button text color
                      ),
                    )
                  : const Text(
                      "Sauvegarder",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // same as other button text color
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTranche() async {
    final obligationId = widget.obligation.id;
    final emprunteurId =
        widget.obligation.getEmprunteurId(); // now uses relatedUserId

    final amountText = _amountController.text.trim();
    final dateText = _dateController.text.trim();

    if (amountText.isEmpty || dateText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Montant invalide")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newTranche = await _trancheService
          .createTranche(
            obligationId,
            emprunteurId,
            amount,
            dateText,
            filePath: _controller.fileUrl.value,
          )
          .timeout(const Duration(seconds: 10));

      setState(() => _isLoading = false);

      if (newTranche != null) {
        setState(() => _tranches.add(newTranche));

        ;

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tranche ajoutée avec succès !")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Erreur réseau ou serveur : impossible d'ajouter la tranche")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau : $e")),
      );
    }
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          UIHelper.horizontalSpace(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrancheItem(Tranche tranche) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(MdiIcons.cash, color: Colors.green),
        title: Text("${tranche.amount} €"),
        subtitle: Text("Échéance : ${tranche.paidAt}"),
      ),
    );
  }

  Widget buildLabeledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(55, 65, 81, 1),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                  color: Color.fromRGBO(229, 231, 235, 1), width: 2),
            ),

            isDense: true, // réduit la hauteur
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final obligation = widget.obligation;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // back arrow color
        ),
        title: const Text(
          "Details",
          style: TextStyle(color: Colors.white),
        ),
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
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (obligation.fileUrl != null &&
                    obligation.fileUrl!.isNotEmpty) {
                  try {
                    // Get a proper download URL from Firebase Storage
                    final ref = FirebaseStorage.instance
                        .refFromURL(obligation.fileUrl!);
                    final downloadUrl = await ref.getDownloadURL();

                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Image.network(
                                  downloadUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null)
                                      return child; // ✅ Image fully loaded
                                    return const Center(
                                      child:
                                          CircularProgressIndicator(), // ✅ Loader while loading
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                            "Impossible de charger l'image"),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
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
                          content: Text("Impossible de charger l'image")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pas de preuve disponible")),
                  );
                }
              },
              child: const Text(
                "Preuve attachée",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Champs avec labels au-dessus
            buildLabeledField("Emprunteur",
                "${obligation.preteurName} ${obligation.preteurNum}"),
            buildLabeledField("Prêteur",
                "${obligation.emprunteurName} ${obligation.emprunteurNum}"),
            buildLabeledField("Date", obligation.dateDisplay),
            buildLabeledField("Date remboursement au plus tard",
                obligation.dateStartDisplay ?? ""),
            buildLabeledField(
              "Montant initial",
              "${obligation.amount}${obligation.currency}",
            ),
            buildLabeledField("Montant restant",
                "${obligation.remainingAmount}${obligation.currency}"),
            buildLabeledField("Note", obligation.raison),

            const SizedBox(height: 16),

            // Liste des tranches
            const Text(
              "Déjà rendu :",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color.fromRGBO(55, 65, 81, 1),
              ),
            ),
            const SizedBox(height: 8),
            if (_tranches.isEmpty)
              const Text(
                "Aucune tranche pour le moment.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color.fromRGBO(55, 65, 81, 1),
                ),
              )
            else
              Column(
                children: _tranches.asMap().entries.map((entry) {
                  final i = entry.key + 1;
                  final tranche = entry.value;
                  return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text("Tranche $i"),
                        subtitle: Text(
                            "${tranche.amount} ${obligation.currency} le ${tranche.paidAt.toString()}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (tranche.fileUrl != null &&
                                tranche.fileUrl!.isNotEmpty) {
                              try {
                                // Get a proper download URL from Firebase Storage
                                final ref = FirebaseStorage.instance
                                    .refFromURL(tranche.fileUrl!);
                                final downloadUrl = await ref.getDownloadURL();
                                showDialog(
                                  context: context,
                                  barrierDismissible:
                                      true, // user can tap outside to close if desired
                                  builder: (context) => Dialog(
                                    insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        minHeight:
                                            300, // ✅ gives fixed minimum size so dialog doesn’t jump
                                        minWidth: 300,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              // ✅ Ensures fixed area for the image, preventing dialog resize
                                              child: Center(
                                                child: Image.network(
                                                  downloadUrl,
                                                  fit: BoxFit.contain,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        child: Text(
                                                            "Impossible de charger l'image"),
                                                      ),
                                                    );
                                                  },
                                                ),
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
                                    content: Text("Pas de preuve disponible")),
                              );
                            }
                          },
                          child: const Text(
                            "voir preuve",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ));
                }).toList(),
              ),

            const SizedBox(height: 20),

            // Ajouter une tranche
            Center(
              child: ElevatedButton(
                onPressed: _showAddTrancheDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(143, 151, 121, 1.0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Ajouter un versement",
                  style: TextStyle(
                      fontSize: 20,
                      color: white,
                      fontFamily: 'inter',
                      fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}

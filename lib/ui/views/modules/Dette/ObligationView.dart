import 'dart:convert';
import 'dart:math';

import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/TrancheService.dart';
import 'package:elh/ui/views/modules/Dette/DetailVersementDialog.dart';
import 'package:elh/ui/views/modules/Dette/DetteController.dart';
import 'package:elh/ui/widgets/Upload_file_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Tranche.dart'; // <-- pareil ici
import 'package:elh/ui/views/modules/Dette/AddObligationController.dart';

class ObligationView extends StatefulWidget {
  final Obligation obligation;
  final Future<void> Function()? onTrancheAdded;

  const ObligationView({
    super.key,
    required this.obligation,
    this.onTrancheAdded,
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
  DateTime? _selectedDate; // Holds the picked date internally

  String? _uploadedFileUrl;
  String getTitle(String type) {
    if (type == 'jed') {
      return "On me doit";
    } else if (type == 'onm') {
      return "Je dois";
    } else if (type == 'amana') {
      return "Mes Amanas";
    } else {
      return "Mes Obligations"; // fallback title
    }
  }

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

  void _showAddTrancheDialog({required String date}) {
    _amountController.clear();
    _dateController.clear();
    _selectedDate = null; // Reset previous selection

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Montant du versement",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(55, 65, 81, 1),
                      ),
                    ),
                    const SizedBox(height: 7),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date du versement",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(55, 65, 81, 1),
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          // Save internally
                          setState(() => _selectedDate = pickedDate);

                          // Display for user
                          _dateController.text =
                              "${pickedDate.day.toString().padLeft(2, '0')}/"
                              "${pickedDate.month.toString().padLeft(2, '0')}/"
                              "${pickedDate.year}";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Choisir une date",
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
                UploadFileWidget(controller: _controller),
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
                final selectedDate = _selectedDate;

                if (amountText.isEmpty || selectedDate == null) {
                  ScaffoldMessenger.of(scaffoldContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                          content: Text("Veuillez remplir tous les champs")),
                    );
                  return;
                }

                // Compare with obligation date
                final obligationDate = widget.obligation.date; // DateTime
                if (selectedDate.isBefore(obligationDate)) {
                  ScaffoldMessenger.of(scaffoldContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                          content: Text(
                              "La date du versement ne peut pas être antérieure à la date de l'obligation")),
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

                try {
                  final newTranche = await _trancheService
                      .createTranche(obligationId, emprunteurId, amount,
                          selectedDate.toIso8601String(),
                          filePath: _controller.obligation.file)
                      .timeout(const Duration(seconds: 10));

                  setStateDialog(() => _isLoading = false);

                  if (newTranche != null) {
                    if (newTranche.status == 'validée') {
                      int newAmount = amount.toInt();
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
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Sauvegarder",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
        title: Text("${tranche.amount} "),
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
        centerTitle: true, // ✅ centers the title
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
            if (obligation.fileUrl != null && obligation.fileUrl!.isNotEmpty)
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
                          child: SizedBox(
                            width: 300, // fixed width
                            height: 400, // fixed height
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      downloadUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
            buildLabeledField("Date de remboursement au plus tard",
                obligation.dateStartDisplay ?? ""),
            buildLabeledField(
              "Montant initial",
              "${obligation.amount} ${obligation.currency}",
            ),
            buildLabeledField("Montant restant",
                "${obligation.remainingAmount} ${obligation.currency}"),
            buildLabeledField("Note", obligation.note),

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
                "Aucun versement pour le moment.",
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
                        title: Row(
                          children: [
                            Text("Versement $i "),
                            Text(
                              tranche.status,
                              style: TextStyle(
                                color: tranche.status == "en attente"
                                    ? Colors.orange
                                    : tranche.status == "validée"
                                        ? Colors.green
                                        : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          "${tranche.amount.toStringAsFixed(0)} ${obligation.currency} le ${DateFormat('dd-MM-yyyy').format(DateTime.parse(tranche.paidAt))}",
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await showDetailVersementDialog(
                              context: context,
                              id: tranche.id,
                              date: widget.obligation.dateDisplay.toString(),
                              montant: tranche.amount,
                              paidAt: tranche.paidAt,
                              photo: tranche.fileUrl,
                              status: tranche.status,
                              emprunteurId: 1,
                              onDelete: (int id) async {
                                // Find the tranche to delete
                                final index =
                                    _tranches.indexWhere((t) => t.id == id);
                                if (index == -1) return false; // not found

                                final tranche = _tranches[index];

                                // Delete from backend
                                await _trancheService
                                    .deleteTranche(id)
                                    .timeout(const Duration(seconds: 10));

                                setState(() {
                                  // Update remainingAmount if tranche was validated
                                  if (tranche.status == 'validée') {
                                    widget.obligation.remainingAmount =
                                        ((widget.obligation.remainingAmount ??
                                                    0) +
                                                tranche.amount)
                                            .toInt();
                                  }

                                  // Remove from local list
                                  _tranches.removeAt(index);
                                });

                                // Trigger callback
                                await widget.onTrancheAdded?.call();

                                return true;
                              },
                              onUpdate: ({
                                required int trancheId,
                                required double amount,
                                required String paidAt,
                                required String status,
                                required int emprunteurId,
                                String? filePath,
                              }) async {
                                await _trancheService.updateTranche(
                                  trancheId: trancheId,
                                  amount: amount,
                                  paidAt: paidAt,
                                  status: status,
                                  emprunteurId: emprunteurId,
                                );
                                // Update local list
                                setState(() {
                                  final index = _tranches
                                      .indexWhere((t) => t.id == trancheId);
                                  if (index != -1) {
                                    final oldAmount = _tranches[index].amount;
                                    _tranches[index] =
                                        _tranches[index].copyWith(
                                      amount: amount,
                                      paidAt: paidAt,
                                      status: status,
                                    );

                                    // Update remaining amount based on difference
                                    if (status == 'validée') {
                                      widget.obligation.remainingAmount =
                                          ((widget.obligation.remainingAmount ??
                                                      0) +
                                                  oldAmount -
                                                  amount)
                                              .toInt(); // <- cast to int
                                    }
                                  }
                                });
                                await widget.onTrancheAdded?.call();
                                await _loadTranches();

                                return true;
                              },
                            );
                          },
                          child: const Text(
                            "voir details",
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
                onPressed: () => _showAddTrancheDialog(
                    date: widget.obligation.dateDisplay.toString()),
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

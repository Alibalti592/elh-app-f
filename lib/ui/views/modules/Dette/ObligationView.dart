import 'package:elh/services/TrancheService.dart';
import 'package:elh/ui/widgets/Upload_file_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/models/Obligation.dart';
import 'package:elh/models/Tranche.dart';
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

  // We just use this controller as a holder for the picked file path.
  final AddObligationController _controller =
      AddObligationController('onm', Obligation());

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

    final outerContext = context; // use this for SnackBars

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
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
                      "Montant de la tranche",
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
                          borderRadius: BorderRadius.circular(6),
                        ),
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

                // Date + Upload
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date",
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
                        final pickedDate = await showDatePicker(
                          context: dialogCtx,
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
                          borderRadius: BorderRadius.circular(6),
                        ),
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
                    const SizedBox(height: 15),

                    // Attach file (stores local path in _controller.obligation.file)
                    UploadFileWidget(controller: _controller),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(😎,
                ),
              ),
              onPressed: () async {
                if (_isLoading) return;

                final amountText = _amountController.text.trim();
                final dateText = _dateController.text.trim();

                if (amountText.isEmpty || dateText.isEmpty) {
                  ScaffoldMessenger.of(outerContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                        content: Text("Veuillez remplir tous les champs")));
                  return;
                }

                final amount = double.tryParse(amountText);
                if (amount == null) {
                  ScaffoldMessenger.of(outerContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                        const SnackBar(content: Text("Montant invalide")));
                  return;
                }

                final obligationId = widget.obligation.id;
                final emprunteurId = widget.obligation.getEmprunteurId();

                if (obligationId == null || emprunteurId == null) {
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    const SnackBar(
                      content: Text("Obligation ou emprunteur invalide"),
                    ),
                  );
                  return;
                }

                setStateDialog(() => _isLoading = true);

                try {
                  final newTranche = await _trancheService
                      .createTranche(
                        obligationId,
                        emprunteurId,
                        amount,
                        dateText,
                        // IMPORTANT: pass the local file path for multipart
                        filePath: _controller.obligation.file,
                      )
                      .timeout(const Duration(seconds: 15));

                  setStateDialog(() => _isLoading = false);

                  if (newTranche != null) {
                    if (mounted) {
                      setState(() => _tranches.add(newTranche));
                    }
                    await widget.onTrancheAdded?.call();
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(outerContext)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                          content: Text("Tranche ajoutée avec succès !")));
                  } else {
                    ScaffoldMessenger.of(outerContext)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                          content: Text("Erreur lors de l'ajout de la tranche")));
                  }
                } catch (e) {
                  setStateDialog(() => _isLoading = false);
                  ScaffoldMessenger.of(outerContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text("Erreur réseau : $e")));
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

  @override
  Widget build(BuildContext context) {
    final obligation = widget.obligation;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Details", style: TextStyle(color: Colors.white)),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            )
          ],
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
                    borderRadius: BorderRadius.circular(😎,
                  ),
                ),
                onPressed: () async {
                  if (obligation.fileUrl != null &&
                      obligation.fileUrl!.isNotEmpty) {
                    try {
                      final ref =
                          FirebaseStorage.instance.refFromURL(obligation.fileUrl!);
                      final downloadUrl = await ref.getDownloadURL();
                      if (!mounted) return;
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
                                    errorBuilder: (context, , _) {
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
                                const SizedBox(height: 😎,
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Fermer"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } catch (_) {
                      if (!mounted) return;
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
                  "Preuve(s) attaché(es)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Details
              _buildDetailItem(Icons.person, "Préteur",
                  "${obligation.preteurName} (${obligation.preteurNum})"),
              _buildDetailItem(Icons.person_outline, "Emprunteur",
                  "${obligation.firstname} (${obligation.lastname} ${obligation.emprunteurNum})"),
              _buildDetailItem(Icons.event, "Date", obligation.dateDisplay),
              _buildDetailItem(Icons.schedule, "Date remboursement au plus tard",
                  obligation.dateStartDisplay ?? ""),
              _buildDetailItem(Icons.attach_money, "Montant initial",
                  "${obligation.amount}${obligation.currency}"),
              _buildDetailItem(Icons.account_balance_wallet, "Montant restant",
                  "${obligation.remainingAmount}${obligation.currency}"),
              _buildDetailItem(Icons.note, "Note", obligation.raison),

              const SizedBox(height: 16),

              const Text(
                "Déjà rendu :",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color.fromRGBO(55, 65, 81, 1),
                ),
              ),
              const SizedBox(height: 6),
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
                        leading: Icon(MdiIcons.cash, color: Colors.green),
                        title: Text("Tranche $i"),
                        subtitle: Text(
                            "${tranche.amount} ${obligation.currency} le ${tranche.paidAt}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(😎,
                            ),
                          ),
                          
                          onPressed: () async {
                            if (tranche.fileUrl != null &&
                                tranche.fileUrl!.isNotEmpty) {
                              try {
                                final ref = FirebaseStorage.instance
                                    .refFromURL(tranche.fileUrl!);
                                final downloadUrl = await ref.getDownloadURL();
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
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
                                              errorBuilder:
                                                  (context, error, stackTrace) {
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
                                          const SizedBox(height: 😎,
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
                              } catch (_) {
                                if (!mounted) return;
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
                          ),
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
                      ),
                    );
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
                      borderRadius: BorderRadius.circular(6,
                    ),
                  ),
                  ),
                  child: const Text(
                    "Ajouter un versement",
                    style: TextStyle(
                      fontSize: 20,
                      color: white,
                      fontFamily: 'inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
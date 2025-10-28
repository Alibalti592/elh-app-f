import 'dart:convert';
import 'dart:math';
import 'package:elh/ui/views/modules/Dette/AddObligationView.dart';
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
import 'package:elh/locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:elh/repository/DetteRepository.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/ui/views/modules/Relation/SelectContactView.dart';
import 'package:elh/models/Relation.dart';
import 'package:elh/ui/views/modules/Dette/AddObligationView.dart';
import 'package:elh/ui/views/modules/Dette/ObligationCard.dart';
import 'package:elh/ui/views/common/popupCard/HeroDialogRoute.dart';

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
  final DetteRepository _detteRepository = locator<DetteRepository>();
  final ErrorMessageService _errorMessageService =
      locator<ErrorMessageService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();

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

  Future<void> _editObligation() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddObligationView(
          widget.obligation.type,
          obligation: widget.obligation,
        ),
      ),
    );
    if (result == true) {
      await widget.onTrancheAdded?.call();
      await _loadTranches();
      setState(() {});
    }
  }

  Future<void> _downloadObligationCard() async {
    // Exact same UX as DetteController.openObligationCard(...)
    Navigator.of(context).push(
      HeroDialogRoute(
        builder: (context) => Center(
          child: ObligationCard(
            obligation: widget.obligation,
            directShare: true, // same flag used in DetteView
          ),
        ),
      ),
    );
  }

  Future<void> _deleteObligation() async {
    String title = "Supprimer la dette ?";
    String descr =
        "Confirmer la supression de cette dette pour toi et pour la personne associée à cette dette";
    if (widget.obligation.type == 'onm') {
      title = "Supprimer le prêt ?";
      descr =
          "Confirmer la supression de ce prêt pour toi et pour la personne associée à ce prêt";
    } else if (widget.obligation.type == 'amana') {
      title = "Supprimer l’amana ?";
      descr =
          "Confirmer la supression de cette amana pour toi et pour la personne associée à cette amana";
    }

    final confirm = await _dialogService.showConfirmationDialog(
      title: title,
      description: descr,
      cancelTitle: 'Annuler',
      confirmationTitle: 'Supprimer',
    );
    if (confirm?.confirmed == true) {
      try {
        final res = await _detteRepository.deleteDette(widget.obligation.id);
        if (res.status == 200) {
          // Go back and notify list to refresh
          await widget.onTrancheAdded?.call();
          if (mounted) Navigator.of(context).pop(true);
        } else {
          _errorMessageService.errorDefault();
        }
      } catch (_) {
        _errorMessageService.errorOnAPICall();
      }
    }
  }

  Future<void> _toggleRefund() async {
    final isRefunded = widget.obligation.status == 'refund';
    final confirm = await _dialogService.showConfirmationDialog(
      title: isRefunded
          ? "Annuler le remboursement ?"
          : "Marquer comme remboursé ?",
      description: isRefunded
          ? "Confirmer l'annulation du remboursement de cette obligation"
          : "Confirmer le remboursement de cette obligation",
      cancelTitle: 'Annuler',
      confirmationTitle: 'Valider',
    );
    if (confirm?.confirmed == true) {
      try {
        final res = await _detteRepository.refundDette(
            widget.obligation.id, isRefunded);
        if (res.status == 200) {
          await widget.onTrancheAdded?.call();
          await _loadTranches();
          setState(() {
            widget.obligation.status = isRefunded ? 'processing' : 'refund';
          });
        } else {
          _errorMessageService.errorDefault();
        }
      } catch (_) {
        _errorMessageService.errorOnAPICall();
      }
    }
  }

  Future<void> _addRelatedTo() async {
    final confirm = await _dialogService.showConfirmationDialog(
      title: "",
      description:
          "Les partages d'un PRÊT/DETTE/AMANA avec un de vos contact MC seront automatiquement visibles sur son compte Muslim Connect",
      cancelTitle: 'Annuler',
      confirmationTitle: 'Partager',
    );
    if (confirm?.confirmed == true) {
      final value = await _navigationService.navigateWithTransition(
        SelectContactView(),
        transitionStyle: Transition.downToUp,
        duration: const Duration(milliseconds: 300),
      );
      if (value is Relation) {
        try {
          final res = await _detteRepository.setRelatedTo(
            widget.obligation.id,
            value.user.id,
          );
          if (res.status == 200) {
            await widget.onTrancheAdded?.call();
            setState(() {
              widget.obligation.isRelatedToUser = true;
            });
          } else {
            _errorMessageService.errorDefault();
          }
        } catch (_) {
          _errorMessageService.errorOnAPICall();
        }
      }
    }
  }

  Future<void> _goToEditObligation() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddObligationView(
          widget.obligation.type,
          obligation: widget.obligation,
        ),
        fullscreenDialog: false, // or true if you want iOS "modal" look
      ),
    );

    // If the edit view returns true after save, refresh parent state
    if (result == true) {
      await widget.onTrancheAdded?.call();
      await _loadTranches();
      setState(() {});
    }
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
    print("Obligation : ${widget.obligation.toJson()}");
    // 🔔 Banner d'erreur affiché SOUS le titre
    String? _bannerError; // null => rien à afficher

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ajouter un versement",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(55, 65, 81, 1),
                ),
              ),
              if (_bannerError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _bannerError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
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
                      onChanged: (_) {
                        // efface le message dès que l'utilisateur retape
                        if (_bannerError != null) {
                          setStateDialog(() => _bannerError = null);
                        }
                      },
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
                          setStateDialog(() => _selectedDate = pickedDate);

                          // Display for user
                          _dateController.text =
                              "${pickedDate.day.toString().padLeft(2, '0')}/"
                              "${pickedDate.month.toString().padLeft(2, '0')}/"
                              "${pickedDate.year}";

                          // efface l'éventuel message
                          if (_bannerError != null) {
                            setStateDialog(() => _bannerError = null);
                          }
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
                  setStateDialog(
                      () => _bannerError = "Veuillez remplir tous les champs");
                  return;
                }

                // Compare with obligation date
                final obligationDate = widget.obligation.date; // DateTime
                if (selectedDate.isBefore(obligationDate)) {
                  setStateDialog(() => _bannerError =
                      "La date du versement ne peut pas être antérieure à la date de l'obligation");
                  return;
                }

                final amount = double.tryParse(amountText);
                final ObligationAmount = widget.obligation.amount;
                final ObligationRemainingAmount =
                    widget.obligation.remainingAmount ?? 0;
                if (amount == null) {
                  setStateDialog(() => _bannerError = "Montant invalide");
                  return;
                }
                if (amount > ObligationRemainingAmount) {
                  setStateDialog(() => _bannerError =
                      "Le montant du versement dépasse le montant restant à rembourser");
                  return;
                }
                setStateDialog(() {
                  _bannerError = null; // clear
                  _isLoading = true;
                });

                final obligationId = widget.obligation.id;
                final emprunteurId = widget.obligation.getEmprunteurId();

                try {
                  final newTranche = await _trancheService
                      .createTranche(
                        obligationId,
                        emprunteurId,
                        amount,
                        selectedDate.toIso8601String(),
                        filePath: _controller.obligation.file,
                      )
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

                    // succès : on ferme la boîte de dialogue directement
                    Navigator.pop(context);
                  } else {
                    setStateDialog(() =>
                        _bannerError = "Erreur lors de l'ajout de la tranche");
                  }
                } catch (e) {
                  setStateDialog(() => _bannerError = "Erreur réseau : $e");
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
        actions: [
          PopupMenuButton<String>(
            elevation: 3,
            offset: const Offset(0, 35),
            icon: Icon(MdiIcons.dotsVerticalCircleOutline, color: Colors.white),
            itemBuilder: (BuildContext context) {
              final items = <PopupMenuEntry<String>>[];

              // Download (always visible if there’s something to download)

              items.add(
                PopupMenuItem<String>(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(MdiIcons.download),
                      const SizedBox(width: 8),
                      const Text("Télécharger"),
                    ],
                  ),
                ),
              );

              // Refund toggle
              items.add(
                PopupMenuItem<String>(
                  value: 'refundObligation',
                  child: Row(
                    children: [
                      Icon(widget.obligation.status == 'refund'
                          ? MdiIcons.close
                          : MdiIcons.check),
                      const SizedBox(width: 8),
                      Text(widget.obligation.status == 'refund'
                          ? "Annuler le remboursement"
                          : "Marquer comme remboursé"),
                    ],
                  ),
                ),
              );

              // Share to member
              if (!widget.obligation.isRelatedToUser) {
                items.add(
                  PopupMenuItem<String>(
                    value: 'addRelatedTo',
                    child: Row(
                      children: [
                        Icon(MdiIcons.shareOutline),
                        const SizedBox(width: 8),
                        const Text("Partager à un membre MC"),
                      ],
                    ),
                  ),
                );
              }

              // Edit / Delete (only when allowed)
              if (widget.obligation.canEdit) {
                items.add(
                  PopupMenuItem<String>(
                    value: 'deleteObligation',
                    child: Row(
                      children: [
                        Icon(MdiIcons.trashCanOutline),
                        const SizedBox(width: 8),
                        const Text("Supprimer"),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
            onSelected: (val) async {
              switch (val) {
                case 'deleteObligation':
                  await _deleteObligation();
                  break;
                case 'refundObligation':
                  await _toggleRefund();
                  break;
                case 'download':
                  await _downloadObligationCard();
                  break;
                case 'addRelatedTo':
                  await _addRelatedTo();
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.obligation.canEdit &&
                    widget.obligation.status != 'refund')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: elhV2Color2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _goToEditObligation,
                    child: const Text(
                      "Modifier",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

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
            buildLabeledField("En date du", obligation.dateDisplay),
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
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${tranche.amount.toStringAsFixed(0)} ${obligation.currency} le ${DateFormat('dd-MM-yyyy').format(DateTime.parse(tranche.paidAt))}",
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tranche.status == "en attente"
                                  ? "En attente de validation par le prêteur"
                                  : tranche.status == "validée"
                                      ? "Validée"
                                      : "Annulée",
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
                                // find current local tranche
                                final index = _tranches
                                    .indexWhere((t) => t.id == trancheId);
                                if (index == -1) return false;
                                final current = _tranches[index];

                                // detect if only image changed (amount, paidAt, status equal old ones)
                                final isOnlyPicture = filePath != null &&
                                    amount == current.amount &&
                                    (paidAt == current.paidAt ||
                                        paidAt == (current.paidAt ?? '')) &&
                                    status == current.status;

                                // call service using nulls for unchanged fields (service now accept nullable)
                                final updatedTranche =
                                    await _trancheService.updateTranche(
                                  trancheId: trancheId,
                                  amount: isOnlyPicture ? null : amount,
                                  paidAt: isOnlyPicture ? null : paidAt,
                                  status: isOnlyPicture ? null : status,
                                  emprunteurId: emprunteurId,
                                  filePath: filePath,
                                );

                                if (updatedTranche == null) return false;

                                // update local list: if only picture -> update fileUrl only, otherwise update fields
                                setState(() {
                                  final oldAmount = current.amount;
                                  if (isOnlyPicture) {
                                    _tranches[index] =
                                        _tranches[index].copyWith(
                                      fileUrl: updatedTranche.fileUrl ??
                                          current.fileUrl,
                                    );
                                  } else {
                                    _tranches[index] =
                                        _tranches[index].copyWith(
                                      amount: updatedTranche.amount ?? amount,
                                      paidAt: updatedTranche.paidAt ?? paidAt,
                                      status: updatedTranche.status ?? status,
                                      fileUrl: updatedTranche.fileUrl ??
                                          current.fileUrl,
                                    );

                                    // update obligation.remainingAmount if needed (preserve your existing logic)
                                    if (status == 'validée') {
                                      widget.obligation.remainingAmount =
                                          ((widget.obligation.remainingAmount ??
                                                      0) +
                                                  oldAmount -
                                                  amount)
                                              .toInt();
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

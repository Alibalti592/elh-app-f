import 'dart:io';
import 'package:elh/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

Future<void> showDetailVersementDialog({
  required BuildContext context,
  required int id,
  required double montant,
  required String paidAt,
  required String date,
  required String status,
  String? photo,
  required Future<bool> Function(int id) onDelete,
  required Future<bool> Function({
    required int trancheId,
    required double amount,
    required String paidAt,
    required String status,
    required int emprunteurId,
    String? filePath, // allow passing picked file
  }) onUpdate,
  int emprunteurId = 1,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => DetailVersementDialog(
      id: id,
      montant: montant,
      paidAt: paidAt,
      date: date,
      photo: photo,
      status: status,
      onDelete: onDelete,
      onUpdate: onUpdate,
      emprunteurId: emprunteurId,
    ),
  );
}

class DetailVersementDialog extends StatefulWidget {
  final int id;
  final double montant;
  final String paidAt;
  final String date;
  final String status;
  final String? photo;
  final Future<bool> Function(int id) onDelete;
  final Future<bool> Function({
    required int trancheId,
    required double amount,
    required String paidAt,
    required String status,
    required int emprunteurId,
    String? filePath,
  }) onUpdate;
  final int emprunteurId;

  const DetailVersementDialog({
    Key? key,
    required this.id,
    required this.montant,
    required this.paidAt,
    required this.date,
    this.photo,
    required this.status,
    required this.onDelete,
    required this.onUpdate,
    required this.emprunteurId,
  }) : super(key: key);

  @override
  State<DetailVersementDialog> createState() => _DetailVersementDialogState();
}

class _DetailVersementDialogState extends State<DetailVersementDialog> {
  late final TextEditingController amountController;
  late final TextEditingController dateController;

  late final String origAmount;
  late final String origDate;

  bool isChanged = false;
  bool isLoading = false;

  File? pickedImage; // user-selected image
  final ImagePicker _picker = ImagePicker();

  void _listener() {
    final changed = amountController.text.trim() != origAmount ||
        dateController.text.trim() != origDate ||
        pickedImage != null; // detect image change
    if (changed != isChanged) {
      setState(() {
        isChanged = changed;
      });
    }
  }

  final dateFormatDisplay = DateFormat('dd-MM-yyyy');
  final dateFormatIso = DateFormat('yyyy-MM-dd');

  DateTime? tryParseAnyDate(String? s) {
    if (s == null || s.isEmpty) return null;
    // Try DateTime.tryParse (handles ISO like 2025-10-24T00:00:00.000)
    final p = DateTime.tryParse(s);
    if (p != null) return p;
    // Try common formats you might receive
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(s);
    } catch (_) {}
    try {
      return DateFormat('yyyy-MM-dd').parseStrict(s);
    } catch (_) {}
    return null;
  }

  @override
  void initState() {
    super.initState();

    _selectedDate = tryParseAnyDate(widget.paidAt);

    final amount = widget.montant;
    amountController = TextEditingController(
      text: (amount % 1 == 0) ? amount.toInt().toString() : amount.toString(),
    );

    // Format the date properly for display (dd-MM-yyyy)
    String displayDate;
    if (_selectedDate != null) {
      displayDate = dateFormatDisplay.format(_selectedDate!);
    } else {
      displayDate = widget.paidAt; // fallback to raw string
    }

    dateController = TextEditingController(text: displayDate);

    // Save originals for change detection
    origAmount = amountController.text;
    origDate = displayDate;

    // Listeners
    amountController.addListener(_listener);
    dateController.addListener(_listener);
  }

  @override
  void dispose() {
    amountController.removeListener(_listener);
    dateController.removeListener(_listener);
    amountController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
      _listener(); // notify dialog to enable "Mettre à jour"
    }
  }

  Future<void> _DialogDateErreur(String message) async {
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Erreur de date'),
        content: Text(message.toString()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, true), child: const Text('Ok')),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Veux-tu supprimer ce versement ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Non')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Oui')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final success = await widget.onDelete(widget.id);
      if (!mounted) return;
      setState(() => isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Versement supprimé')));
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Échec suppression')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Erreur suppression : $e')));
    }
  }

  final dateFormat = DateFormat('dd/MM/yyyy');
  DateTime? _selectedDate; // Holds the picked date internally

  Future<void> _handleUpdate() async {
    final amountText = amountController.text.trim();
    final status = widget.status;
    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }

    final DateTime obligationDate = dateFormat.parse(widget.date);

    if (_selectedDate == null) {
      try {
        _selectedDate = DateTime.tryParse(widget.paidAt);
        if (_selectedDate == null) {
          _selectedDate = dateFormat.parse(widget.paidAt);
        }
      } catch (_) {
        await _DialogDateErreur("Veuillez sélectionner une date valide");
        return;
      }
    }

    if (_selectedDate!.isBefore(obligationDate)) {
      _DialogDateErreur(
        "La date du versement ne peut pas être antérieure à la date de l'obligation",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(_selectedDate!);

      final success = await widget.onUpdate(
        trancheId: widget.id,
        amount: amount,
        paidAt: formattedDate,
        status: status,
        emprunteurId: widget.emprunteurId,
        filePath: pickedImage?.path,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Versement mis à jour')));
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Échec mise à jour')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Erreur mise à jour : $e')));
    }
  }

  String convertToFirebaseUrl(String url) {
    if (url.contains('storage.googleapis.com')) {
      final bucket = 'elhapp-78deb.firebasestorage.app';
      // Extract the path after the bucket name
      final path = url.split('$bucket/').last;
      final encodedPath = Uri.encodeComponent(path);
      return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
    }
    return url; // return as-is if already a Firebase URL or invalid
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: AlertDialog(
        // Optionnel: tu peux plafonner la largeur si tu veux
        // insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: const Text(
          "Détails du versement",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(55, 65, 81, 1),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Étire les enfants sur la largeur finie fournie par AlertDialog
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section
              if (widget.photo != null && widget.photo!.isNotEmpty)
                SizedBox(
                  height: 140,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: pickedImage != null
                            ? Image.file(
                                pickedImage!,
                                fit: BoxFit.cover,
                              )
                            : (widget.photo != null && widget.photo!.isNotEmpty
                                ? Image.network(
                                    convertToFirebaseUrl(widget.photo!),
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Text('Image non disponible'),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text("Attacher une image"),
                                    ),
                                  )),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (pickedImage != null)
                SizedBox(
                  height: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      pickedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                    ),
                    child: const Center(child: Text("Attacher une image")),
                  ),
                ),

              const SizedBox(height: 12),

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
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(229, 231, 235, 1), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
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
                    controller: dateController,
                    readOnly: true,
                    onTap: () async {
                      DateTime initial = _selectedDate ??
                          DateTime.tryParse(widget.paidAt) ??
                          DateTime.now();
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                          // show as 24-10-2025
                          dateController.text =
                              dateFormatDisplay.format(pickedDate);
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          if (!isChanged)
            TextButton(
              onPressed: isLoading ? null : _handleDelete,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Supprimer"),
            ),
          if (isChanged)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isLoading ? null : _handleUpdate,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Mettre à jour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:elh/services/TrancheService.dart';

class TrancheNotificationHandler extends StatefulWidget {
  const TrancheNotificationHandler({Key? key}) : super(key: key);

  @override
  State<TrancheNotificationHandler> createState() =>
      _TrancheNotificationHandlerState();
}

class _TrancheNotificationHandlerState
    extends State<TrancheNotificationHandler> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getToken().then((token) {
      print("🔥 FCM Token: $token");
    });
    // 🔔 Écoute des notifications FCM en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['view'] == 'tranche') {
        _showTrancheDialog(message.data);
      }
    });
  }

  // 📌 Affichage de la popup quand une notification arrive
  void _showTrancheDialog(Map<String, dynamic> data) {
    final montant = data['amount'] ?? 'N/A';
    final trancheId = data['trancheId']?.toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouvelle tranche proposée'),
          content: Text('Montant : $montant €'),
          actions: [
            TextButton(
              onPressed: () {
                if (trancheId != null) {
                  _respondTranche(trancheId, 'accept');
                }
              },
              child: const Text('Accepter'),
            ),
            TextButton(
              onPressed: () {
                if (trancheId != null) {
                  _respondTranche(trancheId, 'decline');
                }
              },
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );
  }

  // 📌 Envoi de la réponse (accepter/refuser) au backend
  void _respondTranche(String trancheId, String action) async {
    try {
      final service = TrancheService();
      final success =
          await service.respondToTranche(int.parse(trancheId), action);

      Navigator.of(context).pop(); // Ferme la popup

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Réponse envoyée avec succès ✅'
                : 'Erreur lors de la réponse ❌',
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ce widget ne dessine rien, il sert juste d’écouteur global
    return const SizedBox.shrink();
  }
}

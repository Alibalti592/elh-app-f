// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class TrancheService {
//   final String baseUrl = 'http://10.0.2.2:8000/elh-api/tranche';

//   Future<bool> respondToTranche(int trancheId, String action) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('jwtToken'); // your stored JWT

//     if (token == null) {
//       throw Exception('Utilisateur non authentifié');
//     }

//     try {
//       final res = await http.post(
//         Uri.parse('$baseUrl/respond'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'trancheId': trancheId,
//           'action': action,
//         }),
//       );

//       if (res.statusCode == 200) {
//         return true;
//       } else {
//         // Log backend error for debug
//         print("Erreur backend: ${res.statusCode} => ${res.body}");
//         return false;
//       }
//     } catch (e) {
//       print("Erreur réseau: $e");
//       return false;
//     }
//   }
// }
import 'package:elh/models/Tranche.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TrancheService {
  final String baseUrl = 'https://test.muslim-connect.fr/elh-api/tranche/tranche';
  final String baseUrl1 = 'https://test.muslim-connect.fr/elh-api/tranche';

  // -----------------------------
  // Respond to a tranche
  // -----------------------------
  Future<bool> respondToTranche(int trancheId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // consistent key

    if (token == null) throw Exception('Utilisateur non authentifié');

    try {
      final res = await http.post(
        Uri.parse('$baseUrl1/respond'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'trancheId': trancheId, 'response': action}),
      );

      if (res.statusCode == 200) return true;

      print("Erreur backend: ${res.statusCode} => ${res.body}");
      return false;
    } catch (e) {
      print("Erreur réseau: $e");
      return false;
    }
  }

  // -----------------------------
  // Fetch tranches by obligationId
  // -----------------------------
  Future<List<Tranche>> getTranches(int obligationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // consistent key

    if (token == null) throw Exception("JWT token is null IN TRANCHE SERVICE");

    final response = await http.get(
      Uri.parse('$baseUrl?obligationId=$obligationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Tranche.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tranches: ${response.body}');
    }
  }

  // -----------------------------
  // Create a new tranche
  // -----------------------------
  Future<Tranche?> createTranche(
    int obligationId,
    int emprunteurId,
    double amount,
    String paidAt, {
    String? fileUrl, // optional named parameter
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return null;

    if (obligationId <= 0 || emprunteurId <= 0) return null;

    final body = {
      'obligationId': obligationId,
      'emprunteurId': emprunteurId,
      'amount': amount,
      'paidAt': paidAt,
      if (fileUrl != null) 'fileUrl': fileUrl, // only include if not null
    };

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl1/create'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data != null && data['trancheId'] != null) {
          return Tranche.fromJson({
            'id': data['trancheId'],
            'amount': data['amount'] ?? amount,
            'status': data['status'] ?? 'en attente',
            'paidAt': paidAt,
          });
        }
      }
    } catch (e) {
      print("Erreur réseau: $e");
    }

    return null;
  }
}

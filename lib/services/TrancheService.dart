import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:elh/models/Tranche.dart';

class TrancheService {
  // Keep your existing endpoints
  final String baseUrl =
      'https://test.muslim-connect.fr/elh-api/tranche/tranche';
  final String baseUrl1 = 'https://test.muslim-connect.fr/elh-api/tranche';
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  getUserToken() async {
    String token = await _authenticationService.getUserToken();
    return token;
  }

  // -----------------------------
  // Respond to a tranche
  // -----------------------------
  Future<bool> respondToTranche(int trancheId, String action) async {
    String token = await this.getUserToken();

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

      // Debug
      // print("Erreur backend: ${res.statusCode} => ${res.body}");
      return false;
    } catch (e) {
      // print("Erreur réseau: $e");
      return false;
    }
  }

  // -----------------------------
  // Fetch tranches by obligationId
  // -----------------------------
  Future<List<Tranche>> getTranches(int obligationId) async {
    String token = await this.getUserToken();

    final response = await http.get(
      Uri.parse('$baseUrl?obligationId=$obligationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Tranche.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tranches: ${response.body}');
    }
  }

  // -----------------------------
  // Create a new tranche
  // If filePath is provided -> multipart (field "tranche" + file "file")
  // Else -> JSON body (as before)
  // -----------------------------
  Future<Tranche?> createTranche(
    int? obligationId,
    int? emprunteurId,
    double amount,
    String paidAt, {
    String? filePath, // <- pass a path to send a file
  }) async {
    String token = await this.getUserToken();
    print(token);

    // Common payload (without fileUrl; server will upload and set it)
    final Map<String, dynamic> payload = {
      'obligationId': obligationId,
      'emprunteurId': emprunteurId,
      'amount': amount,
      'paidAt': paidAt,
    };
    print(payload);

    // ---- Multipart path (with file) ----
    if (filePath != null) {
      final uri = Uri.parse('$baseUrl1/create');

      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        // Do NOT set Content-Type manually; MultipartRequest will do it.
        ..fields['tranche'] = jsonEncode(payload);

      // Attach the file as field "file"
      req.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: p.basename(filePath),
      ));

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return Tranche.fromJson({
          'id': data['trancheId'],
          'amount': data['amount'] ?? amount,
          'status': data['status'] ?? 'en attente',
          'paidAt': paidAt,
          'fileUrl': data['fileUrl'],
        });
      } else {
        // print('Failed multipart: ${res.statusCode} ${res.body}');
        return null;
      }
    }

    // ---- JSON path (no file) ----
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl1/create'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
      print(res.statusCode);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        print("la data : ${data}");
        return Tranche.fromJson({
          'id': data['trancheId'],
          'amount': data['amount'] ?? amount,
          'status': data['status'] ?? 'en attente',
          'paidAt': paidAt,
          'fileUrl': data['fileUrl'],
        });
      }
    } catch (e) {
      print("Erreur réseau: $e");
    }
    return null;
  }
}

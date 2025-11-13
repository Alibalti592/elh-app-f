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

      return false;
    } catch (e) {
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

    // Common payload (without fileUrl; server will upload and set it)
    final Map<String, dynamic> payload = {
      'obligationId': obligationId,
      'emprunteurId': emprunteurId,
      'amount': amount,
      'paidAt': paidAt,
    };

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

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

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

  // -----------------------------
  // Update a tranche
  // -----------------------------
  Future<Tranche?> updateTranche({
    required int trancheId,
    double? amount, // <-- now nullable
    String? paidAt, // <-- nullable
    String? status, // <-- nullable
    required int emprunteurId,
    String? filePath,
  }) async {
    String token = await this.getUserToken();

    // build payload including only provided fields
    final Map<String, dynamic> payload = {};
    if (amount != null) payload['amount'] = amount;
    if (paidAt != null) payload['paidAt'] = paidAt;
    if (status != null) payload['status'] = status;
    // you can include emprunteurId if you want the backend to know it; keep it always
    payload['emprunteurId'] = emprunteurId;

    // ---- Multipart path (with file) ----
    if (filePath != null) {
      final uri = Uri.parse('$baseUrl1/update/$trancheId');

      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // Add each payload key as a simple form field (string)
      payload.forEach((key, value) {
        // ensure non-null and convert to string
        if (value != null) {
          req.fields[key] = value.toString();
        }
      });

      // Add file (field name must match server: 'file')
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
          'status': data['status'] ?? status,
          'paidAt': data['paidAt'] ?? paidAt,
          'fileUrl': data['fileUrl'],
        });
      } else {
        print(
            'Erreur updateTranche (multipart): ${res.statusCode} ${res.body}');
        return null;
      }
    }

    // ---- JSON path (no file) ----
    try {
      final res = await http
          .put(
            Uri.parse('$baseUrl1/update/$trancheId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return Tranche.fromJson({
          'id': data['trancheId'],
          'amount': data['amount'] ?? amount,
          'status': data['status'] ?? status,
          'paidAt': paidAt ?? data['paidAt'],
          'fileUrl': data['fileUrl'],
        });
      }
    } catch (e) {
      print("Erreur réseau updateTranche: $e");
    }

    return null;
  }

  // -----------------------------
  // Delete a tranche
  // -----------------------------
  Future<bool> deleteTranche(int trancheId) async {
    String token = await this.getUserToken();

    try {
      final res = await http.delete(
        Uri.parse('$baseUrl1/delete/$trancheId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('Erreur deleteTranche: $e');
      return false;
    }
  }
}

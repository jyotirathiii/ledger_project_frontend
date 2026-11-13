import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ledger_project/config.dart';
import 'package:ledger_project/services/session.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/signup');
    final response = await http.post(
      url,
      headers: {'content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getBalance() async {
    final url = Uri.parse('$baseUrl/balance/me');
    final response = await (http.get(
      url,
      headers: {'Authorization': 'Bearer ${Session.token}'},
    ));
    return jsonDecode(response.body);
  }

  static Future<dynamic> getHistory() async {
    final url = Uri.parse('$baseUrl/history/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${Session.token}'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> transfer(
    int toId,
    double amount,
    String idempotencyKey,
  ) async {
    final url = Uri.parse('$baseUrl/transfer');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token}',
        'Idempotency-key': idempotencyKey,
      },
      body: jsonEncode({'to_id': toId, 'amount': amount}),
    );
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = {'detail': 'Server error (${response.statusCode})'};
    }
    data['statusCode'] = response.statusCode;
    return data;
  }

  static Future<Map<String, dynamic>> refund(
    int tranferId,
    double amount,
    String idemKey,
  ) async {
    final url = Uri.parse('$baseUrl/refund');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token}',
        'Idempotency-Key': idemKey,
      },
      body: jsonEncode({'transfer_id': tranferId, 'amount': amount}),
    );

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = {'detail': 'server error (${response.statusCode})'};
    }
    data['statusCode'] = response.statusCode;
    return data;
  }
}

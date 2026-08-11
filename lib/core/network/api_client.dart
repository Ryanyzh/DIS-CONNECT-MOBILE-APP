import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

// Environment enum to switch between local, local device, and deployed backend URLs.
enum _Env { local, localDevice, deployed }

class ApiClient {
  static const _Env _env = _Env.deployed;

  // Simulator  → local uvicorn on localhost
  static const String _localUrl = 'http://127.0.0.1:8000';

  // Real device → replace with your Mac's LAN IP (run: ipconfig getifaddr en0)
  static const String _localDeviceUrl = 'http://192.168.1.14:8000';

  // Firebase Functions — the function is named "api", so Firebase strips that
  // prefix from req.path. Appending /api/v1/... makes req.path = /api/v1/...
  // which matches the FastAPI routes defined in functions/app/main.py.
  static const String _deployedUrl =
      'https://asia-southeast1-orbital-dis-connect.cloudfunctions.net/api';

  static String get baseUrl {
    switch (_env) {
      case _Env.local:
        return _localUrl;
      case _Env.localDevice:
        return _localDeviceUrl;
      case _Env.deployed:
        return _deployedUrl;
    }
  }

  // Returns a map of headers including the Firebase ID token for authentication.
  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET request to the backend API. Throws an exception for non-2xx responses.
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception('GET $endpoint failed: ${response.statusCode}');
  }

  // POST request to the backend API. Throws an exception for non-2xx responses.
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception('POST $endpoint failed: ${response.statusCode}');
  }
}

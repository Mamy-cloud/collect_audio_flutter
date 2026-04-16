import 'dart:io';
import 'package:http/http.dart' as http;

class AudioUploadService {
  // URL de l'API FastAPI — remplacez par votre URL réelle
  static const String _apiBaseUrl = 'https://votre-api.exemple.com';

  /// Upload un fichier audio vers FastAPI
  /// Retourne l'URL publique du fichier ou null en cas d'erreur
  static Future<String?> uploadAudio(String localPath, int temoinId) async {
    try {
      final file    = File(localPath);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/temoins/$temoinId/audio'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        file.path,
      ));

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = await response.stream.bytesToString();
        // FastAPI retourne {"url": "..."} — adaptez selon votre API
        return body;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si un fichier audio existe localement
  static bool exists(String? path) {
    if (path == null) return false;
    return File(path).existsSync();
  }
}

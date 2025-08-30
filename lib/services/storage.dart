import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static const String historyFolder = 'sellbetter_history';
  static const String cacheFolder = 'sellbetter_cache';
  static const String settingsFile = 'settings.json';

  static Future<Directory> _getHistoryDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final historyDir = Directory(path.join(docDir.path, historyFolder));
    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }
    return historyDir;
  }

  static Future<Directory> _getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory(path.join(tempDir.path, cacheFolder));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  static Future<File> saveToHistory(File sourceFile, String photoId) async {
    try {
      final historyDir = await _getHistoryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${photoId}_$timestamp${path.extension(sourceFile.path)}';
      final destinationPath = path.join(historyDir.path, fileName);
      return await sourceFile.copy(destinationPath);
    } catch (e) {
      throw Exception('Failed to save to history: $e');
    }
  }

  static Future<List<File>> getHistoryFiles() async {
    try {
      final historyDir = await _getHistoryDirectory();
      final files = await historyDir.list().toList();
      return files
          .whereType<File>()
          .where((file) => _isImageFile(file.path))
          .toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearHistory() async {
    try {
      final historyDir = await _getHistoryDirectory();
      if (await historyDir.exists()) {
        await historyDir.delete(recursive: true);
        await historyDir.create();
      }
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }

  static Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final settingsPath = path.join(docDir.path, settingsFile);
      final file = File(settingsPath);
      await file.writeAsString(jsonEncode(settings));
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadSettings() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final settingsPath = path.join(docDir.path, settingsFile);
      final file = File(settingsPath);
      
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static bool _isImageFile(String filePath) {
    final extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final ext = path.extension(filePath).toLowerCase();
    return extensions.contains(ext);
  }

  static Future<File?> getCachedFile(String key) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final filePath = path.join(cacheDir.path, key);
      final file = File(filePath);
      
      if (await file.exists()) {
        final stat = await file.stat();
        final age = DateTime.now().difference(stat.modified);
        
        if (age.inMinutes < 15) {
          return file;
        } else {
          await file.delete();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File> cacheFile(String key, File sourceFile) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final destinationPath = path.join(cacheDir.path, key);
      return await sourceFile.copy(destinationPath);
    } catch (e) {
      throw Exception('Failed to cache file: $e');
    }
  }
}
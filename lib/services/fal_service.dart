import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../state/models.dart';

class FalService {
  final Dio _dio;
  final String baseUrl;
  String? _accessToken;
  DateTime? _tokenExpiry;

  FalService({
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = baseUrl ?? const String.fromEnvironment('FAL_PROXY_URL', defaultValue: 'https://api.example.com'),
        _dio = dio ?? Dio();

  Future<String> _getAccessToken() async {
    if (_accessToken != null && 
        _tokenExpiry != null && 
        _tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return _accessToken!;
    }

    try {
      final response = await _dio.post(
        '$baseUrl/v1/token',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['token'];
        _tokenExpiry = DateTime.now().add(const Duration(minutes: 25));
        return _accessToken!;
      } else {
        throw Exception('Failed to get access token');
      }
    } catch (e) {
      throw Exception('Token fetch failed: $e');
    }
  }

  Future<File> polishImage({
    required File inputImage,
    required ProductCategory category,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final token = await _getAccessToken();
      
      final prompt = _getPromptForCategory(category);
      
      final bytes = await inputImage.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await _dio.post(
        'https://fal.run/gemini-image-edit',
        data: {
          'prompt': prompt,
          'image': base64Image,
          'variants': 1,
          'size': 'original',
          ...?additionalParams,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final imageData = response.data['image'];
        
        File processedFile;
        if (imageData is String && imageData.startsWith('data:')) {
          final base64Data = imageData.split(',')[1];
          final bytes = base64Decode(base64Data);
          processedFile = await _saveImageToFile(bytes);
        } else if (imageData is String && imageData.startsWith('http')) {
          processedFile = await _downloadImage(imageData);
        } else if (imageData is String) {
          final bytes = base64Decode(imageData);
          processedFile = await _saveImageToFile(bytes);
        } else {
          throw Exception('Unexpected image data format');
        }

        await _logMetrics('polish_completed', category);
        
        return processedFile;
      } else {
        throw Exception('Failed to process image: ${response.statusCode}');
      }
    } catch (e) {
      await _logMetrics('polish_failed', category);
      throw Exception('Image processing failed: $e');
    }
  }

  Future<File> _saveImageToFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/processed_$timestamp.jpg');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<File> _downloadImage(String url) async {
    final response = await _dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return _saveImageToFile(response.data);
  }

  Future<void> _logMetrics(String event, ProductCategory category) async {
    try {
      await _dio.post(
        '$baseUrl/v1/metrics',
        data: {
          'event': event,
          'count': 1,
          'platform': Platform.operatingSystem,
          'category': category.name,
        },
      );
    } catch (e) {
      print('Metrics logging failed: $e');
    }
  }

  String _getPromptForCategory(ProductCategory category) {
    const basePrompt = '''Goal: make this product photo listing-ready without deception.
• Preserve product geometry, textures, brand markings.
• Replace background with a neutral light gray (studio sweep).
• Correct lighting/white balance; reduce glare; keep true color.
• Remove objects not part of the product (hands, clutter, cables).
• Add a soft, physically plausible contact shadow.
• Do NOT invent accessories or change the product's shape.''';

    switch (category) {
      case ProductCategory.furniture:
        return '''$basePrompt
As Base, plus:
• Correct perspective so verticals are vertical; eye-level feel.
• Retain wood grain/fabric texture; subtle finish sheen.''';
      
      case ProductCategory.shoes:
        return '''$basePrompt
As Base, plus:
• Remove lint/loose threads; keep natural creasing.
• Slight edge contrast for outlines; avoid plastic look.''';
      
      case ProductCategory.electronics:
        return '''$basePrompt
As Base, plus:
• Reduce screen glare while keeping screen readable.
• No invented ports/buttons; remove fingerprints.''';
      
      case ProductCategory.cars:
        return '''$basePrompt
As Base, plus:
• Even daylight; reduce harsh reflections; keep paint texture.
• Remove license plate text; keep blank placeholder plate.''';
      
      case ProductCategory.general:
      default:
        return basePrompt;
    }
  }
}
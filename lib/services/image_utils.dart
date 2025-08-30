import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static const int defaultMaxSize = 3072;
  static const int exportMaxSize = 1536;
  static const int defaultQuality = 90;

  static Future<File> processForUpload(
    File inputFile, {
    int maxSize = defaultMaxSize,
  }) async {
    final bytes = await inputFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    image = _fixOrientation(image);
    
    if (image.width > maxSize || image.height > maxSize) {
      if (image.width > image.height) {
        image = img.copyResize(image, width: maxSize);
      } else {
        image = img.copyResize(image, height: maxSize);
      }
    }

    image = _stripExifData(image);

    final processedBytes = img.encodeJpg(image, quality: defaultQuality);
    return _saveToTempFile(processedBytes, 'upload');
  }

  static Future<File> processForExport(
    File inputFile, {
    int maxSize = exportMaxSize,
    int quality = defaultQuality,
    bool addWatermark = false,
    bool addAIBadge = false,
  }) async {
    final bytes = await inputFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    if (image.width > maxSize || image.height > maxSize) {
      if (image.width > image.height) {
        image = img.copyResize(image, width: maxSize);
      } else {
        image = img.copyResize(image, height: maxSize);
      }
    }

    if (addWatermark) {
      image = _addWatermark(image);
    }

    if (addAIBadge) {
      image = _addAIBadge(image);
    }

    image = _stripExifData(image);

    final processedBytes = img.encodeJpg(image, quality: quality);
    
    if (processedBytes.length > 1500000) {
      final lowerQuality = (quality * 0.85).round();
      return processForExport(
        inputFile,
        maxSize: maxSize,
        quality: lowerQuality,
        addWatermark: addWatermark,
        addAIBadge: addAIBadge,
      );
    }

    return _saveToTempFile(processedBytes, 'export');
  }

  static Future<File> createSquareCrop(File inputFile) async {
    final bytes = await inputFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final size = image.width < image.height ? image.width : image.height;
    final x = (image.width - size) ~/ 2;
    final y = (image.height - size) ~/ 2;
    
    image = img.copyCrop(image, x: x, y: y, width: size, height: size);
    
    final processedBytes = img.encodeJpg(image, quality: defaultQuality);
    return _saveToTempFile(processedBytes, 'square');
  }

  static Future<File> create4x3Crop(File inputFile) async {
    final bytes = await inputFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final targetRatio = 4 / 3;
    final currentRatio = image.width / image.height;
    
    int newWidth, newHeight;
    if (currentRatio > targetRatio) {
      newHeight = image.height;
      newWidth = (image.height * targetRatio).round();
    } else {
      newWidth = image.width;
      newHeight = (image.width / targetRatio).round();
    }
    
    final x = (image.width - newWidth) ~/ 2;
    final y = (image.height - newHeight) ~/ 2;
    
    image = img.copyCrop(image, x: x, y: y, width: newWidth, height: newHeight);
    
    final processedBytes = img.encodeJpg(image, quality: defaultQuality);
    return _saveToTempFile(processedBytes, '4x3');
  }

  static img.Image _fixOrientation(img.Image image) {
    return img.bakeOrientation(image);
  }

  static img.Image _stripExifData(img.Image image) {
    image.exif.clear();
    return image;
  }

  static img.Image _addWatermark(img.Image image) {
    final watermarkText = 'SellBetter';
    final fontSize = (image.width * 0.03).round();
    
    img.drawString(
      image,
      watermarkText,
      font: img.arial24,
      x: image.width - (watermarkText.length * fontSize) - 20,
      y: image.height - fontSize - 20,
      color: img.ColorRgba8(255, 255, 255, 128),
    );
    
    return image;
  }

  static img.Image _addAIBadge(img.Image image) {
    final badgeText = 'AI-edited';
    final fontSize = (image.width * 0.025).round();
    final padding = 10;
    final badgeWidth = badgeText.length * fontSize + padding * 2;
    final badgeHeight = fontSize + padding * 2;
    
    img.fillRect(
      image,
      x1: 20,
      y1: image.height - badgeHeight - 20,
      x2: 20 + badgeWidth,
      y2: image.height - 20,
      color: img.ColorRgba8(33, 150, 243, 200),
    );
    
    img.drawString(
      image,
      badgeText,
      font: img.arial24,
      x: 20 + padding,
      y: image.height - badgeHeight - 20 + padding,
      color: img.ColorRgba8(255, 255, 255, 255),
    );
    
    return image;
  }

  static Future<File> _saveToTempFile(Uint8List bytes, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = path.join(tempDir.path, '${prefix}_$timestamp.jpg');
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
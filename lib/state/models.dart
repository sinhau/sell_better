import 'dart:io';
import 'package:flutter/foundation.dart';

enum ProcessingStatus {
  idle,
  uploading,
  processing,
  completed,
  failed,
}

enum ProductCategory {
  general,
  furniture,
  shoes,
  electronics,
  cars,
}

class PhotoItem {
  final String id;
  final File originalImage;
  final File? processedImage;
  final ProcessingStatus status;
  final String? errorMessage;
  final DateTime timestamp;

  PhotoItem({
    required this.id,
    required this.originalImage,
    this.processedImage,
    this.status = ProcessingStatus.idle,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  PhotoItem copyWith({
    String? id,
    File? originalImage,
    File? processedImage,
    ProcessingStatus? status,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    return PhotoItem(
      id: id ?? this.id,
      originalImage: originalImage ?? this.originalImage,
      processedImage: processedImage ?? this.processedImage,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class AppSettings {
  final ProductCategory selectedCategory;
  final bool showAIBadge;
  final bool enableWatermark;
  final int maxImageSize;
  final int exportQuality;

  AppSettings({
    this.selectedCategory = ProductCategory.general,
    this.showAIBadge = true,
    this.enableWatermark = false,
    this.maxImageSize = 3072,
    this.exportQuality = 90,
  });

  AppSettings copyWith({
    ProductCategory? selectedCategory,
    bool? showAIBadge,
    bool? enableWatermark,
    int? maxImageSize,
    int? exportQuality,
  }) {
    return AppSettings(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showAIBadge: showAIBadge ?? this.showAIBadge,
      enableWatermark: enableWatermark ?? this.enableWatermark,
      maxImageSize: maxImageSize ?? this.maxImageSize,
      exportQuality: exportQuality ?? this.exportQuality,
    );
  }
}

class ProcessingResult {
  final String photoId;
  final File processedImage;
  final Map<String, dynamic>? metadata;
  final Duration processingTime;

  ProcessingResult({
    required this.photoId,
    required this.processedImage,
    this.metadata,
    required this.processingTime,
  });
}
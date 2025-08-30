import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/models.dart';
import '../state/providers.dart';

class PhotoTile extends ConsumerWidget {
  final PhotoItem photo;

  const PhotoTile({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBorderColor(photo.status),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              photo.originalImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (photo.status != ProcessingStatus.idle)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getStatusColor(photo.status),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(photo.status),
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        if (photo.processedImage != null)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Polished',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        Positioned(
          top: 8,
          left: 8,
          child: InkWell(
            onTap: () {
              ref.read(photosProvider.notifier).removePhoto(photo.id);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getBorderColor(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.idle:
        return Colors.grey[300]!;
      case ProcessingStatus.uploading:
      case ProcessingStatus.processing:
        return Colors.blue;
      case ProcessingStatus.completed:
        return Colors.green;
      case ProcessingStatus.failed:
        return Colors.red;
    }
  }

  Color _getStatusColor(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.idle:
        return Colors.grey;
      case ProcessingStatus.uploading:
      case ProcessingStatus.processing:
        return Colors.blue;
      case ProcessingStatus.completed:
        return Colors.green;
      case ProcessingStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.idle:
        return Icons.schedule;
      case ProcessingStatus.uploading:
        return Icons.cloud_upload;
      case ProcessingStatus.processing:
        return Icons.auto_fix_high;
      case ProcessingStatus.completed:
        return Icons.check;
      case ProcessingStatus.failed:
        return Icons.error;
    }
  }
}
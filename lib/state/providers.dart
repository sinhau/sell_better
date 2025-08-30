import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';

final photosProvider = StateNotifierProvider<PhotosNotifier, List<PhotoItem>>((ref) {
  return PhotosNotifier();
});

class PhotosNotifier extends StateNotifier<List<PhotoItem>> {
  PhotosNotifier() : super([]);
  
  final _uuid = const Uuid();

  void addPhotos(List<File> files) {
    final newPhotos = files.map((file) => PhotoItem(
      id: _uuid.v4(),
      originalImage: file,
    )).toList();
    state = [...state, ...newPhotos];
  }

  void updatePhoto(String id, PhotoItem updatedPhoto) {
    state = state.map((photo) {
      return photo.id == id ? updatedPhoto : photo;
    }).toList();
  }

  void removePhoto(String id) {
    state = state.where((photo) => photo.id != id).toList();
  }

  void clearAll() {
    state = [];
  }

  PhotoItem? getPhotoById(String id) {
    try {
      return state.firstWhere((photo) => photo.id == id);
    } catch (_) {
      return null;
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings());

  void updateCategory(ProductCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleAIBadge() {
    state = state.copyWith(showAIBadge: !state.showAIBadge);
  }

  void toggleWatermark() {
    state = state.copyWith(enableWatermark: !state.enableWatermark);
  }

  void updateMaxImageSize(int size) {
    state = state.copyWith(maxImageSize: size);
  }

  void updateExportQuality(int quality) {
    state = state.copyWith(exportQuality: quality);
  }
}

final processingProvider = StateNotifierProvider<ProcessingNotifier, AsyncValue<ProcessingResult?>>((ref) {
  return ProcessingNotifier(ref);
});

class ProcessingNotifier extends StateNotifier<AsyncValue<ProcessingResult?>> {
  final Ref ref;
  
  ProcessingNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> processPhoto(String photoId) async {
    state = const AsyncValue.loading();
    
    try {
      final photosNotifier = ref.read(photosProvider.notifier);
      final photo = photosNotifier.getPhotoById(photoId);
      
      if (photo == null) {
        throw Exception('Photo not found');
      }
      
      photosNotifier.updatePhoto(photoId, photo.copyWith(
        status: ProcessingStatus.uploading,
      ));
      
      await Future.delayed(const Duration(seconds: 2));
      
      photosNotifier.updatePhoto(photoId, photo.copyWith(
        status: ProcessingStatus.processing,
      ));
      
      await Future.delayed(const Duration(seconds: 3));
      
      final result = ProcessingResult(
        photoId: photoId,
        processedImage: photo.originalImage,
        processingTime: const Duration(seconds: 5),
      );
      
      photosNotifier.updatePhoto(photoId, photo.copyWith(
        processedImage: result.processedImage,
        status: ProcessingStatus.completed,
      ));
      
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      
      final photosNotifier = ref.read(photosProvider.notifier);
      final photo = photosNotifier.getPhotoById(photoId);
      if (photo != null) {
        photosNotifier.updatePhoto(photoId, photo.copyWith(
          status: ProcessingStatus.failed,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final anonymousIdProvider = Provider<String>((ref) {
  return const Uuid().v4();
});
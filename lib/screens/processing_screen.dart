import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/providers.dart';
import '../state/models.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String? photoId;

  const ProcessingScreen({super.key, this.photoId});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.photoId != null) {
        _startProcessing();
      }
    });
  }

  Future<void> _startProcessing() async {
    final processingNotifier = ref.read(processingProvider.notifier);
    await processingNotifier.processPhoto(widget.photoId!);
    
    if (mounted) {
      final result = ref.read(processingProvider);
      result.when(
        data: (data) {
          if (data != null) {
            context.go('/result?photoId=${widget.photoId}');
          }
        },
        loading: () {},
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Processing failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/picker');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final processingState = ref.watch(processingProvider);
    final photos = ref.watch(photosProvider);
    final currentPhoto = photos.firstWhere(
      (p) => p.id == widget.photoId,
      orElse: () => photos.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentPhoto.status == ProcessingStatus.uploading) ...[
                const CircularProgressIndicator(strokeWidth: 3),
                const SizedBox(height: 24),
                const Text(
                  'Uploading photo...',
                  style: TextStyle(fontSize: 18),
                ),
              ] else if (currentPhoto.status == ProcessingStatus.processing) ...[
                const CircularProgressIndicator(strokeWidth: 3),
                const SizedBox(height: 24),
                const Text(
                  'Polishing your photo...',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This may take a few moments',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ] else if (currentPhoto.status == ProcessingStatus.failed) ...[
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Processing failed',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  currentPhoto.errorMessage ?? 'Unknown error',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _startProcessing(),
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () => context.go('/picker'),
                  child: const Text('Back to Photos'),
                ),
              ] else ...[
                const CircularProgressIndicator(strokeWidth: 3),
                const SizedBox(height: 24),
                const Text(
                  'Preparing...',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
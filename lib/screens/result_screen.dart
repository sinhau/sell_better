import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../state/providers.dart';
import '../widgets/before_after_slider.dart';
import '../widgets/action_bar.dart';

class ResultScreen extends ConsumerWidget {
  final String? photoId;

  const ResultScreen({super.key, this.photoId});

  void _showWhatChangedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What Changed?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.auto_fix_high),
              title: Text('Background cleaned'),
              subtitle: Text('Removed distractions and clutter'),
            ),
            const ListTile(
              leading: Icon(Icons.light_mode),
              title: Text('Lighting improved'),
              subtitle: Text('Balanced exposure and colors'),
            ),
            const ListTile(
              leading: Icon(Icons.blur_circular),
              title: Text('Added shadow'),
              subtitle: Text('Natural contact shadow for depth'),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI-edited for clarity. Product unchanged.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider);
    final settings = ref.watch(settingsProvider);
    
    final photo = photos.firstWhere(
      (p) => p.id == photoId,
      orElse: () => photos.first,
    );

    if (photo.processedImage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/picker');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/picker'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showWhatChangedSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BeforeAfterSlider(
              beforeImage: photo.originalImage,
              afterImage: photo.processedImage!,
            ),
          ),
          if (settings.showAIBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'AI-edited',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ActionBar(
            onSave: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo saved to gallery')),
              );
            },
            onShare: () async {
              if (photo.processedImage != null) {
                await Share.shareXFiles(
                  [XFile(photo.processedImage!.path)],
                  text: 'Check out my polished product photo!',
                );
              }
            },
            onPolishAgain: () {
              context.go('/process?photoId=$photoId');
            },
          ),
        ],
      ),
    );
  }
}
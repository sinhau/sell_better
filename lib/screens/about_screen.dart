import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About SellBetter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.camera_enhance,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How It Works',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const StepCard(
              number: '1',
              title: 'Upload Photos',
              description: 'Select up to 5 product photos from your camera or gallery.',
            ),
            const StepCard(
              number: '2',
              title: 'AI Processing',
              description: 'Our AI cleans backgrounds, improves lighting, and adds natural shadows.',
            ),
            const StepCard(
              number: '3',
              title: 'Review & Export',
              description: 'Compare before/after with our slider and export for your listings.',
            ),
            const SizedBox(height: 32),
            Text(
              'AI Transparency',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI-Edited Badge',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We believe in transparency. All photos processed with SellBetter include an optional AI-edited badge to maintain trust with your buyers.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What We Change',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const FeatureItem(
              icon: Icons.check_circle,
              text: 'Clean, neutral backgrounds',
            ),
            const FeatureItem(
              icon: Icons.check_circle,
              text: 'Improved lighting and color balance',
            ),
            const FeatureItem(
              icon: Icons.check_circle,
              text: 'Natural contact shadows',
            ),
            const FeatureItem(
              icon: Icons.check_circle,
              text: 'Removed clutter and distractions',
            ),
            const SizedBox(height: 24),
            Text(
              'What We Don\'t Change',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const FeatureItem(
              icon: Icons.cancel,
              text: 'Product shape or geometry',
              isNegative: true,
            ),
            const FeatureItem(
              icon: Icons.cancel,
              text: 'Brand markings or logos',
              isNegative: true,
            ),
            const FeatureItem(
              icon: Icons.cancel,
              text: 'Product features or accessories',
              isNegative: true,
            ),
            const FeatureItem(
              icon: Icons.cancel,
              text: 'Textures or materials',
              isNegative: true,
            ),
            const SizedBox(height: 32),
            Text(
              'Privacy',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your photos are processed securely and never stored on our servers. All images remain on your device unless you choose to share them.',
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => context.go('/picker'),
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const StepCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isNegative;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.text,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isNegative ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
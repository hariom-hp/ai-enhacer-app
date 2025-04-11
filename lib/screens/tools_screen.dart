import 'package:flutter/material.dart';
import 'image_enhancer_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'AI Toolbox',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildToolItem(
                  context,
                  'AI Image Enhancer',
                  'Enhance and upscale your images with Clarity AI',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImageEnhancerScreen(),
                      ),
                    );
                  },
                ),
                _buildToolItem(
                  context,
                  'AI Avatar Generator',
                  'Turn your photos or selfies into AI avatar',
                ),
                _buildToolItem(
                  context,
                  'AI Photo Generator',
                  'Create multiple variations from a single photo',
                ),
                _buildToolItem(
                  context,
                  'AI Magic Eraser Photo',
                  'Remove unwanted objects from a photo in just one tap',
                ),
                _buildToolItem(
                  context,
                  'AI Background Remover',
                  'Remove background from a photo in just one click',
                ),
                _buildToolItem(
                  context,
                  'AI Photo Recoloring',
                  'Change the color of the image with a variety of styles',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem(
    BuildContext context,
    String title,
    String description, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: title == 'AI Image Enhancer'
                  ? const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Colors.blue,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

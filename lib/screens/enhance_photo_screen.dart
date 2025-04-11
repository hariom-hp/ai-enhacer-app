import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class EnhancePhotoScreen extends StatefulWidget {
  final XFile imageFile;

  const EnhancePhotoScreen({super.key, required this.imageFile});

  @override
  State<EnhancePhotoScreen> createState() => _EnhancePhotoScreenState();
}

class _EnhancePhotoScreenState extends State<EnhancePhotoScreen> {
  bool _isEnhancing = false;
  bool _isEnhanced = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _selectedVersion = 0;
  double _sliderPosition = 0.5;

  @override
  void initState() {
    super.initState();
    _startEnhancing();
  }

  Future<void> _startEnhancing() async {
    setState(() {
      _isEnhancing = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Check file size
      final fileSize = await widget.imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception(
            'Image size too large. Please choose an image under 10MB.');
      }

      // Attempt to enhance the image
      await ApiService.enhanceImage(widget.imageFile);

      if (mounted) {
        setState(() {
          _isEnhancing = false;
          _isEnhanced = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEnhancing = false;
          _hasError = true;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (error.toString().contains('size too large')) {
      return error.toString();
    } else if (error.toString().contains('format')) {
      return 'Unsupported image format. Please use JPG or PNG files.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enhance Photo',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_isEnhanced)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {},
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _hasError
                ? _buildErrorView()
                : _isEnhancing
                    ? _buildEnhancingView()
                    : _buildComparisonView(),
          ),
          if (_isEnhanced) ...[
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                itemBuilder: (context, index) {
                  String label = index == 0 ? 'Base' : 'V${index + 1}';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVersion = index;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedVersion == index
                              ? Colors.red
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(widget.imageFile.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              color: _selectedVersion == index
                                  ? Colors.red
                                  : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Add download functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Download Enhanced Image',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _sliderPosition += details.delta.dx / context.size!.width;
          _sliderPosition = _sliderPosition.clamp(0.0, 1.0);
        });
      },
      child: Stack(
        children: [
          // Original image
          Image.file(
            File(widget.imageFile.path),
            fit: BoxFit.contain,
            width: double.infinity,
          ),
          // Enhanced image (clipped)
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: _sliderPosition,
              child: Image.file(
                File(widget.imageFile.path),
                fit: BoxFit.contain,
                width: double.infinity,
                // ignore: deprecated_member_use
                color: Colors.blue.withOpacity(0.3), // Simulate enhancement
                colorBlendMode: BlendMode.colorBurn,
              ),
            ),
          ),
          // Slider line
          Positioned(
            left: MediaQuery.of(context).size.width * _sliderPosition - 1,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              color: Colors.white,
              child: Center(
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Labels
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Before',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'After',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.file(
          File(widget.imageFile.path),
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 32),
        const CircularProgressIndicator(
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'Enhancing Photo...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "The enhancement may take a few\nseconds. Please don't quit the app.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startEnhancing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Choose Different Photo',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

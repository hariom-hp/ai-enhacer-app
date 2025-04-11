import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000'; // For Android emulator
  // Use 'http://127.0.0.1:5000' for iOS simulator

  static Future<String> enhanceImage(XFile imageFile) async {
    try {
      // Validate file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw Exception(
            'Unsupported image format. Please use JPG or PNG files.');
      }

      final uri = Uri.parse('$baseUrl/enhance');
      final request = http.MultipartRequest('POST', uri);

      final file = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      );

      request.files.add(file);

      // Add optional parameters for the Clarity AI upscaler
      request.fields['scale_factor'] = '2'; // Default scale factor
      request.fields['creativity'] = '0.35'; // Default creativity level
      request.fields['resemblance'] = '0.6'; // Default resemblance level

      final response = await request.send().timeout(
        const Duration(seconds: 60), // Increased timeout for AI processing
        onTimeout: () {
          throw Exception('Connection timed out. Please try again.');
        },
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['enhanced_image_url'];
      } else if (response.statusCode == 413) {
        throw Exception('Image size too large. Please choose a smaller image.');
      } else if (response.statusCode == 415) {
        throw Exception(
            'Unsupported image format. Please use JPG or PNG files.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
            'Unable to connect to server. Please check your internet connection.');
      }
      rethrow;
    }
  }

  // Add a method to enhance image with custom parameters
  static Future<String> enhanceImageWithParams(
    XFile imageFile, {
    double scaleFactor = 2.0,
    double creativity = 0.35,
    double resemblance = 0.6,
  }) async {
    try {
      // Validate file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw Exception(
            'Unsupported image format. Please use JPG or PNG files.');
      }

      final uri = Uri.parse('$baseUrl/enhance');
      final request = http.MultipartRequest('POST', uri);

      final file = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      );

      request.files.add(file);

      // Add custom parameters for the Clarity AI upscaler
      request.fields['scale_factor'] = scaleFactor.toString();
      request.fields['creativity'] = creativity.toString();
      request.fields['resemblance'] = resemblance.toString();

      final response = await request.send().timeout(
        const Duration(seconds: 60), // Increased timeout for AI processing
        onTimeout: () {
          throw Exception('Connection timed out. Please try again.');
        },
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['enhanced_image_url'];
      } else if (response.statusCode == 413) {
        throw Exception('Image size too large. Please choose a smaller image.');
      } else if (response.statusCode == 415) {
        throw Exception(
            'Unsupported image format. Please use JPG or PNG files.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
            'Unable to connect to server. Please check your internet connection.');
      }
      rethrow;
    }
  }
}

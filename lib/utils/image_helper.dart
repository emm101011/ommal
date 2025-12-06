import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ImageHelper {
  static final ImagePicker _picker = ImagePicker();


  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int? maxWidth,
    int? maxHeight,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }





  static Future<String?> imageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return null;
      }


      final fileSize = await file.length();
      const maxSize = 1024 * 1024;

      if (fileSize > maxSize) {
        debugPrint('Image file is too large: ${fileSize / 1024}KB. Max size is 1MB');
        return null;
      }

      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      debugPrint('Error converting image to Base64: $e');
      return null;
    }
  }


  static Widget base64ToImage(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      );
    } catch (e) {
      debugPrint('Error converting Base64 to image: $e');
      return const Icon(Icons.error);
    }
  }


  static Uint8List? base64ToBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error converting Base64 to bytes: $e');
      return null;
    }
  }




  static Future<String?> compressAndConvertToBase64(
    String imagePath, {
    int maxWidth = 800,
    int maxHeight = 800,
    int quality = 85,
  }) async {
    try {


      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();


      const maxSize = 1024 * 1024;
      if (bytes.length > maxSize) {
        debugPrint('Warning: Image size is ${bytes.length / 1024}KB. Consider compressing further.');
      }

      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error compressing and converting image: $e');
      return null;
    }
  }


  static Future<double> getImageSizeKB(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return 0;
      final size = await file.length();
      return size / 1024;
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 0;
    }
  }
}


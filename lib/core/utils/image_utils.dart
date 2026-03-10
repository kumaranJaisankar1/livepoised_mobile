import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageUtils {
  static ImageProvider? getImageProvider(String? imageStr) {
    if (imageStr == null || imageStr.isEmpty) return null;

    if (imageStr.startsWith('http')) {
      return NetworkImage(imageStr);
    }

    if (imageStr.contains('base64,')) {
      try {
        final base64Part = imageStr.split('base64,').last;
        return MemoryImage(base64Decode(base64Part.trim().replaceAll('\n', '').replaceAll('\r', '')));
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return null;
      }
    }

    // Attempt direct base64 decode if it looks like one
    try {
      return MemoryImage(base64Decode(imageStr.trim().replaceAll('\n', '').replaceAll('\r', '')));
    } catch (e) {
      // Not a valid base64 or URL
      return null;
    }
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<String> saveImage(
    File imageFile,
    String category,
    String gender,
  ) async {
    try {
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create wardrobe directory if it doesn't exist
      final Directory wardrobeDir = Directory(
        path.join(appDir.path, 'wardrobe'),
      );
      if (!await wardrobeDir.exists()) {
        await wardrobeDir.create(recursive: true);
      }

      // Create category directory if it doesn't exist
      final Directory categoryDir = Directory(
        path.join(wardrobeDir.path, category.toLowerCase()),
      );
      if (!await categoryDir.exists()) {
        await categoryDir.create(recursive: true);
      }

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(imageFile.path);
      final String fileName = '${gender}_${timestamp}$extension';

      // Copy the image to the new location
      final String newPath = path.join(categoryDir.path, fileName);
      final File newFile = await imageFile.copy(newPath);

      return newFile.path;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  Future<List<String>> getImagesByCategory(String category) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory categoryDir = Directory(
        path.join(appDir.path, 'wardrobe', category.toLowerCase()),
      );

      if (!await categoryDir.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = await categoryDir.list().toList();
      return files
          .where((file) => file is File)
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting images: $e');
      return [];
    }
  }

  Future<bool> imageExists(String imagePath) async {
    try {
      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}

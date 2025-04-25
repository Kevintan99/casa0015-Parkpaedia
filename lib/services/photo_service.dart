import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoServiceException implements Exception {
  final String message;
  PhotoServiceException(this.message);
  @override
  String toString() => message;
}

class PhotoService {
  static const String _photoListKey = 'user_photos';
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    } catch (e) {
      throw PhotoServiceException('Failed to initialize PhotoService: $e');
    }
  }

  Future<void> _checkInitialization() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          throw PhotoServiceException('Storage permission denied');
        }
      }
    }
  }

  Future<String> savePhoto(File photoFile) async {
    try {
      await _checkInitialization();
      await _checkPermissions();

      if (!await photoFile.exists()) {
        throw PhotoServiceException('Source photo file does not exist');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await photoFile.copy(path.join(directory.path, fileName));
      
      final photos = _prefs.getStringList(_photoListKey) ?? [];
      photos.add(savedImage.path);
      await _prefs.setStringList(_photoListKey, photos);
      
      return savedImage.path;
    } catch (e) {
      throw PhotoServiceException('Failed to save photo: $e');
    }
  }

  Future<List<String>> getAllPhotos() async {
    try {
      await _checkInitialization();
      final photos = _prefs.getStringList(_photoListKey) ?? [];
      // Filter out photos that no longer exist
      photos.removeWhere((photo) => !File(photo).existsSync());
      await _prefs.setStringList(_photoListKey, photos);
      return photos;
    } catch (e) {
      throw PhotoServiceException('Failed to get photos: $e');
    }
  }

  Future<void> deletePhoto(String photoPath) async {
    try {
      await _checkInitialization();
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }

      final photos = _prefs.getStringList(_photoListKey) ?? [];
      photos.remove(photoPath);
      await _prefs.setStringList(_photoListKey, photos);
    } catch (e) {
      throw PhotoServiceException('Failed to delete photo: $e');
    }
  }

  Future<DateTime> getPhotoTimestamp(String photoPath) async {
    try {
      final fileName = path.basename(photoPath);
      final timestamp = int.parse(fileName.split('_')[1].split('.')[0]);
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      throw PhotoServiceException('Failed to get photo timestamp: $e');
    }
  }
} 
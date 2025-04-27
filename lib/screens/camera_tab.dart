import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_service.dart';

class CameraTab extends StatefulWidget {
  const CameraTab({super.key});

  @override
  State<CameraTab> createState() => _CameraTabState();
}

class _CameraTabState extends State<CameraTab> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required')),
          );
          return;
        }
      }

      // Get current location
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Upload photo with location data
      await _firebaseService.uploadPhoto(image, position);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isUploading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    onPressed: () => _handleImageSelection(ImageSource.camera),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                    onPressed: () => _handleImageSelection(ImageSource.gallery),
                  ),
                ],
              ),
      ),
    );
  }
} 
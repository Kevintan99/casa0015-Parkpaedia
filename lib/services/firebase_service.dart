import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../models/species.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all species for a specific park
  Stream<List<Species>> getSpecies(String parkName) {
    return _firestore
        .collection('parks')
        .doc(parkName)
        .collection('species')
        .snapshots()
        .map((snapshot) {
          print('💧 getSpecies for $parkName → \\${snapshot.docs.length} docs');
          return snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                print('  • doc \\${doc.id}: \\${data}');
                return Species.fromMap(data, doc.id);
              })
              .toList();
        });
  }

  // Get filtered species by type
  Stream<List<Species>> getFilteredSpecies(String parkName, String type) {
    return _firestore
        .collection('parks')
        .doc(parkName)
        .collection('species')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) {
          print('💧 getFilteredSpecies for $parkName, type=$type → \\${snapshot.docs.length} docs');
          return snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                print('  • doc \\${doc.id}: \\${data}');
                return Species.fromMap(data, doc.id);
              })
              .toList();
        });
  }

  // Search species by name
  Stream<List<Species>> searchSpecies(String parkName, String searchTerm) {
    return _firestore
        .collection('parks')
        .doc(parkName)
        .collection('species')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: searchTerm + 'z')
        .snapshots()
        .map((snapshot) {
          print('💧 searchSpecies for $parkName, searchTerm=$searchTerm → \\${snapshot.docs.length} docs');
          return snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                print('  • doc \\${doc.id}: \\${data}');
                return Species.fromMap(data, doc.id);
              })
              .toList();
        });
  }

  // Upload a photo with location data
  Future<String> uploadPhoto(XFile photo, Position position) async {
    final String fileName =
        'photos/${DateTime.now().millisecondsSinceEpoch}_${photo.name}';
    final Reference ref = _storage.ref().child(fileName);
    
    final metadata = SettableMetadata(
      customMetadata: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await ref.putFile(File(photo.path), metadata);
    return await ref.getDownloadURL();
  }

  // Get user's photo collection
  Stream<QuerySnapshot> getUserPhotos() {
    return _firestore
        .collection('user_photos')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Toggle like status for a species
  Future<void> toggleLikeSpecies(String speciesId, bool isLiked) async {
    final docRef = _firestore.collection('liked_species').doc(speciesId);
    if (isLiked) {
      await docRef.set({'timestamp': FieldValue.serverTimestamp()});
    } else {
      await docRef.delete();
    }
  }

  // Get liked species
  Stream<List<String>> getLikedSpecies() {
    return _firestore
        .collection('liked_species')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
} 
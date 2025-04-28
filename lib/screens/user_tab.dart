import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import 'package:hive/hive.dart';
import '../models/user_photo.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  final FirebaseService _firebaseService = FirebaseService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Collection'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              Tab(text: 'Liked Species'),
              Tab(text: 'My Photos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLikedSpeciesTab(),
            _buildPhotosTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedSpeciesTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('liked_species').listenable(),
      builder: (context, Box box, _) {
        final likedSpecies = List<String>.from(box.get('ids', defaultValue: <String>[]));
        if (likedSpecies.isEmpty) {
          return const Center(
            child: Text('No liked species yet'),
          );
        }
        return ListView.builder(
          itemCount: likedSpecies.length,
          itemBuilder: (context, index) {
            final speciesId = likedSpecies[index];
            return FutureBuilder<DocumentSnapshot?>(
              future: _findSpeciesById(speciesId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
                  return const SizedBox();
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['imageUrl']),
                  ),
                  title: Text(data['name']),
                  subtitle: Text(data['family']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _unlikeSpecies(speciesId);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<DocumentSnapshot?> _findSpeciesById(String speciesId) async {
    // Try to find the species in all parks
    final parks = ['hydepark', 'regentspark', 'queenelizabethpark'];
    for (final park in parks) {
      final doc = await FirebaseFirestore.instance
          .collection('parks')
          .doc(park)
          .collection('species')
          .doc(speciesId)
          .get();
      if (doc.exists) return doc;
    }
    return null;
  }

  void _unlikeSpecies(String speciesId) {
    final box = Hive.box('liked_species');
    final liked = List<String>.from(box.get('ids', defaultValue: <String>[]));
    liked.remove(speciesId);
    box.put('ids', liked);
    setState(() {});
  }

  Widget _buildPhotosTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('user_photos').listenable(),
      builder: (context, Box box, _) {
        final photos = box.values.cast<UserPhoto>().toList();
        if (photos.isEmpty) {
          return const Center(
            child: Text('No photos saved yet'),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            final formattedDate =
                '${photo.timestamp.year}-${photo.timestamp.month}-${photo.timestamp.day}';
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.file(
                          File(photo.filePath),
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 120,
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(photo.latitude, photo.longitude),
                              zoom: 15,
                              interactiveFlags: InteractiveFlag.none,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(photo.latitude, photo.longitude),
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Taken on: $formattedDate'),
                              Text(
                                'Location: ${photo.latitude.toStringAsFixed(5)}, ${photo.longitude.toStringAsFixed(5)}',
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        TextButton.icon(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete Photo', style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            final box = Hive.box('user_photos');
                            await box.deleteAt(index);
                            final file = File(photo.filePath);
                            if (await file.exists()) {
                              await file.delete();
                            }
                            Navigator.of(context).pop(); // Close the dialog
                            (this.context as Element).markNeedsBuild(); // Refresh UI
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(photo.filePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 
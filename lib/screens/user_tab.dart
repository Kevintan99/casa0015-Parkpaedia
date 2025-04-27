import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';

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
    return StreamBuilder<List<String>>(
      stream: _firebaseService.getLikedSpecies(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final likedSpecies = snapshot.data ?? [];

        if (likedSpecies.isEmpty) {
          return const Center(
            child: Text('No liked species yet'),
          );
        }

        return ListView.builder(
          itemCount: likedSpecies.length,
          itemBuilder: (context, index) {
            final speciesId = likedSpecies[index];
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('species')
                  .doc(speciesId)
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['imageUrl']),
                  ),
                  title: Text(data['name']),
                  subtitle: Text(data['family']),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPhotosTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseService.getUserPhotos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final photos = snapshot.data?.docs ?? [];

        if (photos.isEmpty) {
          return const Center(
            child: Text('No photos uploaded yet'),
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
            final data = photo.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final formattedDate = DateFormat('MMM d, y').format(timestamp);

            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CachedNetworkImage(
                          imageUrl: data['url'],
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Taken on: $formattedDate'),
                              Text(
                                'Location: ${data['latitude']}, ${data['longitude']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: data['url'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 
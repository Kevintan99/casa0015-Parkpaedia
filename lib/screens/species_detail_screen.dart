import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/species.dart';
import '../services/firebase_service.dart';

class SpeciesDetailScreen extends StatefulWidget {
  final Species species;

  const SpeciesDetailScreen({super.key, required this.species});

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    _firebaseService.getLikedSpecies().listen((likedSpecies) {
      if (mounted) {
        setState(() {
          _isLiked = likedSpecies.contains(widget.species.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.species.name),
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              _firebaseService.toggleLikeSpecies(widget.species.id, _isLiked);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.species.id,
              child: CachedNetworkImage(
                imageUrl: widget.species.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.species.family,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${widget.species.type}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Origin: ${widget.species.origin}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.species.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
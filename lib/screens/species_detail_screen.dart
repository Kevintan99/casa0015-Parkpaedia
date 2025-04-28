import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/species.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SpeciesDetailScreen extends StatefulWidget {
  final Species species;

  const SpeciesDetailScreen({super.key, required this.species});

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }

  void _checkLikeStatus() {
    final box = Hive.box('liked_species');
    final liked = List<String>.from(box.get('ids', defaultValue: <String>[]));
    setState(() {
      _isLiked = liked.contains(widget.species.id);
    });
  }

  void _toggleLike() {
    final box = Hive.box('liked_species');
    final liked = List<String>.from(box.get('ids', defaultValue: <String>[]));
    setState(() {
      if (_isLiked) {
        liked.remove(widget.species.id);
        _isLiked = false;
      } else {
        liked.add(widget.species.id);
        _isLiked = true;
      }
      box.put('ids', liked);
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
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.species.id,
              child: Image.network(
                widget.species.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, o, st) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family: ${widget.species.family}',
                    style: Theme.of(context).textTheme.titleMedium,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
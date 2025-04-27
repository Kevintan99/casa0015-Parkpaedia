import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/species.dart';
import '../services/firebase_service.dart';
import 'species_detail_screen.dart';

class HomeTab extends StatefulWidget {
  final String parkName;

  const HomeTab({super.key, required this.parkName});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';
  String? _selectedType;
  final List<String> _types = ['Bird', 'Insect', 'Flower', 'Tree', 'Mammal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parkName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search species...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Filter'),
                  value: _selectedType,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All'),
                    ),
                    ..._types.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Species>>(
              stream: _searchQuery.isNotEmpty
                  ? _firebaseService.searchSpecies(widget.parkName, _searchQuery)
                  : _selectedType != null
                      ? _firebaseService.getFilteredSpecies(
                          widget.parkName, _selectedType!)
                      : _firebaseService.getSpecies(widget.parkName),
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

                final species = snapshot.data ?? [];

                if (species.isEmpty) {
                  return const Center(
                    child: Text('No species found'),
                  );
                }

                return ListView.builder(
                  itemCount: species.length,
                  itemBuilder: (context, index) {
                    final specie = species[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(specie.imageUrl),
                        ),
                        title: Text(specie.name),
                        subtitle: Text(specie.family),
                        trailing: Text(
                          specie.type,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SpeciesDetailScreen(species: specie),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
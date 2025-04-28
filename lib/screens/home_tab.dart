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
  final List<String> _types = ['Bird', 'Insect', 'Flowers', 'Tree', 'Mammals'];
  final parkIds = {
    'Hyde Park': 'hydepark',
    'Regents Park': 'regentspark',
    'Queen Elizabeth Park': 'queenelizabethpark',
  };
  final Map<String, String> parkBackgrounds = {
    'Hyde Park': 'assets/images/hyde_park_bg.jpg',
    'Regents Park': 'assets/images/regents_park_bg.jpg',
    'Queen Elizabeth Park': 'assets/images/queen_elizabeth_park_bg.jpg',
  };

  @override
  Widget build(BuildContext context) {
    final bgImage = parkBackgrounds[widget.parkName] ?? 'assets/images/default_bg.jpg';
    final docId = parkIds[widget.parkName]!;
    print('🏠 HomeTab building for \\${widget.parkName}, docId: \\${docId}');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parkName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            bgImage,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.white.withOpacity(0.7), // Optional overlay for readability
          ),
          Column(
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
                child: Builder(
                  builder: (context) {
                    print('🔄 Setting up StreamBuilder for docId: \\${docId}');
                    return StreamBuilder<List<Species>>(
                      stream: _searchQuery.isNotEmpty
                          ? _firebaseService.searchSpecies(docId, _searchQuery)
                          : _selectedType != null
                              ? _firebaseService.getFilteredSpecies(docId, _selectedType!)
                              : _firebaseService.getSpecies(docId),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String parkNameToId(String name) {
  return name.toLowerCase().replaceAll(' ', '');
} 
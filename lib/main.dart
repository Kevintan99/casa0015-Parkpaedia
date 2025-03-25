import 'package:flutter/material.dart';

void main() {
  runApp(const ParkPaediaApp());
}

class ParkPaediaApp extends StatelessWidget {
  const ParkPaediaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkPaedia',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Start the app at the HomeScreen
      home: const HomeScreen(),
    );
  }
}

/// A model representing a Park with a name, description, imageUrl, and a list of ParkItems.
class Park {
  final String name;
  final String description;
  final String assetPath;
  final List<ParkItem> items;

  Park({
    required this.name,
    required this.description,
    required this.assetPath,
    required this.items,
  });
}

/// A model representing an item (animal/plant) within a park.
class ParkItem {
  final String name;
  final String description;
  final String assetPath;

  ParkItem({
    required this.name,
    required this.description,
    required this.assetPath,
  });
}

// --------------------------------------------------------
// SAMPLE DATA
// --------------------------------------------------------

/// Sample items for demonstration (could be animals, plants, etc.)
final coccinellidae = ParkItem(
  name: 'Coccinellidae',
  description:
      'Coccinellidae is a widespread family of small beetles. Commonly known as ladybugs in North America and ladybirds in the UK.',
  assetPath: 'Assets\Images/Ladybug.jpg', // Local asset image
);

final squirrel = ParkItem(
  name: 'Squirrel',
  description:
      'Squirrels are members of the family Sciuridae, consisting of small or medium-size rodents.',
  assetPath: 'Assets\Images/Ladybug.jpg',
);

final oakTree = ParkItem(
  name: 'Oak Tree',
  description:
      'Oak is a tree or shrub in the genus Quercus of the beech family, Fagaceae.',
  assetPath: 'Assets\Images/Ladybug.jpg',
);

/// Sample list of parks in London (replace with real data and images as needed).
final List<Park> parks = [
  Park(
    name: 'Queen Elizabeth Olympic Park',
    description:
        'Queen Elizabeth Olympic Park is a sporting complex in Stratford, London, built for the 2012 Summer Olympics.',
    assetPath: 'Assets/Images/QueenElizabethPark.jpg',
    items: [
      coccinellidae,
      squirrel,
      oakTree,
    ],
  ),
  Park(
    name: 'Hyde Park',
    description:
        'Hyde Park is a Grade I-registered major park in Central London, famous for its Speakers\' Corner.',
    assetPath: 'Assets\Images/Ladybug.jpg',
    items: [
      ParkItem(
        name: 'Rose Plant',
        description: 'Roses are the most popular garden shrubs.',
        assetPath: 'Assets\Images/Ladybug.jpg',
      ),
      ParkItem(
        name: 'Pigeon',
        description:
            'Rock pigeons, also called city doves, are abundant in urban areas.',
        assetPath: 'Assets\Images/Ladybug.jpg',
      ),
    ],
  ),
];

// --------------------------------------------------------
// HOME SCREEN
// --------------------------------------------------------

/// The home screen with the “ParkPaedia” title, a dropdown to select a park,
/// and an “Enter” button to navigate to the selected park details.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Park? _selectedPark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background might match the user’s design with an image, etc.
      appBar: AppBar(
        title: const Text('PARKPAEDIA'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // A dropdown for selecting which park to view
            DropdownButton<Park>(
              isExpanded: true,
              hint: const Text('Select Park'),
              value: _selectedPark,
              items: parks.map((Park park) {
                return DropdownMenuItem<Park>(
                  value: park,
                  child: Text(park.name),
                );
              }).toList(),
              onChanged: (Park? newValue) {
                setState(() {
                  _selectedPark = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            // An "Enter" button that takes you to the details of the selected park
            ElevatedButton(
              onPressed: _selectedPark == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ParkDetailScreen(park: _selectedPark!),
                        ),
                      );
                    },
              child: const Text('Enter'),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------
// PARK DETAIL SCREEN
// --------------------------------------------------------

/// This screen shows details about the selected park, plus a search/filter UI,
/// and a list of animals/plants within the park.
class ParkDetailScreen extends StatefulWidget {
  final Park park;

  const ParkDetailScreen({Key? key, required this.park}) : super(key: key);

  @override
  State<ParkDetailScreen> createState() => _ParkDetailScreenState();
}

class _ParkDetailScreenState extends State<ParkDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // In a more complex app, you might store the filter state here, too.
  // For now, we just have a button that doesn't do much.

  @override
  Widget build(BuildContext context) {
    // Filter the items by the search query
    final filteredItems = widget.park.items.where((item) {
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.park.name),
      ),
      body: Column(
        children: [
          // Display the park image at the top (if you want to mimic the design)
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Image.asset(
              'Assets/Images/QueenElizabethPark.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if the image fails to load
                return Container(
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: const Text('Image not available'),
                );
              },
            ),
          ),
          // The park description
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.park.description,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          // A row with a search field and a filter button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Filter button (placeholder)
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Implement filter functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter button tapped')),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // List of filtered items
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  leading: Image.asset(
                    item.assetPath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigate to detail screen for this item
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ParkItemDetailScreen(item: item),
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

// --------------------------------------------------------
// PARK ITEM DETAIL SCREEN
// --------------------------------------------------------

/// Shows the details of a single park item (animal or plant).
class ParkItemDetailScreen extends StatelessWidget {
  final ParkItem item;

  const ParkItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image of the item
            Image.asset(
              item.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: const Text('Image not available'),
                );
              },
            ),
            // Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                item.description,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

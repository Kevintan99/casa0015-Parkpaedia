import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_tab.dart';
import 'screens/camera_tab.dart';
import 'screens/user_tab.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_photo.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserPhotoAdapter());
  await Hive.openBox('liked_species');
  await Hive.openBox('user_photos');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase is already initialized, we can ignore the error
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized');
    } else {
      rethrow;
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parkpaedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Forest green as primary color
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/park_selection': (context) => const ParkSelectionPage(),
      },
    );
  }
}

class ParkSelectionPage extends StatefulWidget {
  const ParkSelectionPage({super.key});

  @override
  State<ParkSelectionPage> createState() => _ParkSelectionPageState();
}

class _ParkSelectionPageState extends State<ParkSelectionPage> {
  String? selectedPark;
  final List<String> parks = ['Hyde Park', 'Regents Park', 'Queen Elizabeth Park'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background.jpg', // or use Image.network for an online image
            fit: BoxFit.cover,
          ),
          // Foreground content
          Container(
            color: Colors.white.withOpacity(0.5), // Optional: add a white overlay for readability
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'PARKPAEDIA',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      hint: const Text(
                        'Select Park',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Optional: adjust size as needed
                        ),
                      ),
                      value: selectedPark,
                      isExpanded: true,
                      underline: Container(),
                      items: parks.map((String park) {
                        return DropdownMenuItem<String>(
                          value: park,
                          child: Text(
                            park,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Optional: adjust size as needed
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPark = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedPark == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MainNavigationScreen(selectedPark: selectedPark!),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text('Enter'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final String selectedPark;

  const MainNavigationScreen({super.key, required this.selectedPark});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(parkName: widget.selectedPark),
          const CameraTab(),
          const UserTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
    );
  }
}

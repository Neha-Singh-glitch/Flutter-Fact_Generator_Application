import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // For modern fonts

void main() {
  runApp(const FactGeneratorApp());
}

class FactGeneratorApp extends StatelessWidget {
  const FactGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fact Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // Splash screen as the starting point
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 3 seconds before navigating to the main page
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const FactHomePage(),
        ), // Transition to the main page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: 1.0,
          child: TweenAnimationBuilder(
            duration: const Duration(seconds: 2),
            tween: Tween<Offset>(
              begin: const Offset(0, 0),
              end: const Offset(0, 0.1),
            ),
            builder: (context, Offset offset, child) {
              return Transform.translate(
                offset: offset,
                child: Text(
                  'Fact Generator',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Main Page (Fact Generator UI)
class FactHomePage extends StatefulWidget {
  const FactHomePage({super.key});

  @override
  _FactHomePageState createState() => _FactHomePageState();
}

class _FactHomePageState extends State<FactHomePage> {
  String fact = "Click a category to get a random fact!";
  bool isLoading = false;
  String category = "Random"; // Default category

  // Function to fetch a random fact based on the selected category
  Future<void> fetchRandomFact() async {
    setState(() {
      isLoading = true;
    });

    String apiUrl = 'https://uselessfacts.jsph.pl/random.json?language=en';
    if (category == "Science") {
      apiUrl =
          'https://uselessfacts.jsph.pl/random.json?language=en&category=science';
    } else if (category == "History") {
      apiUrl =
          'https://uselessfacts.jsph.pl/random.json?language=en&category=history';
    } else if (category == "Technology") {
      apiUrl =
          'https://uselessfacts.jsph.pl/random.json?language=en&category=technology';
    }

    try {
      final url = Uri.parse(apiUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String newFact = data['text'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('lastFact', newFact);

        setState(() {
          fact = newFact;
          isLoading = false;
        });
      } else {
        setState(() {
          fact = "Failed to fetch a fact.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        fact = "Error fetching fact: $e";
        isLoading = false;
      });
    }
  }

  // Load cached fact from shared preferences
  Future<void> loadCachedFact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fact = prefs.getString('lastFact') ?? fact;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCachedFact(); // Load cached fact when app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fact Generator',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fact Display with modern text styling
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    fact,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),

                // Show loading spinner when fetching fact
                if (isLoading) const CircularProgressIndicator(),

                const SizedBox(height: 30),

                // Category Boxes with hover/tap animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CategoryBox(
                      category: 'Random',
                      onTap: () {
                        setState(() {
                          category = 'Random';
                        });
                        fetchRandomFact();
                      },
                    ),
                    const SizedBox(width: 20),
                    CategoryBox(
                      category: 'Science',
                      onTap: () {
                        setState(() {
                          category = 'Science';
                        });
                        fetchRandomFact();
                      },
                    ),
                    const SizedBox(width: 20),
                    CategoryBox(
                      category: 'History',
                      onTap: () {
                        setState(() {
                          category = 'History';
                        });
                        fetchRandomFact();
                      },
                    ),
                    const SizedBox(width: 20),
                    CategoryBox(
                      category: 'Technology',
                      onTap: () {
                        setState(() {
                          category = 'Technology';
                        });
                        fetchRandomFact();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Display the current category
                Text(
                  "Category: $category",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Category Box Widget with Hover/Touch Animation
class CategoryBox extends StatefulWidget {
  final String category;
  final VoidCallback onTap;

  const CategoryBox({super.key, required this.category, required this.onTap});

  @override
  _CategoryBoxState createState() => _CategoryBoxState();
}

class _CategoryBoxState extends State<CategoryBox> {
  double _scale = 1.0;
  double _shadow = 0.0;

  void _onHover(bool isHovering) {
    setState(() {
      _scale = isHovering ? 1.1 : 1.0;
      _shadow = isHovering ? 10.0 : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, _shadow),
                blurRadius: 8,
              ),
            ],
          ),
          transform: Matrix4.identity()..scale(_scale),
          child: Text(
            widget.category,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

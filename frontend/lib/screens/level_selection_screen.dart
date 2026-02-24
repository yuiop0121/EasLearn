import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import 'subject_selection_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  Map<String, dynamic>? _hierarchy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTextbooks();
  }

  Future<void> _fetchTextbooks() async {
    if (kUseDemoMode) {
      setState(() {
        _hierarchy = kMockHierarchy;
        _isLoading = false;
      });
      return;
    }
    try {
      final response = await http.get(Uri.parse('$kBackendUrl/textbooks')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          _hierarchy = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching textbooks: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kUseDemoMode ? "EasLearn (Demo Mode)" : "EasLearn - Select Level"),
        centerTitle: true,
        backgroundColor: kUseDemoMode ? Colors.orange : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_hierarchy == null || _hierarchy!.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("No textbooks found or server offline."),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _fetchTextbooks();
                        },
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _hierarchy?.keys.length ?? 0,
                    itemBuilder: (context, index) {
                      String level = _hierarchy!.keys.elementAt(index);
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubjectSelectionScreen(
                                level: level,
                                subjects: Map<String, dynamic>.from(_hierarchy![level]),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.school, size: 40, color: Colors.blueAccent),
                              const SizedBox(height: 10),
                              Text(
                                level,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

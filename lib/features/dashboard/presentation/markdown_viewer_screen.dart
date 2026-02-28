import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class MarkdownViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const MarkdownViewerScreen(
      {super.key, required this.url, required this.title});

  Future<String> fetchMarkdown() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return 'Failed to load note content.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<String>(
        future: fetchMarkdown(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent));
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
                child: Text('Error loading content',
                    style: TextStyle(color: Colors.white)));
          }
          return Markdown(
            data: snapshot.data!,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Colors.white70, fontSize: 16),
              h1: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
              h2: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              listBullet: const TextStyle(color: Colors.blueAccent),
            ),
          );
        },
      ),
    );
  }
}

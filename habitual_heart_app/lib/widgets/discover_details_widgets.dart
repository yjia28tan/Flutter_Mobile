import 'package:flutter/material.dart';

class MeditationToolDetailPage extends StatelessWidget {
  final String title;
  final String description;

  MeditationToolDetailPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(description),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class PanoramaPage extends StatelessWidget {
  final String imageUrl;

  const PanoramaPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Tour'),
        backgroundColor: const Color.fromARGB(255, 14, 86, 170),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PanoramaViewer(
        child: Image.network(imageUrl),
      ),
    );
  }
}

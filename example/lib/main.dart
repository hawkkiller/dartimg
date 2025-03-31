import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dartimg/dartimg.dart' as dartimg;
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Uint8List> _loadImage() async {
    final data = await get(Uri.parse(
        'https://images.unsplash.com/photo-1726137569966-a7354383e2ae?q=80&w=4000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'));

    return data.bodyBytes;
  }

  late Future<Uint8List> _bytes;
  Uint8List? _upscaledImage;

  @override
  void initState() {
    _bytes = _loadImage();
    super.initState();
  }

  Uint8List _upscaleImage(Uint8List image) {
    _upscaledImage = dartimg.upscaleImage(image, 2);

    final file = File('image.jpg');
    final pwd = Directory.current.path;
    print('Current directory: $pwd');
    file.writeAsBytes(_upscaledImage!);
    print('Image saved to $pwd/image.jpg');

    return _upscaledImage!;
  }

  Uint8List _getUpscaledImage(Uint8List toUpscale) {
    return _upscaledImage ?? _upscaleImage(toUpscale);
  }

  Uint8List _updateUpscaledImage(Uint8List toUpscale) {
    _upscaledImage = dartimg.upscaleImage(toUpscale, 2);
    setState(() {});
    return _upscaledImage!;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _updateUpscaledImage(_upscaledImage!);
            },
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            title: const Text('Dart Image Example'),
          ),
          body: FutureBuilder(
              future: _bytes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return Row(
                  children: [
                    Expanded(
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Image.memory(
                        _getUpscaledImage(snapshot.data!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                );
              })),
    );
  }
}

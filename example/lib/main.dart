import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dartimg/dartimg.dart' as dartimg;
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Uint8List> _originalImage;
  Uint8List? _upscaledImage;

  @override
  void initState() {
    super.initState();
    _originalImage = _loadImageAndRunParallelIsolates();
  }

  Future<Uint8List> _loadImageAndRunParallelIsolates() async {
    final imageBytes = await _downloadImage();
    print('Image downloaded. Upscaling once...');

    final initial = dartimg.upscaleImage(imageBytes, 4);

    print('Running 100 upscales in 4 parallel isolates...');

    final stopwatch = Stopwatch()..start();

    // Launch multiple isolates to do the same work in parallel
    final isolateCount = 4;
    final futures = List.generate(
      isolateCount,
      (_) => compute(_upscaleLoop, initial),
    );

    final results = await Future.wait(futures);
    stopwatch.stop();
    print('All isolates finished in ${stopwatch.elapsedMilliseconds} ms');

    return imageBytes;
  }

  static void _upscaleLoop(Uint8List image) {
    for (int i = 0; i < 100; i++) {
      dartimg.upscaleImage(image, 2);
      print('Isolate ${Isolate.current.hashCode}: iteration ${i + 1}');
    }
  }

  Future<Uint8List> _downloadImage() async {
    final response = await get(Uri.parse(
      'https://images.unsplash.com/photo-1726137569966-a7354383e2ae?q=80&w=400&auto=format&fit=crop',
    ));
    return response.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dart Image Example'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_upscaledImage != null) {
              setState(() {
                _upscaledImage = dartimg.upscaleImage(_upscaledImage!, 2);
              });
              print('Manually upscaled again.');
            }
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: _originalImage,
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
                  child: _upscaledImage != null
                      ? Image.memory(_upscaledImage!, fit: BoxFit.cover)
                      : const Center(child: Text('Upscaling...')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

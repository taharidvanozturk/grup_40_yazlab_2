// ignore_for_file: avoid_print, prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grup_40_yazlab_2/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            addDataToFirestore();
          },
          child: const Text('Veri Ekle'),
        ),
      ),
    );
  }
}

// Firestore veri ekleme fonksiyonu
void addDataToFirestore() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (int i = 1; i <= 16; i++) {
      for (int j = 1; j <= 7; j++) {
        String cellId = '$i' + 'x' + '$j';

        await firestore.collection('grid').doc(cellId).set({
          'id': cellId,
          'text': cellId,
          'color': 'FF66BB6A',
        });
      }
    }

    print('Veri başarıyla Firestore\'a eklendi.');
  } catch (e) {
    print('Firestore veri ekleme hatası: $e');
  }
}

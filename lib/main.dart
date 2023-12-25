// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings, avoid_print, unused_field, use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grup_40_yazlab_2/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DersEklemeSayfasi()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OgretmenEklemeSayfasi()),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemCount: 7 * 16,
        itemBuilder: (context, index) {
          int row = (index / 7).floor() + 1;
          int column = (index % 7) + 1;
          String cellId = '$row' + 'x' + '$column';

          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance.collection('grid').doc(cellId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return _buildPlaceholderContainer();
                }

                if (snapshot.hasData && snapshot.data != null) {
                  Map<String, dynamic>? data =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  if (data != null) {
                    return GestureDetector(
                      onTap: () {
                        // Hücreye tıklama işlemleri buraya eklenebilir
                      },
                      child: Container(
                        color: _parseColor(data['color']),
                        child: Center(
                          child: Text(
                            data['text'] ?? 'Placeholder',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return _buildPlaceholderContainer();
                  }
                } else {
                  return _buildPlaceholderContainer();
                }
              } else {
                return const CircularProgressIndicator();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlaceholderContainer() {
    return Container(
      color: Colors.green,
      child: const Center(
        child: Text(
          'No Data',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return null;
    }

    try {
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      print('Error parsing color: $e');
      return null;
    }
  }
}

class DersEklemeSayfasi extends StatelessWidget {
  const DersEklemeSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Ekleme Sayfası'),
      ),
      body: const Center(
        child: Text('Bu sayfa ders ekleme sayfasıdır.'),
      ),
    );
  }
}

class OgretmenEklemeSayfasi extends StatefulWidget {
  const OgretmenEklemeSayfasi({Key? key}) : super(key: key);

  @override
  OgretmenEklemeSayfasiState createState() => OgretmenEklemeSayfasiState();
}

class OgretmenEklemeSayfasiState extends State<OgretmenEklemeSayfasi> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _unvanController = TextEditingController();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  String _selectedDay = 'Pazartesi';
  String _selectedHour = '09:00';

  final List<String> _days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  final List<String> _hours = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğretmen Ekleme Sayfası'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _unvanController,
                decoration: const InputDecoration(labelText: 'Ünvan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ünvan boş olamaz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(labelText: 'Ad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad boş olamaz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _soyadController,
                decoration: const InputDecoration(labelText: 'Soyad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Soyad boş olamaz';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedDay,
                items: _days.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Gün'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedHour,
                items: _hours.map((String hour) {
                  return DropdownMenuItem<String>(
                    value: hour,
                    child: Text(hour),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHour = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Saat'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveTeacherData(context);
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTeacherData(BuildContext context) async {
    String fullName =
        '${_unvanController.text} ${_adController.text} ${_soyadController.text}';
    String documentId = '$fullName-$_selectedDay-$_selectedHour';

    // Check if the document already exists
    var existingDoc = await FirebaseFirestore.instance
        .collection('teachers')
        .doc(documentId)
        .get();

    if (existingDoc.exists) {
      // Document already exists, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu öğretmen zaten bu gün ve saatte ders vermektedir.'),
        ),
      );
    } else {
      // Document does not exist, save the data
      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(documentId)
          .set({
        'unvan': _unvanController.text,
        'ad': _adController.text,
        'soyad': _soyadController.text,
        'day': _selectedDay,
        'hour': _selectedHour,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Öğretmen başarıyla eklendi.'),
        ),
      );

      // Clear form fields
      _unvanController.clear();
      _adController.clear();
      _soyadController.clear();
    }
  }
}

// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings, avoid_print, unused_field, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_local_variable, unnecessary_string_interpolations, library_private_types_in_public_api

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
  final String _selectedNumber = 'Ders Seçiniz';
  final String _selectedDay = 'Gün Seçiniz';
  final String _selectedHour = 'Saat Seçiniz';

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
                  builder: (context) => const DersEklemeSayfasi(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OgretmenEklemeSayfasi(),
                ),
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

class DersEklemeSayfasi extends StatefulWidget {
  const DersEklemeSayfasi({Key? key}) : super(key: key);

  @override
  _DersEklemeSayfasiState createState() => _DersEklemeSayfasiState();
}

class _DersEklemeSayfasiState extends State<DersEklemeSayfasi> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dersAdiController = TextEditingController();
  final TextEditingController _sinifController = TextEditingController();
  final TextEditingController _saatController = TextEditingController();
  String _selectedTeacher = 'Öğretmen Seçiniz';
  String _selectedHour = 'Saat Seçiniz';

  var _selectedNumber;
  var _selectedDay;

  void _saveLessonData(BuildContext context) async {
    String lessonName = _dersAdiController.text;
    String className = _sinifController.text;
    String lessonHour = _saatController.text;
    String teacherName = _selectedTeacher;

    // Ders veritabanındaki dersler koleksiyonuna ekleniyor.
    await FirebaseFirestore.instance.collection('lessons').add({
      'lessonName': lessonName,
      'className': className,
      'lessonHour': lessonHour,
      'teacherName': teacherName,
    });

    // Başarı mesajını göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ders başarıyla eklendi.'),
      ),
    );

    // Form alanlarını temizle
    _dersAdiController.clear();
    _sinifController.clear();
    _saatController.clear();
    setState(() {
      _selectedTeacher = 'Öğretmen Seçiniz';
      _selectedHour = 'Saat Seçiniz';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTeacherNames();
  }

  Future<void> _loadTeacherNames() async {
    // Load teacher names and set initial value for _selectedTeacher
    List<String> teacherNames = await _getTeacherNames();
    if (teacherNames.isNotEmpty) {
      setState(() {
        _selectedTeacher = teacherNames[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Ekleme Sayfası'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dersAdiController,
                decoration: const InputDecoration(labelText: 'Ders Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ders adı boş olamaz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sinifController,
                decoration: const InputDecoration(labelText: 'Sınıf'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sınıf boş olamaz';
                  }
                  return null;
                },
              ),
              FutureBuilder<List<String>>(
                future: _getTeacherNames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<String> teacherNames = snapshot.data!;

                    if (!teacherNames.contains(_selectedTeacher)) {
                      _selectedTeacher = teacherNames.isNotEmpty
                          ? teacherNames[0]
                          : 'Öğretmen Seçiniz';
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedTeacher,
                      items: teacherNames.map((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher,
                          child: Text(teacher),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTeacher = value!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Öğretmen'),
                    );
                  } else {
                    return const Text('No teachers available.');
                  }
                },
              ),
              FutureBuilder<List<Map<String, String>>>(
                future: _getHoursFromGridCollection(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<Map<String, String>> lessonInfos = snapshot.data!;

                    List<String> uniqueNumbers = [];
                    List<String> uniqueDays = [];

                    // Extract unique "text" values for hours and days
                    for (var lessonInfo in lessonInfos) {
                      String id = lessonInfo['id']!;
                      String text = lessonInfo['text']!;

                      if (id.startsWith('1x1') ||
                          id.startsWith('2x1') ||
                          id.startsWith('3x1') ||
                          id.startsWith('4x1') ||
                          id.startsWith('5x1') ||
                          id.startsWith('6x1') ||
                          id.startsWith('7x1') ||
                          id.startsWith('8x1') ||
                          id.startsWith('9x1') ||
                          id.startsWith('10x1') ||
                          id.startsWith('11x1') ||
                          id.startsWith('12x1') ||
                          id.startsWith('13x1') ||
                          id.startsWith('14x1') ||
                          id.startsWith('15x1') ||
                          id.startsWith('16x1')) {
                        uniqueNumbers.add(text);
                      } else if (id.startsWith('1x2') ||
                          id.startsWith('1x3') ||
                          id.startsWith('1x4') ||
                          id.startsWith('1x5') ||
                          id.startsWith('1x6') ||
                          id.startsWith('1x7')) {
                        uniqueDays.add(text);
                      }
                    }

                    return Column(
                      children: [
                        DropdownButtonFormField<Object>(
                          value: _selectedNumber,
                          items: uniqueNumbers.map((number) {
                            return DropdownMenuItem<Object>(
                              value: number,
                              child: Text('$number'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedNumber = value!;
                            });
                          },
                          decoration: const InputDecoration(
                              labelText: 'Ders Saati Seçiniz'),
                        ),
                        DropdownButtonFormField<Object>(
                          value: _selectedDay,
                          items: uniqueDays.map((day) {
                            return DropdownMenuItem<Object>(
                              value: day,
                              child: Text(day),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDay = value!;
                            });
                          },
                          decoration:
                              const InputDecoration(labelText: 'Gün Seçiniz'),
                        ),
                      ],
                    );
                  } else {
                    return const Text('No lessons available.');
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveLessonData(context);
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

  Future<List<Map<String, String>>> _getHoursFromGridCollection() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('grid').get();
    return querySnapshot.docs
        .map(
            (doc) => {'id': doc['id'] as String, 'text': doc['text'] as String})
        .toList();
  }
}

Future<List<String>> _getTeacherNames() async {
  // Firestore'dan öğretmen adlarını çek
  var querySnapshot =
      await FirebaseFirestore.instance.collection('teachers').get();
  return querySnapshot.docs
      .map((doc) => '${doc['unvan']} ${doc['ad']} ${doc['soyad']}')
      .toList();
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
    String documentId = '$fullName';

    // Check if the document already exists
    var existingDoc = await FirebaseFirestore.instance
        .collection('teachers')
        .doc(documentId)
        .get();

    if (existingDoc.exists) {
      // Document already exists, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu öğretmen zaten ekli.'),
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

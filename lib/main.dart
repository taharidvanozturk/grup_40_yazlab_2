// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grup_40_yazlab_2/firebase_options.dart';

Future<List<String>> _getTeacherNames() async {
  var querySnapshot =
      await FirebaseFirestore.instance.collection('teachers').get();
  return querySnapshot.docs
      .map((doc) => '${doc['unvan']} ${doc['ad']} ${doc['soyad']}')
      .toList();
}

Future<List<Map<String, String>>> _getHoursFromGridCollection() async {
  var querySnapshot = await FirebaseFirestore.instance.collection('grid').get();
  return querySnapshot.docs
      .map((doc) => {
            'id': doc['id'].toString(),
            'text': doc['text'].toString(),
          })
      .toList();
}

Future<List<String>> _getClasses() async {
  var querySnapshot =
      await FirebaseFirestore.instance.collection('classes').get();
  return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
}

String _selectedHour = 'Saat Seçiniz';
String _selectedNumber = 'Ders Saati Seçiniz';
String _selectedTeacher = 'Öğretmen Seçiniz';

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
      title: 'Grup 40 YazLab 2',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 8, 163, 79)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Grup 40 YazLab 2'),
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
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OgretmenEklemeSayfasi(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageDataPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _getClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data != null) {
            List<String> classNames = snapshot.data!;
            return Center(
              child: Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                children: classNames.map((className) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width /
                        2, // half of screen width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ClassSchedulePage(className: className),
                          ),
                        );
                      },
                      child: Text(className),
                    ),
                  );
                }).toList(),
              ),
            );
          } else {
            return const Text(
                'Sınıf bilgileri bulunamadı veya kayıtlı sınıf yok.');
          }
        },
      ),
    );
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
  final TextEditingController _saatController = TextEditingController();
  String? _selectedDay;
  String _selectedClass = 'Sınıf Seçiniz';

  Future<void> _saveLessonData(BuildContext context) async {
    String lessonName = _dersAdiController.text;
    String lessonHour = _selectedHour;
    String teacherName = _selectedTeacher;
    String lessonDay = _selectedDay ?? 'Gün Seçiniz'; // Default value for day
    String className = _selectedClass;

    // Check if the teacher already has a lesson at the same time, day, and class
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .where('lessonHour', isEqualTo: lessonHour)
        .where('lessonDay', isEqualTo: lessonDay)
        .where('teacherName', isEqualTo: teacherName)
        .where('className', isEqualTo: className)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Teacher already has a lesson at this time, day, and class, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Bu öğretmenin günün aynı saatinde dersi var. Lütfen tekrar deneyin.'),
        ),
      );
    } else {
      // No conflicting lessons found, proceed to save the new lesson
      await FirebaseFirestore.instance.collection('lessons').add({
        'lessonName': lessonName,
        'className': className,
        'lessonHour': _selectedHour,
        'lessonDay': lessonDay, // Save the day
        'teacherName': teacherName,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ders Başarıyla Eklendi.'),
        ),
      );

      // Clear form fields
      _dersAdiController.clear();
      _saatController.clear();
      setState(() {
        _selectedTeacher = 'Öğretmen Seçiniz';
        _selectedClass = 'Sınıf Seçiniz';
        _selectedDay = 'Gün Seçiniz';
        _selectedHour = 'Ders Saati Seçiniz';
      });
    }
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
                    return const Text('Öğretmen bulunamadı.');
                  }
                },
              ),
              FutureBuilder<List<String>>(
                future: _getClasses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<String> classNames = snapshot.data!;

                    if (!classNames.contains(_selectedClass)) {
                      _selectedClass = classNames.isNotEmpty
                          ? classNames[0]
                          : 'Sınıf Seçiniz';
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedClass,
                      items: classNames.map((className) {
                        return DropdownMenuItem<String>(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Sınıf'),
                    );
                  } else {
                    return const Text('Sınıf bulunamadı.');
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

                    if (_selectedDay == null ||
                        !uniqueDays.contains(_selectedDay!)) {
                      _selectedDay =
                          uniqueDays.isNotEmpty ? uniqueDays[0] : null;
                    }

                    if (kDebugMode) {
                      print(_selectedNumber);
                    }

                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedNumber,
                          items: [
                            const DropdownMenuItem<String>(
                              value: 'Ders Saati Seçiniz',
                              child: Text('Ders Saati Seçiniz'),
                            ),
                            ...Set.from(uniqueNumbers).map((number) {
                              if (number == 'Ders Saati Seçiniz') {
                                return DropdownMenuItem<String>(
                                  value: number,
                                  child: Text('$number'),
                                );
                              }
                              return DropdownMenuItem<String>(
                                value: number,
                                child: Text('$number'),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedNumber = value!;
                              _selectedHour = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Ders Saati Seçiniz',
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedDay ?? 'Gün Seçiniz',
                          items: uniqueDays.map((day) {
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
                          decoration:
                              const InputDecoration(labelText: 'Gün Seçiniz'),
                        ),
                      ],
                    );
                  } else {
                    return const Text(
                        'Ders bilgileri bulunamadı veya kayıtlı ders yok.');
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
    String documentId = fullName;

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

class ClassSchedulePage extends StatelessWidget {
  final String className;

  const ClassSchedulePage({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$className Sınıfı Haftalık Ders Programı'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('lessons')
            .where('className', isEqualTo: className)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data != null) {
            List<QueryDocumentSnapshot> lessons = snapshot.data!.docs;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                var lesson = lessons[index];
                return Card(
                  child: ListTile(
                    title: Text(lesson['lessonName']),
                    subtitle: Text(
                      '${lesson['lessonDay']}, ${lesson['lessonHour']}, ${lesson['teacherName']}',
                      maxLines: 2, // Adjust based on your needs
                    ),
                  ),
                );
              },
            );
          } else {
            return const Text(
                'Ders bilgileri bulunamadı veya kayıtlı ders yok.');
          }
        },
      ),
    );
  }
}

class ManageDataPage extends StatefulWidget {
  const ManageDataPage({Key? key}) : super(key: key);

  @override
  _ManageDataPageState createState() => _ManageDataPageState();
}

class _ManageDataPageState extends State<ManageDataPage> {
  List<Map<String, dynamic>> _dataList = [];

  @override
  void initState() {
    super.initState();
    _loadLessonsData();
    _loadTeachersData();
    _loadClassesData();
  }

  Future<void> _loadLessonsData() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('lessons').get();
    setState(() {
      _dataList = querySnapshot.docs.map((doc) {
        var data = doc.data();
        return {
          'collectionName': 'lessons',
          'id': doc.id,
          'info': '${data['lessonName']} - ${data['teacherName']}',
          ...data,
        };
      }).toList();
    });
    if (kDebugMode) {
      print(_dataList);
    }
  }

  Future<void> _loadTeachersData() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('teachers').get();
    setState(() {
      _dataList = querySnapshot.docs.map((doc) {
        var data = doc.data();
        return {
          'collectionName': 'teachers',
          'id': doc.id,
          'info': '${data['unvan']} ${data['ad']} ${data['soyad']}',
          ...data,
        };
      }).toList();
    });
    if (kDebugMode) {
      print(_dataList);
    }
  }

  Future<void> _loadClassesData() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      _dataList = querySnapshot.docs.map((doc) {
        var data = doc.data();
        if (kDebugMode) {
          print("Loaded classes data: $data");
        }
        return {
          'collectionName': 'classes',
          'id': doc.id,
          'info': '${data['name']}',
          ...data, // Include all the document's fields
        };
      }).toList();
    });
    if (kDebugMode) {
      print(_dataList);
    }
  }

  Future<void> _loadDataFromCollection(String collectionName) async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    setState(() {
      _dataList = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'collectionName': collectionName,
                ...doc
                    .data()
                    .map((key, value) => MapEntry(key, value.toString())),
              })
          .toList();
    });
  }

  Future<void> _deleteDocument(List<Map<String, dynamic>> dataList) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Silme Onayı'),
          content: const Text('Bu veriyi silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Vazgeç'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () async {
                // Access the collection name and document ID from the data list
                var firstData = dataList.isNotEmpty ? dataList.first : {};
                String collectionName = firstData['collectionName'] ?? '';
                String documentId = firstData['id'] ?? '';

                await FirebaseFirestore.instance
                    .collection(collectionName)
                    .doc(documentId)
                    .delete();

                // Veriyi başarıyla sildiyse, veriyi yeniden yükle
                await _loadDataFromCollection(collectionName);

                // Silme işlemi başarılı olduysa bilgilendirme göster
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veri başarıyla silindi.'),
                  ),
                );

                Navigator.of(context).pop(); // Onay penceresini kapat
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editDocument(Map<String, dynamic> documentData) async {
    var existingData = documentData;
    var formValues = Map<String, dynamic>.from(existingData);

    var editedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        var formFields = existingData.keys.map<Widget>((key) {
          // specify the type here
          if (key == 'info') {
            var words = existingData[key].split(' ');
            return Column(
              children: words.map<Widget>((word) {
                // and here
                return TextFormField(
                  initialValue: word,
                  onChanged: (value) => formValues[key] = value,
                  decoration: InputDecoration(labelText: word),
                );
              }).toList(), // convert the iterable to a list
            );
          } else {
            // For other keys, create a TextFormField as usual
            return TextFormField(
              initialValue: existingData[key],
              onChanged: (value) => formValues[key] = value,
              decoration: InputDecoration(labelText: key),
            );
          }
        }).toList();
        return Dialog(
          insetPadding: EdgeInsets.zero, // remove padding
          child: AlertDialog(
            title: Text('Edit Document'),
            content: SingleChildScrollView(
              // add this to enable scrolling when the content is too large
              child: Column(
                children: formFields,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, formValues);
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    // If the user confirmed the changes, update the document in the Firestore database
    if (editedData != null) {
      // Remove the 'collectionName' and 'id' fields from the editedData map

      if (documentData['collectionName'] != null &&
          documentData['id'] != null) {
        await FirebaseFirestore.instance
            .collection(documentData['collectionName'])
            .doc(documentData['id'])
            .update(editedData);
      } else {
        // Handle the case where 'collectionName' or 'id' is null
        if (kDebugMode) {
          print('collectionName or id is null');
        }
      }
      // Successfully updated message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veri başarıyla güncellendi.'),
        ),
      );

      // Reload the data
      if (documentData['collectionName'] != null) {
        // Reload the data
        await _loadDataFromCollection(documentData['collectionName']);
      } else {
        // Handle the case where 'collectionName' is null
        print('collectionName is null');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veri Düzenleme Ekranı'),
      ),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _loadLessonsData,
                child: const Text('Load Lessons'),
              ),
              ElevatedButton(
                onPressed: _loadTeachersData,
                child: const Text('Load Teachers'),
              ),
              ElevatedButton(
                onPressed: _loadClassesData,
                child: const Text('Load Classes'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _dataList.length,
              itemBuilder: (context, index) {
                var data = _dataList[index];
                return ListTile(
                  title: Text(data['info'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editDocument(_dataList[index]);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteDocument([_dataList[index]]);
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

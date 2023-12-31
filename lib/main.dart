// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grup_40_yazlab_2/firebase_options.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

Future<List<String>> _hocalariGetir() async {
  var querySnapshot =
      await FirebaseFirestore.instance.collection('teachers').get();
  return querySnapshot.docs
      .map((doc) => '${doc['unvan']} ${doc['ad']} ${doc['soyad']}')
      .toList();
}

Future<List<Map<String, String>>> _gridSaatleriGetir() async {
  var querySnapshot = await FirebaseFirestore.instance.collection('grid').get();
  return querySnapshot.docs
      .map((doc) => {
            'id': doc['id'].toString(),
            'text': doc['text'].toString(),
          })
      .toList();
}

Future<List<String>> _siniflariGetir() async {
  var querySnapshot =
      await FirebaseFirestore.instance.collection('classes').get();
  return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
}

String _secilenSaat = 'Saat Seçiniz';
String _selectedNumber = 'Ders Saati Seçiniz';
String _secilenHoca = 'Öğretmen Seçiniz';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grup 40 YazLab 2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 8, 163, 79)),
        useMaterial3: true,
      ),
      home: const AnaSayfa(title: 'Grup 40 YazLab 2'),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key, required this.title});

  final String title;

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class KameraEkrani extends StatelessWidget {
  const KameraEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera Ekranı'),
      ),
      body: Center(
        child: ScalableOCR(
          getScannedText: (text) {
            if (kDebugMode) {
              print(text);
            }
          },
        ),
        // Your ScalableOCR properties
      ),
    );
  }
}

class _AnaSayfaState extends State<AnaSayfa> {
  String text = "";
  final StreamController<String> controller = StreamController<String>();
  void _kameraAc() async {
    // Add your camera-related logic here
    // For example, navigate to a new screen with the camera
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KameraEkrani(),
      ),
    );
  }

  void setText(value) {
    controller.add(value);
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
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
                  builder: (context) => const VeriDuzenlemeEkrani(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<List<String>>(
            future: _siniflariGetir(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data != null) {
                List<String> sinifAdlari = snapshot.data!;
                return Center(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: sinifAdlari.map((sinifAdi) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DersProgramiSayfasi(sinifAdi: sinifAdi),
                              ),
                            );
                          },
                          child: Text(sinifAdi),
                        ),
                      );
                    }).toList(),
                  ),
                );
              } else {
                return const Text(
                  'Sınıf bilgileri bulunamadı veya kayıtlı sınıf yok.',
                );
              }
            },
          ),
          FloatingActionButton(
            onPressed: () {
              _kameraAc();
            },
            child: const Icon(Icons.camera_alt_sharp),
          ),
        ],
      ),
    );
  }
}

class DersEklemeSayfasi extends StatefulWidget {
  const DersEklemeSayfasi({super.key});

  @override
  _DersEklemeSayfasiState createState() => _DersEklemeSayfasiState();
}

class _DersEklemeSayfasiState extends State<DersEklemeSayfasi> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dersAdiController = TextEditingController();
  final TextEditingController _saatController = TextEditingController();
  String? _secilenGun;
  String _secilenSinif = 'Sınıf Seçiniz';

  Future<void> _dersIcerigiKaydet(BuildContext context) async {
    String dersAdi = _dersAdiController.text;
    String dersSaati = _secilenSaat;
    String hocaAdi = _secilenHoca;
    String dersGunu = _secilenGun ?? 'Gün Seçiniz';
    String sinifAdi = _secilenSinif;

    // Check if the teacher already has a lesson at the same time, day, and class
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .where('lessonHour', isEqualTo: dersSaati)
        .where('lessonDay', isEqualTo: dersGunu)
        .where('teacherName', isEqualTo: hocaAdi)
        .where('className', isEqualTo: sinifAdi)
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
        'lessonName': dersAdi,
        'className': sinifAdi,
        'lessonHour': _secilenSaat,
        'lessonDay': dersGunu, // Save the day
        'teacherName': hocaAdi,
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
        _secilenHoca = 'Öğretmen Seçiniz';
        _secilenSinif = 'Sınıf Seçiniz';
        _secilenGun = 'Gün Seçiniz';
        _secilenSaat = 'Ders Saati Seçiniz';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _hocalariGoster();
  }

  Future<void> _hocalariGoster() async {
    // Load teacher names and set initial value for _selectedTeacher
    List<String> hocaAdlari = await _hocalariGetir();
    if (hocaAdlari.isNotEmpty) {
      setState(() {
        _secilenHoca = hocaAdlari[0];
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
                future: _hocalariGetir(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<String> hocaAdlari = snapshot.data!;

                    if (!hocaAdlari.contains(_secilenHoca)) {
                      _secilenHoca = hocaAdlari.isNotEmpty
                          ? hocaAdlari[0]
                          : 'Öğretmen Seçiniz';
                    }

                    return DropdownButtonFormField<String>(
                      value: _secilenHoca,
                      items: hocaAdlari.map((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher,
                          child: Text(teacher),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _secilenHoca = value!;
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
                future: _siniflariGetir(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<String> sinifAdlari = snapshot.data!;

                    if (!sinifAdlari.contains(_secilenSinif)) {
                      _secilenSinif = sinifAdlari.isNotEmpty
                          ? sinifAdlari[0]
                          : 'Sınıf Seçiniz';
                    }

                    return DropdownButtonFormField<String>(
                      value: _secilenSinif,
                      items: sinifAdlari.map((className) {
                        return DropdownMenuItem<String>(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _secilenSinif = value!;
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
                future: _gridSaatleriGetir(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<Map<String, String>> derslerinBilgileri =
                        snapshot.data!;

                    List<String> uniqueNumbers = [];
                    List<String> uniqueDays = [];

                    // Extract unique "text" values for hours and days
                    for (var dersBilgileri in derslerinBilgileri) {
                      String id = dersBilgileri['id']!;
                      String text = dersBilgileri['text']!;
                      if (kDebugMode) {
                        print('ID: $id, Text: $text');
                      } // Add this line for debugging

                      if (id.startsWith('2x1') ||
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

                    // Sort the uniqueNumbers list numerically
                    uniqueNumbers.sort((a, b) {
                      // Extract numerical part from 'a' and 'b'
                      int aNumber = int.parse(a.split('.Ders ')[0]);
                      int bNumber = int.parse(b.split('.Ders ')[0]);

                      return aNumber.compareTo(bNumber);
                    });
                    if (_secilenGun == null ||
                        !uniqueDays.contains(_secilenGun!)) {
                      _secilenGun =
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
                            ...uniqueNumbers.map((number) {
                              if (number == 'Ders Saati Seçiniz') {
                                return DropdownMenuItem<String>(
                                  value: number,
                                  child: Text(number),
                                );
                              }
                              return DropdownMenuItem<String>(
                                value: number,
                                child: Text(number),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedNumber = value!;
                              _secilenSaat = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Ders Saati Seçiniz',
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _secilenGun ?? 'Gün Seçiniz',
                          items: uniqueDays.map((day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(day),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _secilenGun = value!;
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
                    _dersIcerigiKaydet(context);
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
  const OgretmenEklemeSayfasi({super.key});

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
                    _ogretmenBilgiKaydet(context);
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

  void _ogretmenBilgiKaydet(BuildContext context) async {
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

class DersProgramiSayfasi extends StatelessWidget {
  final String sinifAdi;

  const DersProgramiSayfasi({super.key, required this.sinifAdi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$sinifAdi Sınıfı Haftalık Ders Programı'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('lessons')
            .where('className', isEqualTo: sinifAdi)
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

class VeriDuzenlemeEkrani extends StatefulWidget {
  const VeriDuzenlemeEkrani({super.key});

  @override
  _VeriDuzenlemeEkraniState createState() => _VeriDuzenlemeEkraniState();
}

class _VeriDuzenlemeEkraniState extends State<VeriDuzenlemeEkrani> {
  List<Map<String, dynamic>> _veriListesi = [];

  @override
  void initState() {
    super.initState();
    _derslerVeriGoster();
    _hocalarVeriGoster();
    _siniflarVeriGoster();
  }

  Future<void> _derslerVeriGoster() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('lessons').get();
    setState(() {
      _veriListesi = querySnapshot.docs.map((doc) {
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
      print(_veriListesi);
    }
  }

  Future<void> _hocalarVeriGoster() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('teachers').get();
    setState(() {
      _veriListesi = querySnapshot.docs.map((doc) {
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
      print(_veriListesi);
    }
  }

  Future<void> _siniflarVeriGoster() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      _veriListesi = querySnapshot.docs.map((doc) {
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
      print(_veriListesi);
    }
  }

  Future<void> _dbVeriCek(String collectionName) async {
    // Access the collection name and document ID from the data list

    var querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    setState(() {
      _veriListesi = querySnapshot.docs
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

  Future<void> _dbVeriSil(List<Map<String, dynamic>> dataList) async {
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
                await _dbVeriCek(collectionName);

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

  Future<void> _dbVeriDuzenle(Map<String, dynamic> documentData) async {
    var existingData = documentData;
    var formValues = Map<String, dynamic>.from(existingData);

    var editedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        var formFields = existingData.keys
            .where((key) =>
                key != 'collectionName' && key != 'id' && key != 'info')
            .map<Widget>((key) {
          var value = existingData[key];
          if (key == 'info') {
            var words = value.split(' ');
            return Column(
              children: words.map<Widget>((word) {
                return TextFormField(
                  initialValue: word,
                  onChanged: (newValue) => formValues[key] = newValue,
                  decoration: InputDecoration(labelText: word),
                );
              }).toList(),
            );
          } else {
            return TextFormField(
              initialValue: value,
              onChanged: (newValue) => formValues[key] = newValue,
              decoration: InputDecoration(labelText: key),
            );
          }
        }).toList();

        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: AlertDialog(
            title: const Text('Veri Düzenleme'),
            content: SingleChildScrollView(
              child: Column(
                children: formFields,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, formValues);

                  _derslerVeriGoster();
                  _hocalarVeriGoster();
                  _siniflarVeriGoster();
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        );
      },
    );

    // If the user confirmed the changes, update the document in the Firestore database
    if (editedData != null) {
      // Create a map only with the fields that need to be updated
      Map<String, dynamic> updatedData = {};
      formValues.forEach((key, value) {
        if (existingData[key] != value) {
          updatedData[key] = value;
        }
      });

      if (updatedData.isNotEmpty &&
          documentData['collectionName'] != null &&
          documentData['id'] != null) {
        await FirebaseFirestore.instance
            .collection(documentData['collectionName'])
            .doc(documentData['id'])
            .update(updatedData);
      }

      // Successfully updated message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veri başarıyla güncellendi.'),
        ),
      );

      // Reload the data
      if (documentData['collectionName'] != null) {
        await _dbVeriCek(documentData['collectionName']);
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
                onPressed: _derslerVeriGoster,
                child: const Text('Dersleri Getir'),
              ),
              ElevatedButton(
                onPressed: _hocalarVeriGoster,
                child: const Text('Hocaları Getir'),
              ),
              ElevatedButton(
                onPressed: _siniflarVeriGoster,
                child: const Text('Sınıfları Getir'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _veriListesi.length,
              itemBuilder: (context, index) {
                var data = _veriListesi[index];
                return ListTile(
                  title: Text(data['info'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _dbVeriDuzenle(_veriListesi[index]);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _dbVeriSil([_veriListesi[index]]);
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

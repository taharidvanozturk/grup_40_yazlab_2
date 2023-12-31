# Grup 40 2'No lu Yazılım Geliştirme Laboratuvarı-I Projesi

- Bu projede Flutter, Firebase Firestore, ARCore ve flutter_scalable_ocr.dart kütüphanesi kullanılarak bir Firestore veritabanı üzerinde çalışan ders programı uygulaması çalışması yapılmıştır.

- Proje içerisinde sınıfların ders programlarını görüntüleme, sisteme öğretim görevlisi ekleme, ders ekleme ve verileri düzenleme özellikleri bulunmaktadır.

- Proje kodları mümkün olduğunca dinamik çalışacak şekilde yazılmış olup değişmeye uygun bir şekilde oluşturulmaya çalışılmıştır.

## Projenin Çalıştırılması

1. öncelikle gerekli geliştirme ortamlarının kurulu olduğundan emin olunur.
   - VS Code için:
     - Dart Extension
     - Flutter Extension
   - Bilgisayar için:
     - Flutter SDK
     - Android SDK
2. Proje öncelikle 'git clone' komutu kullanılarak istenilen klasöre klonlanır.
3. VS Code'un sağ alt kısmından uygulamayı çalıştırmayı hedeflediğimiz ortam seçilir ve terminal üzerinde 'flutter run' komutu ile ya da main.dart dosyası üzerinde sağ üst kısımdan "Start Debugging" tuşuna tıklanarak proje build edilir ve çalıştırılır.

> [!NOTE]
> Bu proje şu an için sadece Android üzerinde denenmiştir. Diğer platformlarda çalışıp çalışmadığı bilinmemektedir.

> [!WARNING]
> Bu aşamada kullanıcı özelinde sorunlar ortaya çıkabilir. Debug console okunarak hatayı inceleyebilir ve dökümantasyon okuyarak hatayı çözebilirsiniz.

## Uygulama Sayfaları

- Bu bölümde uygulamada bulunan sayfalar tanıtılacaktır.

### Ana Sayfa

<p align="center">
  <img src="photos/anasayfa.jpg" alt="Uygulama Ana Sayfasının Görünüşü"/>
</p>

- Uygulama ana sayfasında sınıf seçim kısmı, OCR fonksiyonu, Ders Ekleme Ekranı, Öğretim Görevlisi Ekleme Ekranı ve Veri Düzenleme Ekranı kısımları bulunmaktadır.

### Sınıf Görünümleri

<p align="center">
  <img src="photos/sinifdersgorunumu.jpg" alt="Örnek Bir Sınıfın Haftalık Ders Programı"/>
</p>
- Sınıf Görünümleri kısmında boyuları içeriğe göre değişken bir Sütun yapısı kullanılmış ve Firestore veritabanı komutları kullanılarak "lessons" koleksiyonundan "className" alanı seçilen sınıfla uyan dersler yüklenmiş ve bir GridView içerisine yerleştirilmiştir.

### Ders Ekleme Ekranı

- Ders ekleme ekranında bir form mantığı kurulmuştur. veritabanı üzerinden alınan veriler gerekli kısımlara dağıtılarak kullanıcının yanlış ya da uyumsuz bir formatta ders eklemesi engellenmeye çalışılmıştır.

#### Ders Ekleme Durumunda Çakışma Kontrolü

- Ders saati, Sınıf, Öğretim Görevlisi müsaitliği ve Günler veritabanı içerisinde bir ders için aynı table'da olup olmadığı kontrol edilerek aynı seçeneklere ders eklenmesi engellenmiştir.

<p align="center">
  <img src="photos/dersekleme.jpg" alt="Ders Ekleme Ekranı"/>
</p>

<p align="center">
  <img src="photos/dersekleme2.jpg" alt="Ders Ekleme Ekranı Dropdown Menu Örneği"/>
</p>

### Öğretim Görevlisi Ekleme Ekranı

- Bu ekranda Öğretim Görevlisinin Ünvanı, Adı ve Soyadı bilgileri alınarak "Ünvan+Ad+Soyad" sıralaması ile dosya ismi olarak ve içerisinde de "unvan", "ad" ve "soyad" field'larına kaydedilmektedir.

<p align="center">
  <img src="photos/hocaekleme.jpg" alt="Öğretim Görevlisi Ekleme Ekranı"/>
</p>

### Veri Düzenleme Ekranı

- Bu ekranda FutureBuilder yapısında QuerySnapshot yöntemi kullanılarak tıklanan butona göre istenen veriler alınarak Ders Ekleme Ekranı'nda ki mantığa benzer bir şekilde dağıtılmaktadır.

#### Veri Düzenleme Tuşu

- Veri düzenleme özelliği için main.dart dosyasındaki "\_dbVeriDuzenle" Future'ı kullanılarak alınan veri bir form'a dağıtılmakta ve form üzerinde düzenlendikten sonra kaydet butonuna basıldığında veritabanında uygun alanlar düzenlenen veri ile güncellenmektedir.

#### Veri Silme Tuşu

- Veri silme özelliği için main.dart dosyasındaki "\_dbVeriSil" Future'ı kullanılarak seçilen verinin collectionName'i ve documentId'si ile eşleşen table silinir.

<p align="center">
  <img src="photos/veriduzenlemeekrani.jpg" alt="Veri Düzenleme Ekranı"/>
</p>

<p align="center">
  <img src="photos/sinifduzenleme.jpg" alt="Sınıf Düzenleme Ekranı"/>
</p>

<p align="center">
  <img src="photos/hocaduzenleme.jpg" alt="Öğretim Görevlisi Düzenleme Ekranı"/>
</p>

## Uygulama Veritabanı Yapısı

- Veritabanı olarak mobil uygulama alanında popüler olması ve Flutter gibi Google tarafından yaratılmış bir sistem olduğundan Firebase tercih edilmiştir.

### Tabloların formatı

- | Koleksiyonlar | Dökümanlar                                                                                                       | Alanlar                                                             |
  | ------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
  | classes       | Döküman Adları Sınıf Adlarından Oluşur                                                                           | "name"                                                              |
  | grid          | Grid Koleksiyonu içerisinde bir haftalık ders programı yapısı ızgaralara bölünüp isimlendirilmiştir              | "color", "id", "text"                                               |
  | lessons       | Derslerin Döküman İsimleri Auto-ID ile verilmiştir                                                               | "className", "lessonDay", "lessonHour", "lessonName", "teacherName" |
  | teachers      | Öğretim Görevlilerinin Döküman İsimleri "unvan", ad" ve "soyad" Alanlarındaki verilier birleştirerek oluşturulur | "unvan", "ad", "soyad"                                              |

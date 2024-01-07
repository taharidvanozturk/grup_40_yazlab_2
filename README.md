## Grup 40 2'No lu Yazılım Geliştirme Laboratuvarı-I Projesi

* Bu projede Flutter, Firebase Firestore, ARCore ve flutter_scalable_ocr.dart kütüphanesi kullanılarak bir Firestore veritabanı üzerinde çalışan ders programı uygulaması çalışması yapılmıştır. 

* Proje içerisinde sınıfların ders programlarını görüntüleme, sisteme öğretim görevlisi ekleme, ders ekleme ve verileri düzenleme özellikleri bulunmaktadır.

* Proje kodları mümkün olduğunca dinamik çalışacak şekilde yazılmış olup değişmeye uygun bir şekilde oluşturulmaya çalışılmıştır.

## Uygulama Sayfaları

* Bu bölümde uygulamada bulunan sayfalar tanıtılacaktır.

### Ana Sayfa

![Uygulama Ana Sayfasının Görünüşü](photos/anasayfa.jpg)

* Uygulama ana sayfasında sınıf seçim kısmı, OCR fonksiyonu, Ders Ekleme Ekranı, Öğretim Görevlisi Ekleme Ekranı ve Veri Düzenleme Ekranı kısımları bulunmaktadır.

### Sınıf Görünümleri

![Örnek Bir Sınıfın Haftalık Ders Programı](photos/sinifdersgorunumu.jpg)

* Sınıf Görünümleri kısmında boyuları içeriğe göre değişken bir Sütun yapısı kullanılmış ve Firestore veritabanı komutları kullanılarak "lessons" koleksiyonundan "className" alanı seçilen sınıfla uyan dersler yüklenmiş ve bir GridView içerisine yerleştirilmiştir.



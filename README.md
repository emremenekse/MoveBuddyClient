# **MoveBuddy**

MoveBuddy, uzaktan çalışanlar veya ofis ortamında uzun süre hareketsiz kalan bireyler için tasarlanmış bir mobil uygulamadır. Bu uygulama, kişilerin hareketsiz yaşam tarzını azaltmalarına yardımcı olmayı amaçlar. Kişiye özel hareket önerileri ve bildirimlerle kullanıcıları motive eder. Kullanıcıların aktiflik seviyelerine, yaşlarına, ofis ortamına uygunluğuna ve diğer faktörlere göre özelleştirilebilir içerikler sunar.

---

## **Özellikler**

- **Kişiye Özel Hareket Önerileri:**
  - Kullanıcıların yaşı, aktiflik seviyesi ve hareket tercihine göre öneriler.
  - Ofis ortamına uygun hareket seçenekleri.

- **Bildirim Sistemi:**
  - Gün boyunca kullanıcıya uygun zamanlarda hatırlatıcı bildirimler.
  - Bildirimlerde hareketin ne olduğu ve nasıl yapılacağına dair bilgiler.

- **Video ve Rehber İçeriği:**
  - Hareketlerin detaylı açıklamaları.
  - Uygulama içerisinde video rehberlerle doğru hareketlerin yapılması.

- **Kullanıcı Aktiflik Seviyesi Takibi:**
  - Günlük hareketlerin kaydedilmesi.
  - Kullanıcıya haftalık raporlar ve öneriler sunulması.

- **Gamifikasyon (Ödül ve Rozetler):**
  - Hareketlerini tamamlayan kullanıcıları motive etmek için rozetler ve sanal ödüller.
  - Kullanıcının ilerlemesini gösteren liderlik tabloları.

---

## **Teknolojiler**

- **Arayüz:** SwiftUI
  - iOS için modern ve hızlı UI geliştirme.
  - Dinamik ve kullanıcı dostu tasarımlar.

- **Backend:** Firebase
  - Kullanıcı yönetimi, bildirim gönderimi ve Firestore veritabanı.

- **Database:** Firebase Firestore
  - Kullanıcı ve hareket verilerinin saklanması.

- **Bildirimler:** Firebase Cloud Messaging (FCM)
  - Gerçek zamanlı ve planlanmış bildirim gönderimleri.

- **Video Hosting:** Firebase Storage
  - Hareket rehberlerinin ve videoların depolanması ve sunulması.

- **Analytics:** Firebase Analytics
  - Kullanıcı davranışını izleme ve özelleştirilebilir raporlar oluşturma.

---

## **Kullanım Senaryoları**

1. **Kayıt ve Giriş:**
   - Kullanıcı, uygulamayı ilk kez açtığında adını, yaşını ve aktiflik seviyesini belirtir.
   - Kullanıcının hareket tercihleri ("ofis ortamında yapılabilir hareketler") kaydedilir.

2. **Bildirim Gönderimi:**
   - Firebase Cloud Messaging kullanılarak, belirli zaman aralıklarında kullanıcıya hareket önerileri bildirimleri gönderilir.
   - Örneğin: "5 dakika boyunca oturduğunuz yerde esneme hareketi yapın."

3. **Hareket Rehberi:**
   - Bildirime tıklayan kullanıcı, hareketin nasıl yapılacağını açıklayan bir video veya rehber metni görür.

4. **Geri Bildirim ve İstatistik:**
   - Kullanıcı, tamamladığı hareketleri işaretler.
   - Haftalık raporlarda, kullanıcının tamamladığı hareket sayısı, toplam aktiflik süreleri ve gelecek hafta hedefleri sunulur.

5. **Gamifikasyon ve Motivasyon:**
   - Kullanıcı, belirli sayıda hareket tamamladığında yeni seviyelere geçer ve rozetler kazanır.
   - Bu ödüller, kullanıcıların uygulamaya sadıklığını arttırır.

---

## **Potansiyel Geliştirme Alanları**

- **iOS Dışına Genelleştirme:**
  - Android uygulaması geliştirerek daha geniş bir kullanıcı kitlesine ulaşma.

- **Sağlık Verisi Entegrasyonu:**
  - Apple Health veya Google Fit gibi platformlarla entegre edilerek kullanıcı sağlığı verilerinin takibi.

- **Topluluk ve Sosyal Paylaşım:**
  - Kullanıcıların harekette bulunma motivasyonlarını artıracak sosyal medya bağlantıları veya topluluk desteği.

---

## **Hedefler**

- **Kısa Vadeli:**
  - Uygulamanın iOS versiyonunun yayınlanması ve geri bildirimlerin toplanması.
  - Firebase entegrasyonunun optimize edilmesi.

- **Orta Vadeli:**
  - Android versiyonunun geliştirilmesi ve yayınlanması.
  - Gamifikasyon özelliklerinin detaylandırılması.

- **Uzun Vadeli:**
  - Uluslararası bir uygulama haline gelerek farklı diller ve kültürler için özelleştirme.
  - Şirketler ve ofisler için kurumsal versiyonların sunulması.

---

MoveBuddy, bireylerin sağlıklı ve aktif bir yaşam tarzı benimsemelerine yardımcı olabilecek yenilikçi bir çözüm sunmayı amaçlıyor. İlk adımda iOS için geliştirilecek bu uygulama, gelecekte şirketlerin çalışanlarına da katkı sağlayacak kurumsal bir çözüm haline gelebilir.



Ekran Listesi: 

1. Hoş Geldiniz / Onboarding Ekranı
Uygulamayı ilk kez açan kullanıcıları karşılayan tanıtım ekranları.
Uygulamanın temel özelliklerini anlatan slaytlar (ör. hareket hatırlatıcıları, video rehberler).
Başlat / Giriş Yap butonları.
2. Kayıt ve Giriş Ekranı
Kayıt Ol: Kullanıcı adı, e-posta, şifre ve yaş gibi bilgilerin girildiği form.
Giriş Yap: Mevcut kullanıcılar için e-posta ve şifre ile giriş.
Şifre sıfırlama seçeneği.
Firebase Authentication kullanılabilir.
3. Profil Ayarları Ekranı
Kullanıcı bilgilerini düzenleme (isim, yaş, aktiflik seviyesi, tercih edilen hareket türleri).
Bildirim zamanlamalarını özelleştirme.
Hedef belirleme (ör. günlük hareket süresi).
4. Ana Sayfa / Dashboard
Kullanıcının günlük hedefleri ve mevcut durumu.
Hareket önerilerinin listesi (önerilen ve tamamlanan hareketler).
Haftalık istatistiklere hızlı erişim.
5. Hareket Detay Ekranı
Hareketin nasıl yapılacağını açıklayan detaylar.
Video rehber.
Metinsel açıklamalar.
Hareket süresi veya tekrar sayısı bilgisi.
Başlat ve Tamamlandı işaretleme seçenekleri.
6. Bildirim Geçmişi Ekranı
Kullanıcıya gönderilen hareket bildirimlerinin listesi.
Geçmiş hareketleri inceleme ve tekrar etme seçeneği.
7. İstatistik ve Raporlar Ekranı
Günlük, haftalık ve aylık hareket raporları.
Toplam aktiflik süresi, tamamlanan hareket sayısı gibi bilgiler.
İlerlemeyi görselleştirmek için grafikler.
8. Gamifikasyon Ekranı
Kazanılan rozetlerin ve seviyelerin görüntülenmesi.
Tamamlanan görevler ve yeni hedeflerin listesi.
9. Ayarlar Ekranı
Bildirim zamanlarını özelleştirme.
Tema değiştirme (ör. koyu / açık mod).
Dil seçeneği.
Veri temizleme ve çıkış yapma.
10. Yardım ve Destek Ekranı
Sıkça sorulan sorular (SSS).
Geri bildirim gönderme formu.
Uygulama ile ilgili bilgilendirme.
11. Premium / Ücretli Planlar Ekranı (Opsiyonel)
Ek özellikler sunulacaksa, premium planların tanıtımı ve satın alma.
Özelleştirilmiş hareket planları veya özel rehberlik sunulabilir.
12. Çıkış Yapma ve Kullanıcı Silme Ekranı
Kullanıcının hesabını silme ya da uygulamadan çıkış yapma işlemleri.

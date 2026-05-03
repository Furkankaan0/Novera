# Növera iOS App

<div align="center">
  <h3>🏥 Premium Nöbet & Vardiya Yönetimi</h3>
  <p>Sağlık çalışanları için iOS-native, SwiftUI tabanlı profesyonel uygulama</p>

  ![iOS](https://img.shields.io/badge/iOS-17.0+-blue?logo=apple)
  ![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
  ![Xcode](https://img.shields.io/badge/Xcode-15+-blue?logo=xcode)
  ![Codemagic](https://img.shields.io/badge/CI%2FCD-Codemagic-green)
</div>

---

## 📋 Proje Özeti

**Növera**; hemşire, doktor, klinik destek, güvenlik ve teknik personelin nöbetlerini, vardiyalarını, ekip durumunu, gelir hesabını, takvimini ve hatırlatmalarını tek yerden yönetmesini sağlayan premium iOS uygulamasıdır.

### Temel Özellikler

| Modül | Açıklama |
|-------|----------|
| 📅 **Takvim** | Aylık/haftalık/günlük vardiya görünümü, renk kodlu nöbet türleri |
| 📊 **Dashboard** | Günlük özet, haftalık saat grafiği, ekip duyuruları |
| 👥 **Ekip** | Ekip yönetimi, üye rolleri, duyurular, nöbet takası |
| 💰 **Gelir** | Tahmini kazanç hesabı, fazla mesai, gece zammı analizi |
| 🔔 **Bildirimler** | APNs entegrasyonu, nöbet hatırlatmaları |
| ⭐ **Premium** | StoreKit 2 entegrasyonu, 3 plan seçeneği |
| 📱 **Widget** | iOS Home Screen widget desteği |

---

## 🏗 Teknik Mimari

```
Növera/
├── App/                    # Uygulama giriş noktası, router, global state
├── Core/
│   ├── DesignSystem/       # DesignTokens, renkler, tipografi, animasyonlar
│   ├── Components/         # GlassCard, NoveraButton, StatCard, TextField
│   ├── Extensions/         # Date, Color, View, String extensions
│   ├── Utilities/          # HapticManager, DateHelper
│   └── Constants/          # Uygulama sabitleri
├── Features/
│   ├── Onboarding/         # 5 ekranlı premium onboarding
│   ├── Dashboard/          # Ana ekran, özet kartlar
│   ├── Calendar/           # Takvim görünümleri
│   ├── Shifts/             # Vardiya ekle/düzenle/detay
│   ├── Teams/              # Ekip yönetimi
│   ├── Earnings/           # Gelir takibi
│   ├── Notifications/      # Bildirim ayarları
│   ├── Profile/            # Kullanıcı profili
│   ├── Premium/            # Pro paywall
│   └── Widget/             # iOS Widget
├── Data/
│   ├── Models/             # User, Shift, Team, EarningsSummary
│   ├── Repositories/       # ShiftRepository, TeamRepository, UserRepository
│   ├── Local/              # LocalShiftDataSource (UserDefaults → SwiftData)
│   └── Remote/             # RemoteDataSource protokolleri
└── Services/               # AuthService, ShiftService, RevenueCalc, StoreKit...
```

**Mimari:** `SwiftUI + MVVM + Service Layer + Repository Pattern`  
**Offline-first:** Local persistence, sync statusları, conflict resolution altyapısı

---

## 🚀 Windows'tan Geliştirme: Adım Adım Kurulum

### Adım 1: GitHub Repository Oluşturma

```bash
# GitHub.com'da yeni repo oluşturun:
# Repo adı: novera-ios
# Visibility: Private
# .gitignore: Swift

# Yerel klasörü push edin:
git init
git add .
git commit -m "Initial commit: Növera MVP"
git branch -M main
git remote add origin https://github.com/KULLANICI_ADINIZ/novera-ios.git
git push -u origin main
```

### Adım 2: App Store Connect'te Hazırlık

1. [App Store Connect](https://appstoreconnect.apple.com) adresine gidin
2. **Apps** → **+** → **New App** tıklayın
3. Şu bilgileri girin:
   - Platform: **iOS**
   - Name: **Növera**
   - Bundle ID: **com.novera.app**
   - Language: **Turkish**

### Adım 3: App Store Connect API Key Alma

1. App Store Connect → **Users and Access** → **Keys**
2. **Generate API Key** tıklayın
3. Name: `Codemagic CI`  
   Access: `App Manager`
4. `.p8` dosyasını indirin (**sadece bir kez indirilir!**)
5. Not edin:
   - `Issuer ID` (üst kısımda)
   - `Key ID` (indirilen anahtarın yanında)

### Adım 4: Bundle ID & Signing

1. [Apple Developer Portal](https://developer.apple.com) → **Identifiers**
2. **+** → **App IDs** → **App**
3. Bundle ID: `com.novera.app`
4. Capabilities:
   - ✅ Push Notifications
   - ✅ In-App Purchase
   - ✅ Sign In with Apple

### Adım 5: Codemagic Bağlama

1. [codemagic.io](https://codemagic.io) hesabı açın
2. **Add application** → GitHub repo'yu seçin
3. **codemagic.yaml** detect edilecektir
4. **Environment variables** ekleyin:

| Değişken | Değer | Secure |
|----------|-------|--------|
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID'niz | ✅ |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID'niz | ✅ |
| `APP_STORE_CONNECT_PRIVATE_KEY` | .p8 içeriği (tamamı) | ✅ |
| `CERTIFICATE_PRIVATE_KEY` | Codemagic'in oluşturduğu sertifika key | ✅ |

5. **ios_signing** bölümünde: **Generate a new certificate** seçin
6. **Save** ve ilk build'i başlatın

### Adım 6: TestFlight Upload

Build başarılı olduğunda Codemagic otomatik olarak:
- IPA oluşturur
- App Store Connect'e upload eder
- TestFlight'a gönderir

App Store Connect'te **TestFlight** sekmesine gidin → Build'i görün.

### Adım 7: Test Kullanıcısı Ekleme

1. TestFlight → **Internal Testing** → **+**
2. Email ile davet gönderin
3. Kullanıcı cihazına **TestFlight** uygulamasını indirir ve kodu girer

### Adım 8: İlk Beta Yayınlama

1. App Store Connect → TestFlight → **External Testing**
2. **Add External Testers** → Yeni grup oluşturun
3. **Submit for Beta App Review** (ilk seferde Apple incelemesi gerekir, ~24 saat)

---

## 🎨 Tasarım Kararları

### Renk Paleti
- **Primary:** Teal-Blue (`HSL(198°, 78%, 88%)`) — sağlık-teknoloji hissi
- **Accent:** Violet-Purple (`HSL(259°, 65%, 90%)`) — premium aksan
- **Success Green:** Gelir ve pozitif metrikler
- **Arka plan (Light):** Çok hafif mavi-gri (`HSL(206°, 4%, 98%)`)
- **Arka plan (Dark):** Derin lacivert (`HSL(222°, 20%, 8%)`)

### Tasarım Dili
- **Frosted glass cards:** `.ultraThinMaterial` + özel shadow
- **Rounded corners:** 18-32pt continuous corner radius
- **Micro-animations:** Spring animasyonlar, scale efektleri
- **Typography:** SF Pro Display (sistem fontu, her cihazda mükemmel)
- **Haptic feedback:** Her önemli etkileşimde

---

## 🧪 Test Stratejisi

```bash
# Unit testleri çalıştır
xcodebuild test -scheme "Növera" -destination "platform=iOS Simulator,name=iPhone 15 Pro"
```

| Test Dosyası | Kapsam |
|---|---|
| `RevenueCalculationTests` | Gelir hesabı, fazla mesai, gece zammı |
| `ShiftRepositoryTests` | CRUD, overlap, tarih hesaplamaları |

---

## 📦 App Store Hazırlık

### Kısa Açıklama (30 karakter)
```
Sağlık Personeli Nöbet & Vardiya Yönetimi
```

### Uzun Açıklama
```
Növera, sağlık sektöründe çalışan hemşire, doktor, klinik destek personeli 
ve tüm vardiyalı çalışanlar için geliştirilmiş premium bir nöbet ve vardiya 
yönetim uygulamasıdır.

🏥 ANA ÖZELLİKLER

📅 Akıllı Takvim
• Aylık, haftalık ve günlük vardiya görünümleri
• Renk kodlu nöbet türleri: gündüz, gece, icap, tatil, fazla mesai
• iOS takvim entegrasyonu

👥 Ekip Yönetimi
• Ekip oluşturma ve üye yönetimi
• Rol sistemi: Admin, Ekip Sorumlusu, Üye
• Anlık duyurular ve nöbet takas sistemi

💰 Gelir Takibi
• Fazla mesai, gece zammı ve tatil ödemesi hesabı
• Aylık tahmini kazanç analizi
• Özelleştirilebilir ücret ayarları

🔔 Akıllı Bildirimler
• Yaklaşan nöbet hatırlatmaları
• Ekip duyurusu bildirimleri
• Nöbet değişikliği uyarıları

⭐ Növera Pro
• Sınırsız vardiya kaydı
• Gelişmiş gelir analizleri
• iOS Widget desteği
• Akıllı öneriler

NOT: Uygulama yalnızca personelin vardiya ve çalışma verilerini saklar. 
Hasta bilgisi işlenmez.
```

### Anahtar Kelimeler
```
nöbet, vardiya, hemşire, doktor, sağlık, çalışma saati, mesai, takvim, ekip, nöbet takibi
```

### Kategori
**Medical** → Alt kategori: **Health & Fitness**

### Privacy Nutrition Label
| Veri | Kullanım | Kimlikle İlişkili |
|------|---------|-------------------|
| Ad | Kullanıcı profili | Evet |
| Email | Hesap yönetimi | Evet |
| Meslek bilgisi | Uygulama işlevselliği | Evet |
| Vardiya/Çalışma verileri | Uygulama işlevselliği | Hayır |

### TestFlight Beta Açıklaması
```
Növera Beta v1.0'a hoş geldiniz!

Bu sürümde test edebilecekleriniz:
- Premium onboarding akışı
- Vardiya ekleme ve takvim görünümü
- Dashboard istatistikleri
- Ekip yönetimi
- Gelir hesaplama

Geri bildirimlerinizi lütfen TestFlight üzerinden iletin.
Teşekkürler! 🏥
```

### Sürüm Notu (v1.0)
```
Növera'ya hoş geldiniz! 🎉

• Premium onboarding deneyimi
• Aylık/haftalık takvim görünümü  
• Vardiya ekleme ve yönetimi
• Dashboard ile çalışma özeti
• Ekip yönetimi ve duyurular
• Tahmini gelir hesaplama
• Karanlık/Aydınlık mod desteği
```

---

## 🔒 Güvenlik

- Tüm auth token'lar Keychain'de saklanır
- API iletişimi HTTPS-only
- Hasta verisi hiçbir şekilde işlenmez
- KVKK/GDPR uyumlu minimal veri toplama

---

## TODO / Roadmap

- [ ] SwiftData entegrasyonu (UserDefaults'tan migration)
- [ ] Node.js backend bağlantısı
- [ ] Sign in with Apple tam entegrasyonu
- [ ] Apple Watch companion app
- [ ] iCloud sync
- [ ] PDF rapor dışa aktarma
- [ ] Mesai hesabında bordro API entegrasyonu

---

## 📞 İletişim

**Geliştirici:** Növera Team  
**Email:** hello@novera.app  
**Bundle ID:** com.novera.app

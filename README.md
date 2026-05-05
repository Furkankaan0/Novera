# Nöbetim+

Nöbetim+ sağlık çalışanları için iOS’a özel, offline-first nöbet, vardiya, ekip, mesai ve gelir tahmini MVP’sidir.

## Teknik yapı

- Native iOS, SwiftUI, Swift 5.9+, iOS 17+
- MVVM + Clean Architecture klasör düzeni
- SwiftData local storage
- UserNotifications, EventKit, App Intents, WidgetKit placeholder
- StoreKit 2 mock mode ve Apple ile Giriş altyapısı
- XCTest hesaplama motoru testleri
- Codemagic TestFlight workflow

## Codemagic ve TestFlight

1. App Store Connect’te Users and Access > Integrations > App Store Connect API bölümünden API Key oluştur.
2. Codemagic’te `appstore_credentials` environment group oluştur.
3. Şu değişkenleri aynı gruba ekle ve private key değerini Secret olarak işaretle:
   - `APP_STORE_CONNECT_PRIVATE_KEY`: `.p8` dosyasının tamamı.
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`: Key ID.
   - `APP_STORE_CONNECT_ISSUER_ID`: Issuer ID.
4. Bu proje için `codemagic.yaml` değerleri ayarlı:
   - `BUNDLE_ID`: `com.nobetimplus.app`
   - `XCODE_SCHEME`: `NobetimPlus`
   - `APP_STORE_APPLE_ID`: `6766450087`
5. Apple Developer portalında `com.nobetimplus.app` için Bundle ID aç, Sign in with Apple ve App Groups capability’lerini etkinleştir.
6. Codemagic workflow olarak `ios-testflight` çalıştır. Windows üzerinde Xcode kurmadan Mac build ortamında arşiv ve TestFlight yüklemesi yapılır.

Private key `.p8` dosyasını repoya ekleme. `codemagic.yaml` yalnızca Codemagic secret environment variable değerlerini okur.

Kod imzalama notu: Codemagic otomatik signing için App Store Connect API key ile signing files çekmeye çalışır. Codemagic hesabında geçerli Apple Distribution certificate/provisioning profile yoksa Codemagic code signing identities alanından sertifika oluştur veya `CERTIFICATE_PRIVATE_KEY` değişkenini Codemagic’in signing dokümanına göre ekle.

## Sık imzalama sorunları

- Provisioning profile bulunamazsa Bundle ID, team ve capability eşleşmesini kontrol et.
- Sign in with Apple hatasında Apple Developer capability ve entitlements dosyasındaki App ID eşleşmeli.
- App Group hatasında `group.com.nobetimplus.app` Apple Developer’da eklenmiş olmalı.
- TestFlight yükleme hatasında `APP_STORE_APPLE_ID` App Store Connect uygulama Apple ID’si olmalı.
- `APP_STORE_CONNECT_PRIVATE_KEY is missing` hatasında variable group adı `appstore_credentials` olmalı ve workflow bu gruba erişmeli.

## MVP kapsamı

P0 tamam: proje kurulumu, design system, onboarding, dashboard, shift CRUD, takvim, hesaplama motoru, SwiftData local storage, bildirim izni, analiz, profil/ayarlar ve Codemagic.

P1 hazır altyapı: ekip mock, premium paywall, StoreKit 2 mock, WidgetKit dosyası, EventKit export, Smart Insights, localization.

P2 placeholder: swap request, CloudKit sync, PDF/CSV export, App Intents genişletme, gelişmiş ekip rolleri ve backend-ready API layer.

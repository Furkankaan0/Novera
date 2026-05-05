import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var profile: UserProfile

    init(appState: AppState) {
        self.appState = appState
        _profile = State(initialValue: appState.profile)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CinematicBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.large) {
                        hero
                        settingsCard("Profil", systemImage: "person.fill") {
                            TextField("Ad Soyad", text: $profile.fullName)
                            Picker("Rol", selection: $profile.role) {
                                ForEach(UserRole.allCases) { Text($0.localizedTitle).tag($0) }
                            }
                            TextField("Departman", text: $profile.department)
                        }

                        settingsCard("Mesai ve gelir", systemImage: "clock.badge.checkmark.fill") {
                            numericField("Aylık normal çalışma saati", value: $profile.monthlyNormalHours)
                            numericField("Saatlik fazla mesai tahmini ücret", value: $profile.overtimeHourlyRate)
                            numericField("Resmi tatil saatlik tahmini ücret", value: $profile.holidayHourlyRate)
                            numericField("Gece çalışma katsayısı", value: $profile.nightWorkMultiplier)
                            numericField("Döner sermaye / ek ödeme", value: $profile.additionalPayment)
                        }

                        settingsCard("Güvenlik ve erişilebilirlik", systemImage: "lock.shield.fill") {
                            Toggle("Haptic feedback", isOn: $profile.hapticsEnabled)
                            Toggle("Face ID / Touch ID uygulama kilidi", isOn: $profile.appLockEnabled)
                            Text("Uygulama kilidi mimarisi hazır; LocalAuthentication akışı P1’de etkinleştirilebilir.")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }

                        settingsCard("Hesap", systemImage: "apple.logo") {
                            Button("Apple oturumundan çık") {
                                appState.appleSignInManager.signOut()
                                profile.appleUserIdentifier = nil
                                appState.showToast("Oturum kapatıldı")
                            }
                            .frame(minHeight: 44)

                            Button(role: .destructive) {
                                appState.showToast("Hesabımı Sil akışı placeholder olarak hazır")
                            } label: {
                                Text("Hesabımı Sil")
                            }
                            .frame(minHeight: 44)
                        }

                        settingsCard("Gizlilik", systemImage: "hand.raised.fill") {
                            Text("Tutulan veri: vardiya, mesai, ekip mock bilgisi, profil ve ayarlar. Veriler MVP’de cihazda saklanır. Takvim izni yalnızca iPhone Takvim’e aktarma, bildirim izni yalnızca nöbet hatırlatmaları için istenir. Hasta bilgisi girilmemelidir.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(Spacing.large)
                }
            }
            .navigationTitle("Ayarlar")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        appState.updateProfile(profile)
                        appState.showToast("Ayarlar kaydedildi")
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }

    private var hero: some View {
        PremiumGlassPanel(cornerRadius: 30) {
            HStack(spacing: Spacing.medium) {
                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 7) {
                    Text("Kişisel çalışma ayarları")
                        .font(.system(.title2, design: .rounded, weight: .black))
                    Text("Gelir tahmini ve mesai özetleri buradaki değerlere göre hesaplanır.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func settingsCard<Content: View>(_ title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        PremiumGlassPanel(cornerRadius: 26) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Label(title, systemImage: systemImage)
                    .font(Typography.title)
                    .foregroundStyle(DesignColors.secondary)
                content()
            }
        }
    }

    private func numericField(_ title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Spacer()
            TextField(title, value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 98)
                .textFieldStyle(.roundedBorder)
        }
    }
}

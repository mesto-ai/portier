import SwiftUI

struct SettingsView: View {
    @ObservedObject var portService: PortService

    private var lang: AppLanguage { portService.language }

    var body: some View {
        ZStack {
            MestoTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 10) {
                    Button(action: { portService.activeView = .ports }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 11, weight: .semibold))
                            Text(L10n.t("back", lang))
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(MestoTheme.accentMid)
                    }
                    .buttonStyle(.plain)
                    .onHover { h in if h { NSCursor.pointingHand.push() } else { NSCursor.pop() } }

                    Spacer()

                    Text(L10n.t("settings", lang))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MestoTheme.text)

                    Spacer()

                    // Spacer for symmetry
                    Color.clear.frame(width: 50, height: 1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(MestoTheme.bg)
                .overlay(
                    Rectangle().fill(MestoTheme.border).frame(height: 1),
                    alignment: .bottom
                )

                ScrollView {
                    VStack(spacing: 20) {
                        // Appearance Section
                        sectionHeader(L10n.t("appearance", lang))

                        // Dark Mode Toggle
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(MestoTheme.accentMid.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image(systemName: portService.isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(MestoTheme.accentMid)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(L10n.t("dark_mode", lang))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(MestoTheme.text)
                                Text(L10n.t("dark_mode_desc", lang))
                                    .font(.system(size: 10))
                                    .foregroundColor(MestoTheme.textDim)
                            }

                            Spacer()

                            Toggle("", isOn: $portService.isDarkMode)
                                .toggleStyle(.switch)
                                .tint(MestoTheme.accentMid)
                                .labelsHidden()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: MestoTheme.radius)
                                .fill(MestoTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: MestoTheme.radius)
                                        .stroke(MestoTheme.border, lineWidth: 1)
                                )
                        )

                        // Language Section
                        sectionHeader(L10n.t("language", lang))

                        VStack(spacing: 0) {
                            ForEach(Array(AppLanguage.allCases.enumerated()), id: \.element) { index, appLang in
                                Button(action: { portService.language = appLang }) {
                                    HStack(spacing: 12) {
                                        Text(appLang.flag)
                                            .font(.system(size: 20))

                                        Text(appLang.displayName)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(MestoTheme.text)

                                        Spacer()

                                        if portService.language == appLang {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(MestoTheme.mestoGradient)
                                        } else {
                                            Circle()
                                                .stroke(MestoTheme.border, lineWidth: 1.5)
                                                .frame(width: 16, height: 16)
                                        }
                                    }
                                    .padding(12)
                                    .contentShape(Rectangle())
                                    .background(
                                        RoundedRectangle(cornerRadius: portService.language == appLang ? MestoTheme.radius : 0)
                                            .fill(portService.language == appLang ? MestoTheme.accent.opacity(0.08) : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                                .onHover { h in if h { NSCursor.pointingHand.push() } else { NSCursor.pop() } }

                                if index < AppLanguage.allCases.count - 1 {
                                    Rectangle()
                                        .fill(MestoTheme.border)
                                        .frame(height: 1)
                                        .padding(.horizontal, 12)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: MestoTheme.radius)
                                .fill(MestoTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: MestoTheme.radius)
                                        .stroke(MestoTheme.border, lineWidth: 1)
                                )
                        )
                    }
                    .padding(16)
                }
            }
        }
        .preferredColorScheme(portService.isDarkMode ? .dark : .light)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(MestoTheme.textDim)
                .tracking(1.2)
            Spacer()
        }
    }
}

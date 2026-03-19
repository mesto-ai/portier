import SwiftUI

struct AboutView: View {
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

                    Text(L10n.t("about", lang))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MestoTheme.text)

                    Spacer()

                    Color.clear.frame(width: 50, height: 1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(MestoTheme.bg)
                .overlay(
                    Rectangle().fill(MestoTheme.border).frame(height: 1),
                    alignment: .bottom
                )

                Spacer()

                // Content
                VStack(spacing: 24) {
                    // Logo
                    MestoLogo()
                        .frame(width: 80, height: 88)

                    // App name
                    VStack(spacing: 4) {
                        Text(L10n.t("app_name", lang))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(MestoTheme.text)

                        Text("\(L10n.t("version", lang)) 1.0.0")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(MestoTheme.textDim)
                    }

                    // Developed by
                    HStack(spacing: 0) {
                        Text("mesto")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(MestoTheme.textMuted)
                        Text(".ai")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(MestoTheme.mestoGradient)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: MestoTheme.radius)
                            .fill(MestoTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: MestoTheme.radius)
                                    .stroke(MestoTheme.border, lineWidth: 1)
                            )
                    )

                    // Description
                    Text(L10n.t("about_desc", lang))
                        .font(.system(size: 12))
                        .foregroundColor(MestoTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Footer
                Text(L10n.t("developed_by", lang))
                    .font(.system(size: 10))
                    .foregroundColor(MestoTheme.textDim)
                    .padding(.bottom, 16)
            }
        }
        .preferredColorScheme(portService.isDarkMode ? .dark : .light)
    }
}

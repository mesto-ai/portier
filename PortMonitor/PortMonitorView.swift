import SwiftUI

struct PortMonitorView: View {
    @ObservedObject var portService: PortService
    @State private var hoveredProcess: Int? // PID
    @State private var hoveredPortDetail: UUID?
    @State private var showKillConfirm: ProcessEntry?

    private var lang: AppLanguage { portService.language }

    var body: some View {
        Group {
            switch portService.activeView {
            case .ports:
                portsView
            case .settings:
                SettingsView(portService: portService)
            case .about:
                AboutView(portService: portService)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: portService.activeView == .ports)
    }

    private var portsView: some View {
        ZStack {
            MestoTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                categoryBar
                Spacer().frame(height: 6)
                filterBar
                processList
                footerView
            }
        }
        .preferredColorScheme(portService.isDarkMode ? .dark : .light)
        .alert(L10n.t("kill_process", lang), isPresented: Binding(
            get: { showKillConfirm != nil },
            set: { if !$0 { showKillConfirm = nil } }
        )) {
            Button(L10n.t("cancel", lang), role: .cancel) { showKillConfirm = nil }
            Button(L10n.t("terminate", lang), role: .destructive) {
                if let proc = showKillConfirm {
                    _ = portService.killProcess(pid: proc.pid)
                }
                showKillConfirm = nil
            }
        } message: {
            if let proc = showKillConfirm {
                let portList = proc.ports.map { String($0.port) }.joined(separator: ", ")
                Text(verbatim: "\(proc.processName) (PID: \(proc.pid)) \(L10n.t("kill_confirm", lang))\nPort \(portList) \(L10n.t("ports_freed", lang)).")
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 10) {
            MestoLogo()
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 1) {
                Text("Portier")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(MestoTheme.text)
                HStack(spacing: 0) {
                    Text("mesto")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(MestoTheme.textDim)
                    Text(".ai")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(MestoTheme.mestoGradient)
                }
            }

            Spacer()

            Button(action: { portService.refresh() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(MestoTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(MestoTheme.border, lineWidth: 1)
                        )
                        .frame(width: 28, height: 28)
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(MestoTheme.textMuted)
                        .rotationEffect(.degrees(portService.isLoading ? 360 : 0))
                        .animation(
                            portService.isLoading ?
                                .linear(duration: 0.8).repeatForever(autoreverses: false) :
                                .default,
                            value: portService.isLoading
                        )
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 4) {
                Circle()
                    .fill(MestoTheme.success)
                    .frame(width: 6, height: 6)
                Text(verbatim: "\(portService.totalPortCount)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(MestoTheme.text)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(MestoTheme.success.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MestoTheme.success.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(MestoTheme.bg)
    }

    // MARK: - Category Bar
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                CategoryChip(
                    icon: "square.grid.2x2.fill",
                    title: L10n.t("all", lang),
                    count: portService.processes.reduce(0) { $0 + $1.ports.count },
                    color: MestoTheme.text,
                    isSelected: portService.selectedCategory == nil,
                    useGradient: true,
                    action: { portService.selectedCategory = nil }
                )

                ForEach(PortCategory.allCases) { cat in
                    let count = portService.categoryCounts[cat] ?? 0
                    if count > 0 {
                        CategoryChip(
                            icon: cat.icon,
                            title: cat.localizedName(lang),
                            count: count,
                            color: cat.color,
                            isSelected: portService.selectedCategory == cat,
                            action: {
                                portService.selectedCategory = portService.selectedCategory == cat ? nil : cat
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(MestoTheme.bg)
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(MestoTheme.textDim)
                TextField(L10n.t("search_placeholder", lang), text: $portService.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(MestoTheme.text)
                if !portService.searchText.isEmpty {
                    Button(action: { portService.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(MestoTheme.textDim)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: MestoTheme.radius)
                    .fill(MestoTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: MestoTheme.radius)
                            .stroke(MestoTheme.border, lineWidth: 1)
                    )
            )

            HStack(spacing: 6) {
                ForEach(PortService.FilterType.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.localizedName(lang),
                        isSelected: portService.filterType == filter,
                        action: { portService.filterType = filter }
                    )
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(MestoTheme.bg)
        .overlay(
            Rectangle()
                .fill(MestoTheme.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Process List (Grouped by Category)
    private var processList: some View {
        ScrollView {
            if portService.filteredProcesses.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 2) {
                    ForEach(portService.groupedByCategory) { group in
                        SectionHeader(
                            category: group.category,
                            count: group.totalPorts,
                            processCount: group.processes.count,
                            isCollapsed: portService.collapsedCategories.contains(group.category.rawValue),
                            lang: lang,
                            onToggle: { portService.toggleCategory(group.category) }
                        )

                        if !portService.collapsedCategories.contains(group.category.rawValue) {
                            ForEach(group.processes) { proc in
                                ProcessRow(
                                    process: proc,
                                    isHovered: hoveredProcess == proc.pid,
                                    isExpanded: portService.expandedProcesses.contains(proc.pid),
                                    lang: lang,
                                    onKill: { showKillConfirm = proc },
                                    onToggleExpand: { portService.toggleProcessExpand(proc.pid) },
                                    onOpenBrowser: { port in portService.openInBrowser(port: port) }
                                )
                                .onHover { isHovered in
                                    hoveredProcess = isHovered ? proc.pid : nil
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .background(MestoTheme.bg)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 32))
                .foregroundStyle(MestoTheme.mestoGradient)
            Text(L10n.t("no_ports", lang))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(MestoTheme.textMuted)
            Text(L10n.t("no_ports_desc", lang))
                .font(.system(size: 11))
                .foregroundColor(MestoTheme.textDim)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Footer
    private var footerView: some View {
        HStack(spacing: 8) {
            Text(L10n.t("auto_refresh", lang))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(MestoTheme.textDim)

            Spacer()

            // Settings button
            Button(action: { portService.activeView = .settings }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 11))
                    .foregroundColor(MestoTheme.textDim)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(MestoTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(MestoTheme.border, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .onHover { h in if h { NSCursor.pointingHand.push() } else { NSCursor.pop() } }
            .help(L10n.t("settings", lang))

            // About button
            Button(action: { portService.activeView = .about }) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 11))
                    .foregroundColor(MestoTheme.textDim)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(MestoTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(MestoTheme.border, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .onHover { h in if h { NSCursor.pointingHand.push() } else { NSCursor.pop() } }
            .help(L10n.t("about", lang))

            // Quit button
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                        .font(.system(size: 9))
                    Text(L10n.t("quit", lang))
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(MestoTheme.textDim)
            }
            .buttonStyle(.plain)
            .onHover { h in if h { NSCursor.pointingHand.push() } else { NSCursor.pop() } }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(MestoTheme.bg)
        .overlay(
            Rectangle().fill(MestoTheme.border).frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Process Row (PID bazlı, portları kompakt gösterir)
struct ProcessRow: View {
    let process: ProcessEntry
    let isHovered: Bool
    let isExpanded: Bool
    let lang: AppLanguage
    let onKill: () -> Void
    let onToggleExpand: () -> Void
    let onOpenBrowser: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Ana satır
            HStack(spacing: 10) {
                appIconView

                VStack(alignment: .leading, spacing: 4) {
                    // Süreç adı + açıklama
                    HStack(spacing: 6) {
                        Text(process.processName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(MestoTheme.text)
                            .lineLimit(1)

                        if process.ports.count > 1 {
                            Text(verbatim: "\(process.ports.count) port")
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(process.category.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(process.category.color.opacity(0.1))
                                )
                        }
                    }

                    if let desc = process.localizedDescription(lang) {
                        Text(desc)
                            .font(.system(size: 10))
                            .foregroundColor(MestoTheme.textMuted)
                            .lineLimit(1)
                    }

                    // Port badge'leri (kompakt)
                    portBadges
                }

                Spacer()

                // Aksiyon butonları
                if isHovered {
                    HStack(spacing: 6) {
                        // Çoklu port varsa genişlet butonu
                        if process.ports.count > 1 {
                            Button(action: onToggleExpand) {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(MestoTheme.textMuted)
                                    .frame(width: 22, height: 22)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(MestoTheme.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(MestoTheme.border, lineWidth: 1)
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        // Web erişimi
                        if let firstWeb = process.ports.first(where: { $0.isWebAccessible }) {
                            Button(action: { onOpenBrowser(firstWeb.port) }) {
                                Image(systemName: "safari")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(MestoTheme.accentMid)
                                    .frame(width: 22, height: 22)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(MestoTheme.accentMid.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(MestoTheme.accentMid.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                            .help(L10n.t("open_browser", lang))
                        }

                        // Kill
                        Button(action: onKill) {
                            Image(systemName: "xmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(MestoTheme.error)
                                .frame(width: 22, height: 22)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(MestoTheme.error.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(MestoTheme.error.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .help(L10n.t("terminate_process", lang))
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)

            // Genişletilmiş port detayları
            if isExpanded && process.ports.count > 1 {
                expandedPortList
            }
        }
        .background(
            RoundedRectangle(cornerRadius: MestoTheme.radius)
                .fill(isHovered ? MestoTheme.surface : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: MestoTheme.radius)
                        .stroke(isHovered ? MestoTheme.border : Color.clear, lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }

    // Port badge'leri - her zaman max 3, fazlası "+N"
    private var portBadges: some View {
        let portsToShow = Array(process.ports.prefix(3))
        let remaining = max(0, process.ports.count - 3)

        return HStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: "number")
                    .font(.system(size: 8))
                Text(verbatim: "\(process.pid)")
                    .font(.system(size: 10, design: .monospaced))
            }
            .foregroundColor(MestoTheme.textDim)

            ForEach(portsToShow) { port in
                HStack(spacing: 2) {
                    Circle()
                        .fill(port.state == "LISTEN" ? MestoTheme.success : MestoTheme.accentMid)
                        .frame(width: 4, height: 4)
                    Text(verbatim: "\(port.port)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                }
                .foregroundColor(MestoTheme.accent)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(MestoTheme.accent.opacity(0.08))
                )
            }

            if remaining > 0 {
                Text(verbatim: "+\(remaining)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(MestoTheme.textDim)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(MestoTheme.border.opacity(0.5))
                    )
                    .onTapGesture { onToggleExpand() }
            }
        }
    }

    // Genişletilmiş port listesi
    private var expandedPortList: some View {
        VStack(spacing: 2) {
            ForEach(process.ports) { port in
                HStack(spacing: 8) {
                    Circle()
                        .fill(port.state == "LISTEN" ? MestoTheme.success : MestoTheme.accentMid)
                        .frame(width: 5, height: 5)

                    Text(verbatim: ":\(port.port)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(MestoTheme.accent)
                        .frame(width: 60, alignment: .leading)

                    Text(port.state)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(port.state == "LISTEN" ? MestoTheme.success : MestoTheme.accentMid)

                    Text(port.displayAddress)
                        .font(.system(size: 9))
                        .foregroundColor(MestoTheme.textDim)
                        .lineLimit(1)

                    Spacer()

                    if port.isWebAccessible {
                        Button(action: { onOpenBrowser(port.port) }) {
                            Image(systemName: "safari")
                                .font(.system(size: 9))
                                .foregroundColor(MestoTheme.accentMid)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 52)
                .padding(.vertical, 3)
            }
        }
        .padding(.bottom, 6)
        .transition(.opacity)
    }

    @ViewBuilder
    private var appIconView: some View {
        if let nsIcon = process.appIcon {
            Image(nsImage: nsIcon)
                .resizable()
                .interpolation(.high)
                .frame(width: 32, height: 32)
                .cornerRadius(7)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(process.category.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(process.category.color.opacity(0.2), lineWidth: 1)
                    )
                    .frame(width: 32, height: 32)
                Image(systemName: process.category.icon)
                    .font(.system(size: 12))
                    .foregroundColor(process.category.color)
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let category: PortCategory
    let count: Int
    let processCount: Int
    let isCollapsed: Bool
    let lang: AppLanguage
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(category.color)
                    .frame(width: 16)

                Text(category.localizedName(lang))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(MestoTheme.text)

                Text(verbatim: "\(processCount) \(L10n.t("process_count", lang)) · \(count) \(L10n.t("port_count", lang))")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(category.color.opacity(0.7))

                Spacer()

                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(MestoTheme.textDim)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(category.color.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(category.color.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
        .padding(.bottom, 2)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    let isSelected: Bool
    let useGradient: Bool
    let action: () -> Void

    init(icon: String, title: String, count: Int, color: Color, isSelected: Bool, useGradient: Bool = false, action: @escaping () -> Void) {
        self.icon = icon; self.title = title; self.count = count
        self.color = color; self.isSelected = isSelected
        self.useGradient = useGradient; self.action = action
    }

    @ViewBuilder
    private var chipBackgroundView: some View {
        if isSelected && useGradient {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [MestoTheme.accent, MestoTheme.accentMid, MestoTheme.accentEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        } else if isSelected {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(MestoTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(MestoTheme.border, lineWidth: 1)
                )
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                Text(verbatim: "\(count)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : color)
            }
            .foregroundColor(isSelected ? .white : MestoTheme.textMuted)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(chipBackgroundView)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : MestoTheme.textMuted)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(MestoTheme.mestoGradient)
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(MestoTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(MestoTheme.border, lineWidth: 1)
                                )
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

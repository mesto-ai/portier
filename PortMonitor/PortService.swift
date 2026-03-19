import Foundation
import AppKit
import Combine
import SwiftUI

// MARK: - Kategori Sistemi (5 net kategori)

enum PortCategory: String, CaseIterable, Identifiable {
    case development = "Geliştirme"
    case apps        = "Uygulamalar"
    case browsers    = "Tarayıcılar"
    case infra       = "Altyapı"
    case system      = "Sistem"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .development: return "hammer.fill"
        case .apps:        return "square.grid.2x2.fill"
        case .browsers:    return "globe"
        case .infra:       return "server.rack"
        case .system:      return "gearshape.2.fill"
        }
    }

    var color: Color {
        switch self {
        case .development: return Color(hex: "#22c55e")   // yeşil
        case .apps:        return Color(hex: "#8A2BE2")    // mor
        case .browsers:    return Color(hex: "#0066FF")    // mavi
        case .infra:       return Color(hex: "#fc6d26")    // turuncu
        case .system:      return Color(hex: "#8b92a0")    // gri
        }
    }

    var sortOrder: Int {
        switch self {
        case .development: return 0
        case .apps:        return 1
        case .browsers:    return 2
        case .infra:       return 3
        case .system:      return 4
        }
    }

    func localizedName(_ lang: AppLanguage) -> String {
        switch self {
        case .development: return L10n.t("development", lang)
        case .apps:        return L10n.t("apps", lang)
        case .browsers:    return L10n.t("browsers", lang)
        case .infra:       return L10n.t("infra", lang)
        case .system:      return L10n.t("system", lang)
        }
    }

    /// Temizlenmiş süreç adı + port'tan kategori belirle
    static func categorize(_ name: String, port: Int) -> PortCategory {
        let lower = name.lowercased()

        // ── Tarayıcılar ──
        let browsers = ["google chrome", "firefox", "safari", "brave", "arc", "opera", "edge", "webkit", "chromium"]
        if browsers.contains(where: { lower.contains($0) }) { return .browsers }

        // ── Geliştirme: editörler, runtime'lar, sunucular ──
        let devTools = [
            // Editör & IDE
            "vs code", "code", "cursor", "zed", "sublime", "atom", "vim", "nvim", "emacs",
            "idea", "webstorm", "phpstorm", "pycharm", "rubymine", "goland", "clion", "fleet",
            "android studio",
            // Runtime & Sunucu
            "node", "python", "ruby", "php", "java", "go", "deno", "bun",
            "cargo", "rustc", "dotnet", "swift", "swiftc", "beam.smp", "erl", "elixir",
            // Build & Dev Server
            "vite", "webpack", "esbuild", "turbopack", "next-server", "tsx", "npx",
            "flask", "uvicorn", "gunicorn", "django", "rails", "puma", "express",
            "hugo", "jekyll", "gatsby", "storybook",
            "gradle", "maven", "sbt",
            // Git & AI araçları
            "github", "claude code", "claude",
        ]
        if devTools.contains(where: { lower.contains($0) }) { return .development }

        // ── Altyapı: DB, container, web sunucu, ağ ──
        let infra = [
            // Veritabanı
            "postgres", "mysql", "mongo", "redis", "memcached", "elastic",
            "mariadb", "sqlite", "couchdb", "cassandra", "neo4j", "influxd", "clickhouse", "cockroach",
            // Container
            "docker", "containerd", "podman", "kubectl", "kubelet", "k3s", "minikube", "colima",
            // Web Sunucu
            "nginx", "httpd", "apache", "caddy", "traefik",
            // Ağ
            "sshd", "ssh", "openvpn", "wireguard", "tor", "privoxy", "squid",
            "tailscaled", "cloudflared",
        ]
        if infra.contains(where: { lower.contains($0) }) { return .infra }

        // ── Sistem: macOS daemon'ları ve widget'lar ──
        let systemProcs = [
            "identity", "rapport", "sharing", "control center", "system ui",
            "login window", "mdns", "airplay", "launchd", "cups", "bluetooth",
            "coreaudio", "configd", "powerd", "symptom", "location", "notify",
            "kernel", "user activity", "core services", "spotlight", "window server",
            "universal", "trustd", "apsd", "cloud", "nsurlsession",
            "wifi", "remoted", "timed", "biome", "ntpd", "syslog", "cron",
            "weather", "stocks", "ftp",
        ]
        if systemProcs.contains(where: { lower.contains($0) }) { return .system }

        // ── Bilinen dev portları ──
        let devPorts: Set<Int> = [3000, 3001, 3002, 4000, 4200, 4321, 5000, 5001, 5173, 5174, 5500, 8000, 8080, 8081, 8888, 9000, 9090]
        if devPorts.contains(port) { return .development }

        // ── Geri kalan her şey: Uygulamalar ──
        // Figma, Slack, Discord, Spotify, Claude, Zoom, Teams, Telegram, vb.
        return .apps
    }
}

// MARK: - Süreç Adı Temizleme

func cleanProcessName(_ raw: String) -> String {
    // \x20 gibi hex escape'leri çöz
    var cleaned = raw
    let regex = try? NSRegularExpression(pattern: "\\\\x([0-9a-fA-F]{2})")
    if let regex = regex {
        let range = NSRange(cleaned.startIndex..., in: cleaned)
        let matches = regex.matches(in: cleaned, range: range).reversed()
        for match in matches {
            if let hexRange = Range(match.range(at: 1), in: cleaned),
               let code = UInt8(cleaned[hexRange], radix: 16) {
                let char = String(UnicodeScalar(code))
                let fullRange = Range(match.range, in: cleaned)!
                cleaned.replaceSubrange(fullRange, with: char)
            }
        }
    }

    // Bilinen kesik adları okunabilir isme eşle (sıra önemli, uzun prefix önce)
    let prefixMap: [(prefix: String, display: String)] = [
        // VS Code
        ("Code Helper", "VS Code"),
        ("Code H",      "VS Code"),
        // Chrome
        ("Google Chr",  "Google Chrome"),
        ("Google",      "Google Chrome"),
        // Apple Sistem
        ("identitys",   "Identity Services"),
        ("rapportd",    "Rapport Daemon"),
        ("sharingd",    "Sharing Daemon"),
        ("controlce",   "Control Center"),
        ("ControlCe",   "Control Center"),
        ("systemuise",  "System UI Server"),
        ("loginwindo",  "Login Window"),
        ("mdnsrespond", "mDNS Responder"),
        ("airplayxpc",  "AirPlay"),
        ("airplayd",    "AirPlay"),
        ("useractivi",  "User Activity"),
        ("coreservic",  "Core Services"),
        ("kernelmanag", "Kernel Manager"),
        ("universala",  "Universal Access"),
        ("wifivelocit", "WiFi Velocity"),
        ("nsurlsessio", "NSURLSession"),
        ("biomeagent",  "Biome Agent"),
        ("WeatherWi",   "Weather Widget"),
        ("StocksWid",   "Stocks Widget"),
        // Uygulamalar
        ("Figma ",      "Figma"),
        ("figma_age",   "Figma Agent"),
        ("Slack ",      "Slack"),
        ("microsoft t", "Microsoft Teams"),
        ("zoom.us",     "Zoom"),
        ("Electron H",  "Electron App"),
        ("Electron",    "Electron App"),
        // CLI araçları
        ("claude",      "Claude Code"),
    ]

    let cleanedLower = cleaned.lowercased()
    for entry in prefixMap {
        if cleanedLower.hasPrefix(entry.prefix.lowercased()) {
            return entry.display
        }
    }

    return cleaned
}

// MARK: - Port Detail

struct PortDetail: Identifiable, Hashable {
    let id = UUID()
    let port: Int
    let state: String
    let address: String
    let type: String

    var displayAddress: String {
        if address.contains("*") || address.contains("0.0.0.0") {
            return "All Interfaces"
        } else if address.contains("127.0.0.1") || address.contains("[::1]") {
            return "Localhost"
        } else {
            return address
        }
    }

    var isWebAccessible: Bool {
        guard state == "LISTEN" else { return false }
        let webPorts: Set<Int> = [80, 443, 3000, 3001, 3002, 4000, 4200, 4321, 5000, 5001, 5173, 5174, 5500, 8000, 8080, 8081, 8443, 8888, 9000, 9090]
        return webPorts.contains(port)
    }

    var browserURL: URL? {
        guard isWebAccessible else { return nil }
        let scheme = (port == 443 || port == 8443) ? "https" : "http"
        return URL(string: "\(scheme)://localhost:\(port)")
    }

    func hash(into hasher: inout Hasher) { hasher.combine(port) }
    static func == (lhs: PortDetail, rhs: PortDetail) -> Bool { lhs.port == rhs.port }
}

// MARK: - Process Entry

struct ProcessEntry: Identifiable {
    let pid: Int
    let processName: String
    let appIcon: NSImage?
    let category: PortCategory
    let user: String
    let ports: [PortDetail]

    var id: Int { pid }

    var hasWebPorts: Bool {
        ports.contains { $0.isWebAccessible }
    }

    var processDescription: String? {
        localizedDescription(.en)
    }

    func localizedDescription(_ lang: AppLanguage) -> String? {
        switch processName {
        case "Identity Services": return L10n.t("desc_identity", lang)
        case "Rapport Daemon":    return L10n.t("desc_rapport", lang)
        case "Sharing Daemon":    return L10n.t("desc_sharing", lang)
        case "Control Center":    return L10n.t("desc_control_center", lang)
        case "System UI Server":  return L10n.t("desc_system_ui", lang)
        case "Login Window":      return L10n.t("desc_login_window", lang)
        case "mDNS Responder":    return L10n.t("desc_mdns", lang)
        case "AirPlay":           return L10n.t("desc_airplay", lang)
        case "Weather Widget":    return L10n.t("desc_weather", lang)
        case "Stocks Widget":     return L10n.t("desc_stocks", lang)
        case "Google Chrome":     return L10n.t("desc_chrome", lang)
        case "Firefox":           return L10n.t("desc_firefox", lang)
        case "Safari":            return L10n.t("desc_safari", lang)
        case "VS Code":           return L10n.t("desc_vscode", lang)
        case "GitHub":            return L10n.t("desc_github", lang)
        case "Figma Agent":       return L10n.t("desc_figma_agent", lang)
        case "Figma":             return L10n.t("desc_figma", lang)
        case "Slack":             return L10n.t("desc_slack", lang)
        case "Discord":           return L10n.t("desc_discord", lang)
        case "Spotify":           return L10n.t("desc_spotify", lang)
        case "Zoom":              return L10n.t("desc_zoom", lang)
        case "Microsoft Teams":   return L10n.t("desc_teams", lang)
        case "Telegram":          return L10n.t("desc_telegram", lang)
        default:
            let lower = processName.lowercased()
            if lower.contains("node") { return L10n.t("desc_node", lang) }
            if lower.contains("python") { return L10n.t("desc_python", lang) }
            if lower.contains("java") { return L10n.t("desc_java", lang) }
            if lower.contains("claude") { return L10n.t("desc_claude", lang) }
            if lower.contains("postgres") { return L10n.t("desc_postgres", lang) }
            if lower.contains("mysql") { return L10n.t("desc_mysql", lang) }
            if lower.contains("mongo") { return L10n.t("desc_mongo", lang) }
            if lower.contains("redis") { return L10n.t("desc_redis", lang) }
            if lower.contains("nginx") { return L10n.t("desc_nginx", lang) }
            if lower.contains("docker") { return L10n.t("desc_docker", lang) }
            if lower.contains("ssh") { return L10n.t("desc_ssh", lang) }
            return nil
        }
    }
}

// MARK: - Gruplar

struct CategoryGroup: Identifiable {
    let category: PortCategory
    let processes: [ProcessEntry]
    var id: String { category.rawValue }
    var totalPorts: Int { processes.reduce(0) { $0 + $1.ports.count } }
}

// MARK: - Navigation

enum AppView: Equatable {
    case ports
    case settings
    case about
}

// MARK: - Port Service

class PortService: ObservableObject {
    @Published var processes: [ProcessEntry] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var filterType: FilterType = .all
    @Published var selectedCategory: PortCategory? = nil
    @Published var collapsedCategories: Set<String> = []
    @Published var expandedProcesses: Set<Int> = []

    // Navigation
    @Published var activeView: AppView = .ports

    // Settings
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            MestoTheme.isDark = isDarkMode
        }
    }
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "appLanguage") }
    }

    private var timer: Timer?

    enum FilterType: String, CaseIterable {
        case all = "all"
        case listening = "listening"
        case established = "established"

        func localizedName(_ lang: AppLanguage) -> String {
            switch self {
            case .all: return L10n.t("all", lang)
            case .listening: return L10n.t("listening", lang)
            case .established: return L10n.t("established", lang)
            }
        }
    }

    var filteredProcesses: [ProcessEntry] {
        var result = processes

        switch filterType {
        case .all: break
        case .listening:
            result = result.compactMap { proc in
                let filtered = proc.ports.filter { $0.state == "LISTEN" }
                guard !filtered.isEmpty else { return nil }
                return ProcessEntry(pid: proc.pid, processName: proc.processName, appIcon: proc.appIcon, category: proc.category, user: proc.user, ports: filtered)
            }
        case .established:
            result = result.compactMap { proc in
                let filtered = proc.ports.filter { $0.state != "LISTEN" }
                guard !filtered.isEmpty else { return nil }
                return ProcessEntry(pid: proc.pid, processName: proc.processName, appIcon: proc.appIcon, category: proc.category, user: proc.user, ports: filtered)
            }
        }

        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }

        if !searchText.isEmpty {
            result = result.filter { proc in
                proc.processName.localizedCaseInsensitiveContains(searchText) ||
                String(proc.pid).contains(searchText) ||
                proc.ports.contains { String($0.port).contains(searchText) } ||
                (proc.processDescription?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                proc.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.ports.first?.port ?? 0 < $1.ports.first?.port ?? 0 }
    }

    var groupedByCategory: [CategoryGroup] {
        let procs = filteredProcesses
        var groups: [PortCategory: [ProcessEntry]] = [:]
        for proc in procs {
            groups[proc.category, default: []].append(proc)
        }
        return groups.map { CategoryGroup(category: $0.key, processes: $0.value) }
            .sorted { $0.category.sortOrder < $1.category.sortOrder }
    }

    var categoryCounts: [PortCategory: Int] {
        var counts: [PortCategory: Int] = [:]
        for proc in processes {
            counts[proc.category, default: 0] += proc.ports.count
        }
        return counts
    }

    var totalPortCount: Int {
        filteredProcesses.reduce(0) { $0 + $1.ports.count }
    }

    init() {
        let dark = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
        self.isDarkMode = dark
        MestoTheme.isDark = dark
        let savedLang = UserDefaults.standard.string(forKey: "appLanguage") ?? "tr"
        self.language = AppLanguage(rawValue: savedLang) ?? .tr
        refresh()
        startAutoRefresh()
    }

    func startAutoRefresh() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func refresh() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let newProcesses = self?.fetchProcesses() ?? []
            DispatchQueue.main.async {
                self?.processes = newProcesses
                self?.isLoading = false
            }
        }
    }

    func fetchProcesses() -> [ProcessEntry] {
        let output = runCommand("/usr/sbin/lsof", arguments: ["-i", "-P", "-n"])
        return parseLsofGrouped(output)
    }

    func fetchPorts() -> [PortDetail] {
        fetchProcesses().flatMap { $0.ports }
    }

    func killProcess(pid: Int) -> Bool {
        let result = runCommand("/bin/kill", arguments: ["-9", "\(pid)"])
        let success = result.isEmpty || !result.contains("No such process")
        if success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.refresh()
            }
        }
        return success
    }

    func openInBrowser(port: Int) {
        let scheme = (port == 443 || port == 8443) ? "https" : "http"
        if let url = URL(string: "\(scheme)://localhost:\(port)") {
            NSWorkspace.shared.open(url)
        }
    }

    func toggleCategory(_ category: PortCategory) {
        if collapsedCategories.contains(category.rawValue) {
            collapsedCategories.remove(category.rawValue)
        } else {
            collapsedCategories.insert(category.rawValue)
        }
    }

    func toggleProcessExpand(_ pid: Int) {
        if expandedProcesses.contains(pid) {
            expandedProcesses.remove(pid)
        } else {
            expandedProcesses.insert(pid)
        }
    }

    static func getAppIcon(for pid: Int, processName: String) -> NSImage? {
        if let app = NSRunningApplication(processIdentifier: pid_t(pid)),
           let icon = app.icon,
           app.bundleIdentifier != nil {
            return icon
        }

        let cleanedName = cleanProcessName(processName)
        if let bundleIcon = iconFromKnownBundle(cleanedName) {
            return bundleIcon
        }
        return nil
    }

    private static func iconFromKnownBundle(_ name: String) -> NSImage? {
        let bundleMap: [String: String] = [
            "VS Code":         "com.microsoft.VSCode",
            "Google Chrome":   "com.google.Chrome",
            "Discord":         "com.hnc.Discord",
            "Slack":           "com.tinyspeck.slackmacgap",
            "Spotify":         "com.spotify.client",
            "Figma":           "com.figma.Desktop",
            "Figma Agent":     "com.figma.Desktop",
            "Firefox":         "org.mozilla.firefox",
            "Zoom":            "us.zoom.xos",
            "Microsoft Teams": "com.microsoft.teams2",
            "Telegram":        "ru.keepcoder.Telegram",
            "IntelliJ IDEA":   "com.jetbrains.intellij",
            "WebStorm":        "com.jetbrains.WebStorm",
            "Cursor":          "com.todesktop.230313mzl4w4u92",
            "GitHub":          "com.github.GitHubClient",
        ]

        guard let bundleId = bundleMap[name] else { return nil }
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            return NSWorkspace.shared.icon(forFile: appURL.path)
        }
        return nil
    }

    /// "2.1.52", "10.3" gibi versiyon numarası mı kontrol et
    private static func looksLikeVersion(_ name: String) -> Bool {
        let pattern = #"^\d+[\.\d]+"#
        return name.range(of: pattern, options: .regularExpression) != nil
    }

    /// PID'den ps ile gerçek süreç adını al
    private static func resolveProcessName(pid: Int) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-p", "\(pid)", "-o", "comm="]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do { try process.run(); process.waitUntilExit() } catch { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !output.isEmpty else { return nil }
        // /Applications/Claude.app/Contents/MacOS/claude → claude
        return URL(fileURLWithPath: output).lastPathComponent
    }

    private func runCommand(_ path: String, arguments: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do { try process.run(); process.waitUntilExit() } catch { return "" }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    private func parseLsofGrouped(_ output: String) -> [ProcessEntry] {
        let lines = output.components(separatedBy: "\n")

        struct RawEntry {
            var rawName: String
            var user: String
            var ports: [PortDetail] = []
            var icon: NSImage?
            var seenPorts: Set<Int> = []
        }

        var pidMap: [Int: RawEntry] = [:]

        for line in lines.dropFirst() {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 9 else { continue }

            let rawName = String(parts[0])
            let pid = Int(String(parts[1])) ?? 0
            let user = String(parts[2])
            let typeStr = String(parts[4])

            guard typeStr == "IPv4" || typeStr == "IPv6" else { continue }

            let state: String
            if parts.count >= 10 {
                let lastPart = String(parts[parts.count - 1])
                if lastPart.hasPrefix("(") && lastPart.hasSuffix(")") {
                    state = String(lastPart.dropFirst().dropLast())
                } else {
                    state = "ESTABLISHED"
                }
            } else {
                state = "LISTEN"
            }

            let addressField = String(parts[8])
            let portStr: String
            let address: String

            if addressField.contains("->") {
                let localPart = addressField.components(separatedBy: "->").first ?? ""
                if let lastColon = localPart.lastIndex(of: ":") {
                    portStr = String(localPart[localPart.index(after: lastColon)...])
                    address = String(localPart[..<lastColon])
                } else { continue }
            } else if let lastColon = addressField.lastIndex(of: ":") {
                portStr = String(addressField[addressField.index(after: lastColon)...])
                address = String(addressField[..<lastColon])
            } else { continue }

            guard let port = Int(portStr), port > 0 else { continue }

            let nameField = String(parts.last ?? "")
            let proto = nameField.contains("UDP") ? "UDP" : "TCP"

            if pidMap[pid] == nil {
                // lsof bazen süreç adı yerine versiyon numarası veriyor (ör: "2.1.52")
                // Bu durumda ps ile gerçek adı çek
                var resolvedName = rawName
                if Self.looksLikeVersion(rawName) {
                    resolvedName = Self.resolveProcessName(pid: pid) ?? rawName
                }
                let icon = Self.getAppIcon(for: pid, processName: resolvedName)
                pidMap[pid] = RawEntry(rawName: resolvedName, user: user, icon: icon)
            }

            if pidMap[pid]!.seenPorts.contains(port) { continue }
            pidMap[pid]!.seenPorts.insert(port)

            pidMap[pid]!.ports.append(PortDetail(
                port: port, state: state, address: address, type: proto
            ))
        }

        return pidMap.compactMap { pid, entry in
            guard !entry.ports.isEmpty else { return nil }
            let name = cleanProcessName(entry.rawName)
            let firstPort = entry.ports.first?.port ?? 0
            let category = PortCategory.categorize(name, port: firstPort)
            let sortedPorts = entry.ports.sorted { $0.port < $1.port }

            return ProcessEntry(
                pid: pid, processName: name, appIcon: entry.icon,
                category: category, user: entry.user, ports: sortedPorts
            )
        }
    }
}

import Foundation

// MARK: - Dil Enum

enum AppLanguage: String, CaseIterable {
    case tr = "tr"
    case en = "en"

    var displayName: String {
        switch self {
        case .tr: return "Türkçe"
        case .en: return "English"
        }
    }

    var flag: String {
        switch self {
        case .tr: return "🇹🇷"
        case .en: return "🇬🇧"
        }
    }
}

// MARK: - Localization

struct L10n {
    static func t(_ key: String, _ lang: AppLanguage) -> String {
        translations[lang]?[key] ?? key
    }

    private static let translations: [AppLanguage: [String: String]] = [
        .tr: [
            // Navigation
            "settings": "Ayarlar",
            "about": "Hakkımızda",
            "back": "Geri",

            // Categories
            "all": "Tümü",
            "development": "Geliştirme",
            "apps": "Uygulamalar",
            "browsers": "Tarayıcılar",
            "infra": "Altyapı",
            "system": "Sistem",

            // Filters
            "listening": "Dinleniyor",
            "established": "Bağlı",

            // Search
            "search_placeholder": "Ara... (port, süreç, kategori)",

            // Footer
            "auto_refresh": "Her 5 saniyede yenilenir",
            "quit": "Çıkış",

            // Settings
            "dark_mode": "Koyu Tema",
            "dark_mode_desc": "Arayüz karanlık modda görüntülenir",
            "language": "Dil",
            "language_desc": "Uygulama dilini seçin",
            "appearance": "Görünüm",

            // About
            "app_name": "Portier",
            "version": "Versiyon",
            "developed_by": "mesto.ai tarafından geliştirildi",
            "about_desc": "Sisteminizde aktif olan ağ portlarını ve süreçleri izleyin. Hangi uygulamanın hangi portu kullandığını anında görün.",

            // Process list
            "process_count": "süreç",
            "port_count": "port",
            "kill_process": "Süreci Sonlandır",
            "cancel": "İptal",
            "terminate": "Sonlandır",
            "kill_confirm": "sonlandırılsın mı?",
            "ports_freed": "serbest kalacak",
            "all_interfaces": "Tüm Arayüzler",
            "no_ports": "Aktif port bulunamadı",
            "no_ports_desc": "Tüm portlar kapalı veya filtreyle eşleşen sonuç yok",
            "open_browser": "Tarayıcıda aç",
            "terminate_process": "Süreci sonlandır",

            // Descriptions
            "desc_identity": "Apple Kimlik Servisi (iCloud, iMessage)",
            "desc_rapport": "Apple Cihaz Keşif Servisi",
            "desc_sharing": "AirDrop & Paylaşım Servisi",
            "desc_control_center": "Kontrol Merkezi",
            "desc_system_ui": "Sistem Arayüzü Sunucusu",
            "desc_login_window": "Giriş Penceresi",
            "desc_mdns": "Bonjour DNS Servisi",
            "desc_airplay": "AirPlay Servisi",
            "desc_weather": "Hava Durumu Widget",
            "desc_stocks": "Borsa Widget",
            "desc_chrome": "Web Tarayıcı",
            "desc_firefox": "Web Tarayıcı",
            "desc_safari": "Apple Web Tarayıcı",
            "desc_vscode": "Kod Editörü",
            "desc_github": "GitHub Desktop",
            "desc_figma_agent": "Figma MCP Agent",
            "desc_figma": "UI/UX Tasarım Aracı",
            "desc_slack": "Ekip İletişim Platformu",
            "desc_discord": "Sesli & Yazılı İletişim",
            "desc_spotify": "Müzik Streaming",
            "desc_zoom": "Video Konferans",
            "desc_teams": "Ekip İletişim",
            "desc_telegram": "Mesajlaşma",
            "desc_node": "Node.js Sunucu",
            "desc_python": "Python Uygulaması",
            "desc_java": "Java Uygulaması",
            "desc_claude": "Claude Code CLI",
            "desc_postgres": "PostgreSQL Veritabanı",
            "desc_mysql": "MySQL Veritabanı",
            "desc_mongo": "MongoDB Veritabanı",
            "desc_redis": "Redis Cache",
            "desc_nginx": "Nginx Web Sunucusu",
            "desc_docker": "Docker Container",
            "desc_ssh": "SSH Bağlantısı",
        ],
        .en: [
            // Navigation
            "settings": "Settings",
            "about": "About",
            "back": "Back",

            // Categories
            "all": "All",
            "development": "Development",
            "apps": "Applications",
            "browsers": "Browsers",
            "infra": "Infrastructure",
            "system": "System",

            // Filters
            "listening": "Listening",
            "established": "Connected",

            // Search
            "search_placeholder": "Search... (port, process, category)",

            // Footer
            "auto_refresh": "Refreshes every 5 seconds",
            "quit": "Quit",

            // Settings
            "dark_mode": "Dark Mode",
            "dark_mode_desc": "Display the interface in dark mode",
            "language": "Language",
            "language_desc": "Select application language",
            "appearance": "Appearance",

            // About
            "app_name": "Portier",
            "version": "Version",
            "developed_by": "Developed by mesto.ai",
            "about_desc": "Monitor active network ports and processes on your system. Instantly see which application is using which port.",

            // Process list
            "process_count": "process",
            "port_count": "port",
            "kill_process": "Kill Process",
            "cancel": "Cancel",
            "terminate": "Terminate",
            "kill_confirm": "will be terminated?",
            "ports_freed": "will be freed",
            "all_interfaces": "All Interfaces",
            "no_ports": "No active ports found",
            "no_ports_desc": "All ports are closed or no results match the filter",
            "open_browser": "Open in browser",
            "terminate_process": "Terminate process",

            // Descriptions
            "desc_identity": "Apple Identity Service (iCloud, iMessage)",
            "desc_rapport": "Apple Device Discovery Service",
            "desc_sharing": "AirDrop & Sharing Service",
            "desc_control_center": "Control Center",
            "desc_system_ui": "System UI Server",
            "desc_login_window": "Login Window",
            "desc_mdns": "Bonjour DNS Service",
            "desc_airplay": "AirPlay Service",
            "desc_weather": "Weather Widget",
            "desc_stocks": "Stocks Widget",
            "desc_chrome": "Web Browser",
            "desc_firefox": "Web Browser",
            "desc_safari": "Apple Web Browser",
            "desc_vscode": "Code Editor",
            "desc_github": "GitHub Desktop",
            "desc_figma_agent": "Figma MCP Agent",
            "desc_figma": "UI/UX Design Tool",
            "desc_slack": "Team Communication Platform",
            "desc_discord": "Voice & Text Communication",
            "desc_spotify": "Music Streaming",
            "desc_zoom": "Video Conference",
            "desc_teams": "Team Communication",
            "desc_telegram": "Messaging",
            "desc_node": "Node.js Server",
            "desc_python": "Python Application",
            "desc_java": "Java Application",
            "desc_claude": "Claude Code CLI",
            "desc_postgres": "PostgreSQL Database",
            "desc_mysql": "MySQL Database",
            "desc_mongo": "MongoDB Database",
            "desc_redis": "Redis Cache",
            "desc_nginx": "Nginx Web Server",
            "desc_docker": "Docker Container",
            "desc_ssh": "SSH Connection",
        ],
    ]
}

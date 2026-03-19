#!/bin/bash
set -e

APP_NAME="Portier"
BUNDLE_ID="com.mestoai.portier"
VERSION="1.0.0"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
STAGING_DIR=".build/dmg-staging"

echo "=== Building ${APP_NAME} v${VERSION} ==="

# 1. Release build
echo "→ Compiling (release)..."
swift build -c release

# 2. Create .app bundle structure
echo "→ Creating app bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp "${BUILD_DIR}/PortMonitor" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Copy Info.plist and add missing keys
cat > "${APP_BUNDLE}/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Portier</string>
    <key>CFBundleDisplayName</key>
    <string>Portier</string>
    <key>CFBundleIdentifier</key>
    <string>com.mestoai.portier</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>Portier</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 mesto.ai. All rights reserved.</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.developer-tools</string>
</dict>
</plist>
PLIST

# 3. Generate app icon from the app's own logo (1024x1024 icns)
echo "→ Generating app icon..."
ICONSET_DIR=".build/AppIcon.iconset"
rm -rf "${ICONSET_DIR}"
mkdir -p "${ICONSET_DIR}"

# Create a Swift script to render the app icon
cat > ".build/generate_icon.swift" << 'ICONSCRIPT'
import AppKit

let sizes: [(String, Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

for (name, px) in sizes {
    let size = NSSize(width: px, height: px)
    let image = NSImage(size: size, flipped: false) { rect in
        let scaleX = rect.width / 100
        let scaleY = rect.height / 110

        func p(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
            NSPoint(x: x * scaleX, y: rect.height - y * scaleY)
        }

        // Background: rounded rect with gradient
        let bg = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.22, yRadius: rect.height * 0.22)
        let gradient = NSGradient(starting: NSColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0),
                                  ending: NSColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0))!
        gradient.draw(in: bg, angle: -90)

        let color = NSColor.white

        // Hexagon
        let hex = NSBezierPath()
        hex.move(to: p(50, 12))
        hex.line(to: p(88, 34))
        hex.line(to: p(88, 76))
        hex.line(to: p(50, 98))
        hex.line(to: p(12, 76))
        hex.line(to: p(12, 34))
        hex.close()
        color.withAlphaComponent(0.08).setFill()
        hex.fill()
        color.withAlphaComponent(0.3).setStroke()
        hex.lineWidth = 1.5 * scaleX
        hex.stroke()

        // Center vertical line
        color.setStroke()
        let centerLine = NSBezierPath()
        centerLine.move(to: p(50, 35))
        centerLine.line(to: p(50, 75))
        centerLine.lineWidth = 5 * scaleX
        centerLine.lineCapStyle = .round
        centerLine.stroke()

        // V-shape
        let vLeft = NSBezierPath()
        vLeft.move(to: p(50, 55))
        vLeft.line(to: p(28, 37))
        vLeft.lineWidth = 5 * scaleX
        vLeft.lineCapStyle = .round
        vLeft.stroke()

        let vRight = NSBezierPath()
        vRight.move(to: p(50, 55))
        vRight.line(to: p(72, 37))
        vRight.lineWidth = 5 * scaleX
        vRight.lineCapStyle = .round
        vRight.stroke()

        // Side lines
        color.withAlphaComponent(0.7).setStroke()
        let leftSide = NSBezierPath()
        leftSide.move(to: p(28, 37))
        leftSide.line(to: p(28, 63))
        leftSide.lineWidth = 5 * scaleX
        leftSide.lineCapStyle = .round
        leftSide.stroke()

        let rightSide = NSBezierPath()
        rightSide.move(to: p(72, 37))
        rightSide.line(to: p(72, 63))
        rightSide.lineWidth = 5 * scaleX
        rightSide.lineCapStyle = .round
        rightSide.stroke()

        // Circles - glow effect
        let glowColor = NSColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
        glowColor.setFill()

        let cc = NSBezierPath(ovalIn: NSRect(
            x: (50 - 7) * scaleX, y: rect.height - (55 + 7) * scaleY,
            width: 14 * scaleX, height: 14 * scaleY))
        cc.fill()

        let lc = NSBezierPath(ovalIn: NSRect(
            x: (28 - 5) * scaleX, y: rect.height - (37 + 5) * scaleY,
            width: 10 * scaleX, height: 10 * scaleY))
        lc.fill()

        let rc = NSBezierPath(ovalIn: NSRect(
            x: (72 - 5) * scaleX, y: rect.height - (37 + 5) * scaleY,
            width: 10 * scaleX, height: 10 * scaleY))
        rc.fill()

        return true
    }

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        continue
    }
    let url = URL(fileURLWithPath: ".build/AppIcon.iconset/\(name).png")
    try? png.write(to: url)
}
print("Icons generated.")
ICONSCRIPT

swift ".build/generate_icon.swift"
iconutil -c icns "${ICONSET_DIR}" -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
rm -rf "${ICONSET_DIR}" ".build/generate_icon.swift"

# 4. Ad-hoc sign
echo "→ Signing (ad-hoc)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

# 5. Create DMG
echo "→ Creating DMG..."
rm -rf "${STAGING_DIR}" "${DMG_NAME}"
mkdir -p "${STAGING_DIR}"
cp -R "${APP_BUNDLE}" "${STAGING_DIR}/"
ln -s /Applications "${STAGING_DIR}/Applications"

hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${STAGING_DIR}" \
    -ov -format UDZO \
    "${DMG_NAME}"

rm -rf "${STAGING_DIR}"

# 6. Summary
DMG_SIZE=$(du -h "${DMG_NAME}" | cut -f1)
echo ""
echo "=== Done! ==="
echo "  App:  ${APP_BUNDLE}"
echo "  DMG:  ${DMG_NAME} (${DMG_SIZE})"
echo ""
echo "Next steps:"
echo "  1. Test: open ${DMG_NAME}"
echo "  2. Upload to GitHub Releases"
echo "  3. Users: Right-click → Open on first launch (Gatekeeper bypass)"

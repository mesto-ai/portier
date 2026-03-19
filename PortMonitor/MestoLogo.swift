import SwiftUI

/// Mesto AI logo - SVG'den SwiftUI'a birebir çeviri
/// Orijinal viewBox: 0 0 100 110
struct MestoLogo: View {
    var body: some View {
        Canvas { context, size in
            let scaleX = size.width / 100
            let scaleY = size.height / 110

            // Gradient tanımı: #0066FF → #00CCFF → #8A2BE2 (diagonal)
            let gradient = Gradient(stops: [
                .init(color: MestoTheme.accent, location: 0),
                .init(color: MestoTheme.accentMid, location: 0.5),
                .init(color: MestoTheme.accentEnd, location: 1.0)
            ])
            let linearGradient = GraphicsContext.Shading.linearGradient(
                gradient,
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: size.width, y: size.height)
            )

            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(x: x * scaleX, y: y * scaleY)
            }

            // 1. Hexagon background (opacity 0.2)
            var hexPath = Path()
            hexPath.move(to: p(50, 5))
            hexPath.addLine(to: p(93.3, 30))
            hexPath.addLine(to: p(93.3, 80))
            hexPath.addLine(to: p(50, 105))
            hexPath.addLine(to: p(6.7, 80))
            hexPath.addLine(to: p(6.7, 30))
            hexPath.closeSubpath()

            var hexContext = context
            hexContext.opacity = 0.2
            hexContext.fill(hexPath, with: linearGradient)

            // 2. Center vertical line: M50,35 → 50,75
            var centerLine = Path()
            centerLine.move(to: p(50, 35))
            centerLine.addLine(to: p(50, 75))
            context.stroke(
                centerLine,
                with: linearGradient,
                style: StrokeStyle(lineWidth: 6 * scaleX, lineCap: .round)
            )

            // 3. V-shape lines: 50,55 → 25,35 and 50,55 → 75,35
            var vLeft = Path()
            vLeft.move(to: p(50, 55))
            vLeft.addLine(to: p(25, 35))
            context.stroke(
                vLeft,
                with: linearGradient,
                style: StrokeStyle(lineWidth: 6 * scaleX, lineCap: .round)
            )

            var vRight = Path()
            vRight.move(to: p(50, 55))
            vRight.addLine(to: p(75, 35))
            context.stroke(
                vRight,
                with: linearGradient,
                style: StrokeStyle(lineWidth: 6 * scaleX, lineCap: .round)
            )

            // 4. Side vertical lines (opacity 0.7): 25,35→25,65 and 75,35→75,65
            var sideContext = context
            sideContext.opacity = 0.7

            var leftSide = Path()
            leftSide.move(to: p(25, 35))
            leftSide.addLine(to: p(25, 65))
            sideContext.stroke(
                leftSide,
                with: linearGradient,
                style: StrokeStyle(lineWidth: 6 * scaleX, lineCap: .round)
            )

            var rightSide = Path()
            rightSide.move(to: p(75, 35))
            rightSide.addLine(to: p(75, 65))
            sideContext.stroke(
                rightSide,
                with: linearGradient,
                style: StrokeStyle(lineWidth: 6 * scaleX, lineCap: .round)
            )

            // 5. Center circle: cx=50, cy=55, r=8
            let centerCircle = Path(ellipseIn: CGRect(
                x: (50 - 8) * scaleX,
                y: (55 - 8) * scaleY,
                width: 16 * scaleX,
                height: 16 * scaleY
            ))
            context.fill(centerCircle, with: linearGradient)

            // 6. Left circle: cx=25, cy=35, r=6
            let leftCircle = Path(ellipseIn: CGRect(
                x: (25 - 6) * scaleX,
                y: (35 - 6) * scaleY,
                width: 12 * scaleX,
                height: 12 * scaleY
            ))
            context.fill(leftCircle, with: linearGradient)

            // 7. Right circle: cx=75, cy=35, r=6
            let rightCircle = Path(ellipseIn: CGRect(
                x: (75 - 6) * scaleX,
                y: (35 - 6) * scaleY,
                width: 12 * scaleX,
                height: 12 * scaleY
            ))
            context.fill(rightCircle, with: linearGradient)
        }
    }
}

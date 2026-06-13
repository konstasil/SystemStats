import SwiftUI

struct MiniGraphView: View {
    let data: [Double]
    let color: Color
    let maxValue: Double
    let size: CGSize

    init(data: [Double], color: Color = .green, maxValue: Double = 100.0, size: CGSize = CGSize(width: 24, height: 18)) {
        self.data = data
        self.color = color
        self.maxValue = maxValue
        self.size = size
    }

    var body: some View {
        Canvas { context, canvasSize in
            guard data.count > 1 else { return }

            let width = canvasSize.width
            let height = canvasSize.height
            let stepX = width / CGFloat(data.count - 1)

            var path = Path()
            for (index, value) in data.enumerated() {
                let x = CGFloat(index) * stepX
                let normalized = min(value / maxValue, 1.0)
                let y = height - (CGFloat(normalized) * height)

                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            var fillPath = path
            fillPath.addLine(to: CGPoint(x: width, y: height))
            fillPath.addLine(to: CGPoint(x: 0, y: height))
            fillPath.closeSubpath()

            let gradient = Gradient(colors: [
                color.opacity(0.6),
                color.opacity(0.1)
            ])
            context.fill(fillPath, with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: height)
            ))

            context.stroke(path, with: .color(color), lineWidth: 1.5)
        }
        .frame(width: size.width, height: size.height)
    }
}

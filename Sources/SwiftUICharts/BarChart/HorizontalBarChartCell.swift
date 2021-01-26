import SwiftUI

public struct HorizontalBarChartCell : View {
    var percentage: Double
    var value: Double
    var valueSpecifier: String = "%.2f"
    var index: Int = 0
    var numberOfDataPoints: Int
    var accentColor: Color
    var gradient: GradientColor?
    var textColor: Color = Color(UIColor.label)
    var unit: String? = nil

    @State var scaleValue: Double = 0
    @Binding var touchLocation: CGPoint
    public var body: some View {
        ZStack {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: gradient?.getGradient() ?? GradientColor(
                                start: accentColor,
                                end: accentColor
                            ).getGradient(),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(CGSize(width: self.scaleValue, height: 1), anchor: .leading)
            }
            HStack {
                Spacer()
                Text("\(value, specifier: valueSpecifier) \(unit ?? "")")
                    .foregroundColor(textColor)
                    .fontWeight(.semibold)
            }
            .padding(.trailing)

        }
        .onAppear() {
            self.scaleValue = self.percentage
        }
        .animation(
            Animation
                .spring()
                .delay(self.touchLocation.y < 0 ? Double(self.index) * 0.04 : 0)
        )
    }
}

#if DEBUG
struct HorizontalBarChartCell_Previews : PreviewProvider {
    static var previews: some View {
        HorizontalBarChartCell(
            percentage: Double(0.5),
            value: 50,
            numberOfDataPoints: 12,
            accentColor: Colors.OrangeStart,
            gradient: nil,
            touchLocation: .constant(.zero)
        )
    }
}
#endif

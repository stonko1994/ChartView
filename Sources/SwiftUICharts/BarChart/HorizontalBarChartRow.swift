import SwiftUI

internal struct HorizontalBarChartRow : View {
    var barData: BarChartData
    @Binding var touchLocation: CGPoint

    internal init(
        data: [Double],
        valueSpecifier: String = "%.2f",
        accentColor: Color,
        gradient: GradientColor? = nil,
        touchLocation: Binding<CGPoint>
    ) {
        let barData = data.map {
            BarChartRowData(
                value: $0,
                valueSpecifier: valueSpecifier,
                accentColor: accentColor,
                gradient: gradient
            )
        }

        self.init(data: barData, touchLocation: touchLocation)
    }

    internal init(
        data: [BarChartRowData],
        touchLocation: Binding<CGPoint>
    ) {
        self.init(
            data: BarChartData(data: data),
            touchLocation: touchLocation
        )
    }

    internal init(
        data: BarChartData,
        touchLocation: Binding<CGPoint>
    ) {
        self.barData = data
        self._touchLocation = touchLocation
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(
                alignment: .leading,
                spacing: (geometry.frame(in: .local).height - 22) / CGFloat(barData.count * 3)
            ) {
                ForEach(Array(barData.data.enumerated()), id: \.0) { index, barChartRowData in
                    HorizontalBarChartCell(
                        percentage: barData.normalize(value: barChartRowData.value),
                        value: barChartRowData.value,
                        valueSpecifier: barChartRowData.valueSpecifier,
                        index: index,
                        numberOfDataPoints: barData.count,
                        accentColor: barChartRowData.accentColor,
                        gradient: barChartRowData.gradient,
                        textColor: barChartRowData.textColor,
                        unit: barChartRowData.unit,
                        touchLocation: $touchLocation
                    )
                    .scaleEffect(
                        self.touchLocation.y >
                                CGFloat(index) / CGFloat(barData.count) && touchLocation.y < CGFloat(index + 1) / CGFloat(barData.count)
                            ? CGSize(width: 1.1, height: 1.4)
                            : CGSize(width: 1, height: 1),
                        anchor: .leading
                    )
                    .animation(.spring())
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(10)
        }
    }
}

#if DEBUG
struct HorizontalBarChartRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            HorizontalBarChartRow(
                data: [8,4,5],
                accentColor: Colors.OrangeStart,
                touchLocation: .constant(.zero)
            )

            HorizontalBarChartRow(
                data: [
                    BarChartRowData(value: 8, accentColor: Color.green),
                    BarChartRowData(value: 2, accentColor: Color.red),
                    BarChartRowData(value: 4, accentColor: Color.blue)
                ],
                touchLocation: .constant(.zero)
            )

            HorizontalBarChartRow(
                data: [8,23,54,32,12,37,7,5,4,2,3,5,6,8,9,8,23,54,32,12,37,7,5,4,2,3,5,6,8,9],
                accentColor: Colors.OrangeStart,
                touchLocation: .constant(.zero)
            )
            HorizontalBarChartRow(
                data: [8,23,54,32,12,37,7,5,4,2,3,5,6,8,9,8,23,54,32,12,37,7,5,4,2,3,5,6,8,9],
                accentColor: Colors.OrangeStart,
                touchLocation: .constant(.zero)
            )
            .preferredColorScheme(.dark)
        }
    }
}
#endif

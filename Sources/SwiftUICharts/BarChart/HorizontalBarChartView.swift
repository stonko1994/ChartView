import SwiftUI

public struct BarChartRowData {
    public let value: Double
    public let valueSpecifier: String
    public let accentColor: Color
    public let gradient: GradientColor?
    public let textColor: Color
    public let unit: String?

    public init(
        value: Double,
        valueSpecifier: String = "%.2f",
        accentColor: Color,
        gradient: GradientColor? = nil,
        textColor: Color = Color(UIColor.label),
        unit: String? = nil
    ) {
        self.value = value
        self.valueSpecifier = valueSpecifier
        self.accentColor = accentColor
        self.gradient = gradient
        self.textColor = textColor
        self.unit = unit
    }
}

public struct BarChartData {
    public let data: [BarChartRowData]

    var onlyPoints: [Double] {
        data.map { $0.value }
    }

    var count: Int {
        data.count
    }

    var maxValue: Double {
        guard let max = onlyPoints.max() else {
            return 1
        }
        return max != 0 ? max : 1
    }

    func normalize(value: Double) -> Double {
        value / Double(maxValue)
    }
}

public struct HorizontalBarChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    private var data: BarChartData
    public var title: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var dropShadow: Bool

    @State private var touchLocation: CGPoint = .zero
    @State private var showLabelValue: Bool = false
    @State private var currentValue: Double = 0 {
        didSet {
            if oldValue != self.currentValue {
                HapticFeedback.playSelection()
            }
        }
    }

    public init(
        data: [Double],
        title: String? = nil,
        style: ChartStyle = Styles.barChartStyleOrangeLight,
        darkModeStyle: ChartStyle = Styles.barChartStyleOrangeLight,
        dropShadow: Bool = true,
        valueSpecifier: String = "%.1f"
    ) {
        let barData = data.map {
            BarChartRowData(
                value: $0,
                valueSpecifier: valueSpecifier,
                accentColor: style.accentColor,
                gradient: style.gradientColor,
                textColor: style.textColor
            )
        }

        self.init(
            data: barData,
            title: title,
            style: style,
            darkModeStyle: darkModeStyle,
            dropShadow: dropShadow
        )
    }

    public init(
        data: [BarChartRowData],
        title: String? = nil,
        style: ChartStyle = Styles.barChartStyleOrangeLight,
        darkModeStyle: ChartStyle = Styles.barChartStyleOrangeLight,
        dropShadow: Bool = true
    ) {
        self.init(
            data: BarChartData(data: data),
            title: title,
            style: style,
            darkModeStyle: darkModeStyle,
            dropShadow: dropShadow
        )
    }

    public init(
        data: BarChartData,
        title: String? = nil,
        style: ChartStyle = Styles.barChartStyleOrangeLight,
        darkModeStyle: ChartStyle = Styles.barChartStyleOrangeLight,
        dropShadow: Bool = true
    ) {
        self.data = data
        self.title = title
        self.style = style
        self.darkModeStyle = darkModeStyle
        self.darkModeStyle = darkModeStyle
        self.dropShadow = dropShadow
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(colorScheme == .dark ? darkModeStyle.backgroundColor : style.backgroundColor)
                    .cornerRadius(colorScheme == .dark ? darkModeStyle.cornerRadius : style.cornerRadius)
                    .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)

                VStack(alignment: .leading) {
                    if title != nil {
                    HStack {
                        Text(title!)
                            .font(.headline)
                            .foregroundColor(
                                self.colorScheme == .dark
                                    ? self.darkModeStyle.textColor
                                    : self.style.textColor
                            )
                        }.padding()
                    }

                    ZStack {
                        HorizontalBarChartRow(
                            data: data,
                            touchLocation: self.$touchLocation
                        )
                    }
                }
            }
        }
    }
}

#if DEBUG
struct HorizontalBarChartView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalBarChartView(
            data: [37,72,51,22,39,47,66,85,50],
            valueSpecifier: "%.0f"
        )
        HorizontalBarChartView(
            data: [
                BarChartRowData(value: 8, accentColor: Color.green, textColor: .white),
                BarChartRowData(value: 2, accentColor: Color.red),
                BarChartRowData(value: 4, accentColor: Color.blue),
                BarChartRowData(value: 3, accentColor: Color.blue),
                BarChartRowData(value: 8, accentColor: Color.blue),
                BarChartRowData(value: 1, accentColor: Color.blue)
            ],
            title: "Evolution Avg. Points\nper round",
            style: ChartStyle(
                backgroundColor: Color.gray,
                accentColor: Color.red,
                secondGradientColor: Color.orange,
                textColor: Color.white,
                legendTextColor: Color.white,
                dropShadowColor: .clear,
                cornerRadius: 10
            ),
            darkModeStyle: ChartStyle(
                backgroundColor: Color.gray,
                accentColor: Color.red,
                secondGradientColor: Color.orange,
                textColor: Color.pink,
                legendTextColor: Color.white,
                dropShadowColor: .clear,
                cornerRadius: 10
            ),
            dropShadow: false
        )
    }
}
#endif

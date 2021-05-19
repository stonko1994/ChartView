import SwiftUI

public protocol LineData {
    var dataPoints: [Double] { get }
    var color: GradientColor { get }
}

public struct MultiLineView: View {
    var data: [MultiLineChartData]
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var dragLocation:CGPoint = .zero
    @State private var indicatorLocation:CGPoint = .zero
//    @State private var closestPoints: [CGPoint] = []
    @State private var opacity: Double = 0
    @State private var currentDataNumbers: [MagnifierValues] = []
    @State private var hideHorizontalLines: Bool = false

    public init(
        data: [LineData],
        title: String? = nil,
        legend: String? = nil,
        style: ChartStyle = Styles.lineChartStyleOne,
        darkModeStyle: ChartStyle = Styles.lineViewDarkMode,
        valueSpecifier: String? = "%.1f"
    ) {

        self.data = data.map { MultiLineChartData(points: $0.dataPoints, gradient: $0.color) }
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.darkModeStyle = darkModeStyle
    }

    var globalMin: Double {
        if let min = data.flatMap({ $0.onlyPoints() }).min() {
            return min
        }
        return 0
    }

    var globalMax: Double {
        if let max = data.flatMap({ $0.onlyPoints() }).max() {
            return max
        }
        return 0
    }

    public var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading, spacing: 8) {
                Group{
                    if (self.title != nil){
                        Text(self.title!)
                            .font(.title)
                            .bold().foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    if (self.legend != nil){
                        Text(self.legend!)
                            .font(.callout)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                    }
                }.offset(x: 0, y: 20)
                ZStack{
                    GeometryReader{ reader in
                        Rectangle()
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)

                        Legend(
                            max: self.data.flatMap { $0.onlyPoints() }.max()!,
                            min: self.data.flatMap { $0.onlyPoints() }.min()!,
                            dataPointsCount: self.data[0].onlyPoints().count,
                            frame: reader.frame(in: .local),
                            hideHorizontalLines: self.$hideHorizontalLines,
                            valueSpecifier: "%.0f"
                        )
                        .transition(.opacity)
                        .animation(Animation.easeOut(duration: 1).delay(1))

                        ZStack{
                            ForEach(self.data) { lineChart in
                                Line(data: lineChart,
                                     frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width - 30, height: reader.frame(in: .local).height)),
                                     touchLocation: self.$indicatorLocation,
                                     showIndicator: self.$hideHorizontalLines,
                                     minDataValue: .constant(self.globalMin),
                                     maxDataValue: .constant(self.globalMax),
                                     showBackground: false,
                                     gradient: lineChart.getGradient()
                                )
                                .offset(x: 30, y: 0)
                            }
                        }
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: 240)
                    .offset(x: 0, y: 40 )
                    MultiMagnifierRect(
                        currentNumbers: self.$currentDataNumbers,
                        valueSpecifier: self.valueSpecifier
                    )
                    .opacity(self.opacity)
                    .offset(x: self.dragLocation.x - geometry.frame(in: .local).size.width/2, y: 52)
                }
                .frame(width: geometry.frame(in: .local).size.width, height: 240)
                .gesture(DragGesture()
                    .onChanged { value in
                        let width = geometry.frame(in: .local).size.width
                        self.dragLocation = CGPoint(
                            x: clamp(value.location.x, min: 30, max: width),
                            y: value.location.y
                        )
                        self.indicatorLocation = CGPoint(
                            x: max(value.location.x - 30, 0),
                            y: 32
                        )
                        self.opacity = 1
                        self.getClosestDataPoints(
                            to: self.dragLocation,
                            width: width,
                            height: 240
                        )
                        self.hideHorizontalLines = true
                    }
                    .onEnded{ value in
                        self.opacity = 0
                        self.hideHorizontalLines = false
                    }
                )
            }
        }
    }

    func getClosestDataPoints(to point: CGPoint, width:CGFloat, height: CGFloat) {
        self.currentDataNumbers = self.data.compactMap { data in
            let points = data.onlyPoints()
            let stepWidth: CGFloat = width / CGFloat(points.count)
//            let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)

            let index:Int = clamp(
                Int(floor(point.x / stepWidth)),
                min: 0,
                max: points.count - 1
            )
            if (index >= 0 && index < points.count) {
                return MagnifierValues(value: points[index], color: data.getGradient())
            }
            return nil
        }
        print("[log] \(currentDataNumbers)")
    }
}

struct MultiLineView_Previews: PreviewProvider {
    static var previews: some View {
        let line1 = DummyLineData(
            dataPoints: (0...1).map { _ in Double.random(in: 0...70) },
            color: GradientColor(start: .red, end: .blue)
        )

        let line2 = DummyLineData(
            dataPoints: (0...1).map { _ in Double.random(in: 0...70) },
            color: GradientColor(start: .green, end: .blue)
        )

        let line3 = DummyLineData(
            dataPoints: (0...1).map { _ in Double.random(in: 0...70) },
            color: GradientColor(start: .black, end: .orange)
        )

        let line4 = DummyLineData(
            dataPoints: (0...1).map { _ in Double.random(in: 0...70) },
            color: GradientColor(start: .purple, end: .gray)
        )

        return Group {
            ZStack {
                Rectangle().fill(Color.gray)

                HStack {
                    HStack {
                        Spacer()
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        MultiLineView(
                            data: [line1, line2, line3, line4],
                            title: "Full chart",
                            style: Styles.lineChartStyleOne
                        ).environment(\.colorScheme, .dark)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Spacer()
                    }
                }


            }

//            MultiLineView(data: [282.502, 284.495, 283.51, 285.019, 285.197, 286.118, 288.737, 288.455, 289.391, 287.691, 285.878, 286.46, 286.252, 284.652, 284.129, 284.188], title: "Full chart", style: Styles.lineChartStyleOne)

        }
    }
}

fileprivate struct DummyLineData: LineData {
    let dataPoints: [Double]
    let color: GradientColor
}


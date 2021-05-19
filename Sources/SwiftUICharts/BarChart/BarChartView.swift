//
//  ChartView.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    private var data: ChartData
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var dropShadow: Bool
    public var cornerImage: Image?
    public var valueSpecifier: String

    @State private var touchLocation: CGPoint = .zero
    @State private var showValue: Bool = false
    @State private var showLabelValue: Bool = false
    @State private var currentValue: Double = 0 {
        didSet {
            if (oldValue != self.currentValue && self.showValue) {
                HapticFeedback.playSelection()
            }
        }
    }

    public init(
        data: ChartData,
        title: String? = nil,
        legend: String? = nil,
        style: ChartStyle = Styles.barChartStyleOrangeLight,
        darkModeStyle: ChartStyle = Styles.barChartStyleOrangeLight,
        dropShadow: Bool? = true,
        cornerImage: Image? = nil,
        valueSpecifier: String? = "%.1f"
    ) {
        self.data = data
        self.title = title
        self.legend = legend
        self.style = style
        self.darkModeStyle = darkModeStyle
        self.dropShadow = dropShadow!
        self.cornerImage = cornerImage
        self.valueSpecifier = valueSpecifier!
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(colorScheme == .dark ? darkModeStyle.backgroundColor : style.backgroundColor)
                    .cornerRadius(colorScheme == .dark ? darkModeStyle.cornerRadius : style.cornerRadius)
                    .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)
                VStack(alignment: .leading) {
                    if showValue || title != nil || self.legend != nil && !showValue || cornerImage != nil {
                        HStack {
                            if showValue {
                                Text(self.title!)
                                    .font(.headline)
                                    .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                            } else if title != nil {
                                Text("\(self.currentValue, specifier: self.valueSpecifier)")
                                    .font(.headline)
                                    .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                            }
                            if self.legend != nil && !showValue {
                                Text(self.legend!)
                                    .font(.callout)
                                    .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor)
                                    .transition(.opacity)
                                    .animation(.easeOut)
                            }
                            Spacer()
                            if cornerImage != nil {
                                self.cornerImage
                                    .imageScale(.large)
                                    .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                            }
                        }.padding()
                    }

                    ZStack {
                        GeometryReader{ reader in
                            Legend(
                                max: self.data.onlyPoints().max()!,
                                min: 0,
                                dataPointsCount: self.data.onlyPoints().count,
                                frame: reader.frame(in: .local),
                                hideHorizontalLines: .constant(false),
                                valueSpecifier: "%.0f"
                            )
                            .transition(.opacity)
                            .animation(Animation.easeOut(duration: 1).delay(1))

                            BarChartRow(
                                data: data.points.map {
                                    $0.1
                                },
                                accentColor: self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor,
                                gradient: self.colorScheme == .dark ? self.darkModeStyle.gradientColor : self.style.gradientColor,
                                touchLocation: self.$touchLocation
                            )
                            .padding(.trailing, 30)
                            .offset(x: 30, y: 0)
                        }
                    }

                    if self.legend != nil && !self.showLabelValue {
                        Text(self.legend!)
                            .font(.headline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                            .padding()
                    } else if self.touchLocation != .zero &&
                                self.data.valuesGiven && self.getCurrentValue(width: geometry.frame(in: .local).size.width) != nil {
                        LabelView(
                            arrowOffset: self.getArrowOffset(touchLocation: touchLocation, width: geometry.frame(in: .local).size.width),
                            title: .constant(self.getCurrentValue(width: geometry.frame(in: .local).size.width)!.0)
                        )
                            .offset(
                                x: self.getLabelViewOffset(touchLocation: touchLocation, width: geometry.frame(in: .local).size.width),
                                y: -6
                            )
                            .foregroundColor(
                                self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor
                            )
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let width = geometry.frame(in: .local).size.width
                        self.touchLocation = CGPoint(
                            x: (value.location.x / width),
                            y: 0
                        )
                        self.showValue = true
                        self.currentValue = self.getCurrentValue(width: geometry.frame(in: .local).size.width)?.1 ?? 0
                        if (self.data.valuesGiven) {
                            self.showLabelValue = true
                        }
                    }
                    .onEnded { value in
                        self.showValue = false
                        self.showLabelValue = false
                        self.touchLocation = .zero
                    }

            )
            .gesture(TapGesture())
        }
    }

    func getArrowOffset(touchLocation: CGPoint, width: CGFloat) -> Binding<CGFloat> {
        let realLoc = (touchLocation.x * width) - 50
        if realLoc < 10 {
            return .constant(realLoc - 10)
        } else if realLoc > width - 110 {
            return .constant((width - 110 - realLoc) * -1)
        } else {
            return .constant(0)
        }
    }

    func getLabelViewOffset(touchLocation: CGPoint, width: CGFloat) -> CGFloat {
        return min(width - 110, max(10, (touchLocation.x * width) - 50))
    }

    func getCurrentValue(width: CGFloat) -> (String, Double)? {
        guard self.data.points.count > 0 else {
            return nil
        }
        let index = max(0, min(self.data.points.count - 1, Int(floor((self.touchLocation.x * width) / (width / CGFloat(self.data.points.count))))))
        return self.data.points[index]
    }
}

#if DEBUG
struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(
            data: TestData.values ,
            title: "Model 3 sales",
            legend: "Quarterly",
            valueSpecifier: "%.0f"
        )
        BarChartView(
            data: ChartData(values: [
                ("2018 Q4", 23.2),
                ("2019 Q1", 25.4),
                ("2019 Q2", 12.5),
                ("2019 Q3", 56.4),
                ("2019 Q4", 41.8),
                ("2018 Q4", 23.2),
                ("2019 Q1", 25.4),
                ("2019 Q2", 12.5),
                ("2019 Q3", 56.4),
                ("2019 Q4", 41.8),
                ("2018 Q4", 23.2),
                ("2019 Q1", 25.4),
                ("2019 Q2", 12.5),
                ("2019 Q3", 56.4),
                ("2019 Q4", 41.8),
                ("2018 Q4", 23.2),
                ("2019 Q1", 25.4),
                ("2019 Q2", 12.5),
                ("2019 Q3", 56.4),
                ("2019 Q4", 41.8),
                ("2018 Q4", 23.2),
                ("2019 Q1", 25.4),
                ("2019 Q2", 12.5),
                ("2019 Q3", 56.4),
                ("2019 Q4", 41.8),
                ("2018 Q4", 23.2),
                ("2019 Q1", 25.4),
                ("2019 Q2", 12.5),
                ("2019 Q3", 56.4),
                ("2019 Q4", 41.8)
            ]),
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
                textColor: Color.white,
                legendTextColor: Color.white,
                dropShadowColor: .clear,
                cornerRadius: 10
            ),
//            form: ChartForm.extraLarge,
            dropShadow: false,
            valueSpecifier: "%.2f"
        )
    }
}
#endif

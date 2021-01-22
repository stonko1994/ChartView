//
//  ChartRow.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartRow : View {
    var data: [Double]
    var accentColor: Color
    var gradient: GradientColor?
    
    var maxValue: Double {
        guard let max = data.max() else {
            return 1
        }
        return max != 0 ? max : 1
    }
    @Binding var touchLocation: CGPoint
    public var body: some View {
        GeometryReader { geometry in
            HStack(
                alignment: .bottom,
                spacing: (geometry.frame(in: .local).width - 22) / CGFloat(self.data.count * 3)
            ) {
//                Spacer()
                ForEach(0..<self.data.count, id: \.self) { i in
                    BarChartCell(
                        value: self.normalizedValue(index: i),
                        index: i,
                        width: Float(geometry.frame(in: .local).width - 22),
                        numberOfDataPoints: self.data.count,
                        accentColor: self.accentColor,
                        gradient: self.gradient,
                        touchLocation: self.$touchLocation
                    )
                    .scaleEffect(
                        self.touchLocation.x >
                                CGFloat(i) / CGFloat(self.data.count) && self.touchLocation.x < CGFloat(i + 1) / CGFloat(self.data.count)
                            ? CGSize(width: 1.4, height: 1.1)
                            : CGSize(width: 1, height: 1),
                        anchor: .bottom
                    )
                    .animation(.spring())
                }
//                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding([.leading, .trailing], 10)

        }
    }
    
    func normalizedValue(index: Int) -> Double {
        return Double(self.data[index])/Double(self.maxValue)
    }
}

#if DEBUG
struct ChartRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            BarChartRow(
                data: [8,4,5],
                accentColor: Colors.OrangeStart,
                touchLocation: .constant(.zero)
            )
            BarChartRow(
                data: [8,23,54,32,12,37,7,5,4,2,3,5,6,8,9],
                accentColor: Colors.OrangeStart,
                touchLocation: .constant(.zero)
            )
        }
    }
}
#endif

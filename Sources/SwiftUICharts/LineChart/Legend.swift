//
//  Legend.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

struct Legend: View {
    @State var max: Double
    @State var min: Double
    @State var dataPointsCount: Int

    @Binding var frame: CGRect
    @Binding var hideHorizontalLines: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let padding:CGFloat = 30

    public var valueSpecifier: String = "%.2f"

    var stepWidth: CGFloat {
        if dataPointsCount < 2 {
            return 0
        }
        return frame.size.width / CGFloat(dataPointsCount-1)
    }
    var stepHeight: CGFloat {
        if min < 0 {
            return (frame.size.height-padding) / CGFloat(max - min)
        } else {
            return (frame.size.height-padding) / CGFloat(max - min)
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading){
            ForEach((0...4), id: \.self) { height in
                HStack(alignment: .center){
                    Text("\(self.getYLegendSafe(height: height), specifier: valueSpecifier)").offset(x: 0, y: self.getYposition(height: height) )
                        .foregroundColor(Colors.LegendText)
                        .font(.caption)
                    self.line(atHeight: self.getYLegendSafe(height: height), width: self.frame.width)
                        .stroke(self.colorScheme == .dark ? Colors.LegendDarkColor : Colors.LegendColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [5,height == 0 ? 0 : 10]))
                        .opacity((self.hideHorizontalLines && height != 0) ? 0 : 1)
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeOut(duration: 0.2))
                        .clipped()
                }
               
            }
            
        }
    }
    
    func getYLegendSafe(height:Int)->CGFloat{
        if let legend = getYLegend() {
            return CGFloat(legend[height])
        }
        return 0
    }
    
    func getYposition(height: Int)-> CGFloat {
        if let legend = getYLegend() {
            return (self.frame.height - ((CGFloat(legend[height]) - CGFloat(min))*self.stepHeight))-(self.frame.height/2)
        }
        return 0
       
    }
    
    func line(atHeight: CGFloat, width: CGFloat) -> Path {
        var hLine = Path()
        hLine.move(to: CGPoint(x:5, y: (atHeight-CGFloat(min))*stepHeight))
        hLine.addLine(to: CGPoint(x: width, y: (atHeight-CGFloat(min))*stepHeight))
        return hLine
    }
    
    func getYLegend() -> [Double]? {
        let step = Double(max - min) / 4
        return [min+step * 0, min+step * 1, min+step * 2, min+step * 3, min+step * 4]
    }
}

struct Legend_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            Legend(
                max: 8.0,
                min: 0.2,
                dataPointsCount: 5,
                frame: .constant(geometry.frame(in: .local)),
                hideHorizontalLines: .constant(false),
                valueSpecifier: "%0.f"
            )
        }.frame(width: 320, height: 200)
    }
}

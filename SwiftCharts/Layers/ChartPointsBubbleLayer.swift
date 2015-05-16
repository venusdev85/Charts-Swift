//
//  ChartPointsBubbleLayer.swift
//  Examples
//
//  Created by ischuetz on 16/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit


public class ChartPointBubble: ChartPoint {
    let diameterScalar: CGFloat
    let bgColor: UIColor
    let borderColor: UIColor
    
    public init(x: ChartAxisValue, y: ChartAxisValue, diameterScalar: CGFloat, bgColor: UIColor, borderColor: UIColor = UIColor.blackColor()) {
        self.diameterScalar = diameterScalar
        self.bgColor = bgColor
        self.borderColor = borderColor
        super.init(x: x, y: y)
    }
}


public class ChartPointsBubbleLayer<T: ChartPointBubble>: ChartPointsLayer<T> {
    
    private let diameterFactor: CGFloat
    
    init(axisX: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, maxBubbleDiameter: CGFloat = 30, minBubbleDiameter: CGFloat = 2) {
        
        let (minDiameterScalar: CGFloat, maxDiameterScalar: CGFloat) = chartPoints.reduce((min: CGFloat(0), max: CGFloat(0))) {tuple, chartPoint in
            (min: min(tuple.min, chartPoint.diameterScalar), max: max(tuple.max, chartPoint.diameterScalar))
        }
        
        self.diameterFactor = (maxBubbleDiameter - minBubbleDiameter) / (maxDiameterScalar - minDiameterScalar)

        super.init(axisX: axisX, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override public func chartViewDrawing(#context: CGContextRef, chart: Chart) {

        for chartPointModel in self.chartPointsModels {

            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context, chartPointModel.chartPoint.borderColor.CGColor)
            CGContextSetFillColorWithColor(context, chartPointModel.chartPoint.bgColor.CGColor)
            
            let diameter = chartPointModel.chartPoint.diameterScalar * diameterFactor
            let circleRect = (CGRectMake(chartPointModel.screenLoc.x - diameter / 2, chartPointModel.screenLoc.y - diameter / 2, diameter, diameter))
            
            CGContextFillEllipseInRect(context, circleRect)
            CGContextStrokeEllipseInRect(context, circleRect)
        }
    }
}

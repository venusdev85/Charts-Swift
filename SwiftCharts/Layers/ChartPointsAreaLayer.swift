//
//  ChartPointsAreaLayer.swift
//  swiftCharts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointsAreaLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    private let lineColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    private let addContainerPoints: Bool
    
    public init(axisX: ChartAxisLayer, axisY: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], lineColor: UIColor, animDuration: Float, animDelay: Float, addContainerPoints: Bool) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.addContainerPoints = addContainerPoints
        
        super.init(axisX: axisX, yAxis: axisY, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    override func display(#chart: Chart) {
        var points = self.chartPointScreenLocs
        
        let origin = self.innerFrame.origin
        let xLength = self.innerFrame.width
        
        let bottomY = origin.y + self.innerFrame.height
        
        if self.addContainerPoints {
            points.append(CGPointMake(origin.x + xLength, bottomY))
            points.append(CGPointMake(origin.x, bottomY))
        }
        
        let areaView = ChartAreasView(points: points, frame: chart.bounds, color: self.lineColor, animDuration: self.animDuration, animDelay: self.animDelay)
        chart.addSubview(areaView)
    }
}

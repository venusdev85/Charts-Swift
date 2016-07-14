//
//  ChartAxisXLowLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for low X axes
class ChartAxisXLowLayerDefault: ChartAxisXLayerDefault {

    override var low: Bool {return true}

    /// The start point of the axis line.
    override var lineP1: CGPoint {
        return CGPointMake(axis.firstVisibleScreen, origin.y)
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return CGPointMake(axis.lastVisibleScreen, end.y)
    }
    
    override func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        super.chartViewDrawing(context: context, chart: chart)
    }

    override func prepareUpdate() {
        super.prepareUpdate()
        offset = offset - (frame.height - lastFrame.height)
    }
    
    override func updateInternal() {
        guard let chart = self.chart else {return}
        super.updateInternal()
        if lastFrame.height != self.frame.height {
            chart.notifyAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta(layer: self, delta: self.frame.height - self.lastFrame.height))
        }
    }

    override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // Handle resizing of other low x axes
        if let xLow = xLow where xLow.layer.frame.maxY > self.frame.maxY {
            offset = offset - xLow.delta
            self.initDrawers()
        }
    }
    
    override func initDrawers() {
        self.lineDrawer = self.generateLineDrawer(offset: 0)
        let labelsOffset = (self.settings.axisStrokeWidth / 2) + self.settings.labelsToAxisSpacingX
        self.labelDrawers = self.generateLabelDrawers(offset: labelsOffset)
        let definitionLabelsOffset = labelsOffset + self.labelsTotalHeight + self.settings.axisTitleLabelsToLabelsSpacing
        self.axisTitleLabelDrawers = self.generateAxisTitleLabelsDrawers(offset: definitionLabelsOffset)
    }
}

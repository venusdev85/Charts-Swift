//
//  Zoomable.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

// TODO finish zoom_pan_global_transform branch and replace this

public protocol Zoomable {
    
    var zoomPanSettings: ChartSettingsZoomPan {get}
    
    var containerView: UIView {get}
    
    var contentView: UIView {get}
    
    var scaleX: CGFloat {get}
    var scaleY: CGFloat {get}
    
    var maxScaleX: CGFloat? {get}
    var minScaleX: CGFloat? {get}
    var maxScaleY: CGFloat? {get}
    var minScaleY: CGFloat? {get}
    
    func zoom(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat, isGesture: Bool)
    
    func onZoomStart(scaleX scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat)

    func onZoomStart(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat)
    
    func onZoomFinish(scaleX scaleX: CGFloat, scaleY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat, isGesture: Bool)
}

public extension Zoomable {
    
    var contentScaleRatioX: CGFloat {
        return contentView.transform.a / scaleX
    }

    var contentScaleRatioY: CGFloat {
        return contentView.transform.d / scaleY
    }
    
    public func zoom(scaleX scaleX: CGFloat, scaleY: CGFloat, anchorX: CGFloat = 0.5, anchorY: CGFloat = 0.5) {
        let center = calculateCenter(anchorX: anchorX, anchorY: anchorX)
        zoom(scaleX: scaleX, scaleY: scaleY, centerX: center.x, centerY: center.y)
    }
    
    public func zoom(deltaX deltaX: CGFloat, deltaY: CGFloat, anchorX: CGFloat = 0.5, anchorY: CGFloat = 0.5) {
        let center = calculateCenter(anchorX: anchorX, anchorY: anchorX)
        zoom(deltaX: deltaX, deltaY: deltaY, centerX: center.x, centerY: center.y, isGesture: false)
    }
    
    public func zoom(scaleX scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        
        let finalMinScaleX = minScaleX.map{max($0, scaleX)} ?? scaleX
        let finalScaleX = maxScaleX.map{min(finalMinScaleX, $0)} ?? finalMinScaleX
        let finalMinScaleY = minScaleY.map{max($0, scaleY)} ?? scaleY
        let finalScaleY = maxScaleY.map{min(finalMinScaleY, $0)} ?? finalMinScaleY
        
        onZoomStart(scaleX: finalScaleX, scaleY: finalScaleY, centerX: centerX, centerY: centerY)
        
        let contentViewCenter = toContentViewCenter(centerX, centerY: centerY)
        setContentViewAnchor(contentViewCenter.x, centerY: contentViewCenter.y)
        
        let newContentWidth = finalScaleX * containerView.frame.width
        let newScale = newContentWidth / contentView.frame.width
        let newContentHeight = finalScaleY * containerView.frame.height
        let newScaleY = newContentHeight / contentView.frame.height
        
        setContentViewScale(scaleX: newScale, scaleY: newScaleY)
    }
    
    public func zoom(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat, isGesture: Bool) {
        
        var finalDeltaX: CGFloat
        var finalDeltaY: CGFloat
        if zoomPanSettings.elastic {
            finalDeltaX = deltaX
            finalDeltaY = deltaY
        } else {
            let finalMinDeltaX = minScaleX.map{max($0 / scaleX, deltaX)} ?? deltaX
            finalDeltaX = maxScaleX.map{min($0 / scaleX, finalMinDeltaX)} ?? finalMinDeltaX
            let finalMinDeltaY = minScaleY.map{max($0 / scaleY, deltaY)} ?? deltaY
            finalDeltaY = maxScaleY.map{min($0 / scaleY, finalMinDeltaY)} ?? finalMinDeltaY
        }
        
        onZoomStart(deltaX: finalDeltaX, deltaY: finalDeltaY, centerX: centerX, centerY: centerY)
        
        let contentViewCenter = toContentViewCenter(centerX, centerY: centerY)
        zoomContentView(deltaX: finalDeltaX, deltaY: finalDeltaY, centerX: contentViewCenter.x, centerY: contentViewCenter.y)
        
        onZoomFinish(scaleX: contentView.frame.width / containerView.frame.width, scaleY: contentView.frame.height / containerView.frame.height, deltaX: finalDeltaX, deltaY: finalDeltaY, centerX: centerX, centerY: centerY, isGesture: isGesture)
    }
    
    private func zoomContentView(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        setContentViewAnchor(centerX, centerY: centerY)
        
        let scaleX = zoomPanSettings.elastic ? deltaX : max(containerView.frame.width / contentView.frame.width, deltaX)
        let scaleY = zoomPanSettings.elastic ? deltaY : max(containerView.frame.height / contentView.frame.height, deltaY)
        
        setContentViewScale(scaleX: scaleX, scaleY: scaleY)
    }
    
    private func toContentViewCenter(centerX: CGFloat, centerY: CGFloat) -> CGPoint {
        let containerFrame = containerView.frame
        let contentFrame = contentView.frame
        
        let transCenterX = centerX - contentFrame.minX - containerFrame.minX
        let transCenterY = centerY - contentFrame.minY - containerFrame.minY
        return CGPointMake(transCenterX, transCenterY)
    }
    
    private func setContentViewAnchor(centerX: CGFloat, centerY: CGFloat) {
        let contentFrame = contentView.frame

        let anchorX = centerX / contentFrame.width
        let anchorY = centerY / contentFrame.height
        let previousAnchor = contentView.layer.anchorPoint
        contentView.layer.anchorPoint = CGPointMake(anchorX, anchorY)
        let offsetX = contentFrame.width * (previousAnchor.x - contentView.layer.anchorPoint.x)
        let offsetY = contentFrame.height * (previousAnchor.y - contentView.layer.anchorPoint.y)
        contentView.transform.tx = contentView.transform.tx - offsetX
        contentView.transform.ty = contentView.transform.ty - offsetY
    }

    private func setContentViewScale(scaleX scaleX: CGFloat, scaleY: CGFloat) {
        contentView.transform = CGAffineTransformScale(contentView.transform, scaleX, scaleY)
        if !zoomPanSettings.elastic {
            keepInBoundaries()
        }
    }
    
    func keepInBoundaries() {
        let containerFrame = containerView.frame
        
        if contentView.frame.origin.y > 0 {
            contentView.transform.ty = contentView.transform.ty - contentView.frame.origin.y
        }
        if contentView.frame.maxY < containerFrame.height {
            contentView.transform.ty = contentView.transform.ty + (containerFrame.height - contentView.frame.maxY)
        }
        if contentView.frame.origin.x > 0 {
            contentView.transform.tx = contentView.transform.tx - contentView.frame.origin.x
        }
        if contentView.frame.maxX < containerFrame.width {
            contentView.transform.tx = contentView.transform.tx + (containerFrame.width - contentView.frame.maxX)
        }
    }
    
    private func calculateCenter(anchorX anchorX: CGFloat = 0.5, anchorY: CGFloat = 0.5) -> CGPoint {
        let centerX = containerView.frame.minX + contentView.frame.minX + containerView.frame.width * anchorX
        let centerY = containerView.frame.minY + contentView.frame.minY + (containerView.frame.height * anchorY)
        return CGPointMake(centerX, centerY)
    }
}
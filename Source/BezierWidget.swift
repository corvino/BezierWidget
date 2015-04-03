//
//  BezierCurveView.swift
//  BezierWidget
//
//  Created by Nathan Corvino on 4/2/15.
//  Copyright (c) 2015 Nathan Corvino. All rights reserved.
//

import Cocoa

class BezierWidget: NSView {

    let graphInner = CAShapeLayer()
    let graphOuter = CAShapeLayer()
    let line1 = CAShapeLayer()
    let line2 = CAShapeLayer()
    let curve = CAShapeLayer()

    let propertyLabel = CATextLayer()
    let timeLabel = CATextLayer()

    let pointLayer1 = BezierWidget.createPointLayer("1")
    let pointLayer2 = BezierWidget.createPointLayer("2")

    dynamic var controlPoint1 = CGPointZero
    dynamic var controlPoint2 = CGPointZero

    dynamic var timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault) {
        didSet {
            let points = UnsafeMutablePointer<Float>.alloc(2)

            timingFunction.getControlPointAtIndex(1, values: points)
            controlPoint1 = CGPoint(x: Double(points[0]), y: 1 - Double(points[1]))
            timingFunction.getControlPointAtIndex(2, values: points)
            controlPoint2 = CGPoint(x: Double(points[0]), y: 1 - Double(points[1]))

            // Is this the best way to do this? Means the transaction gets wrapped so
            // it's not controlled by the setter. Works for now...
            updatePaths(0.25, animateLines: true)
        }
    }

    // Would like this to be a non-option let, but Swift is defeating us at the moment...
    var panGestureRecognizer : NSPanGestureRecognizer! = nil
    var draggingPoint : CALayer?

    class func createPointLayer(title: String) -> CALayer {
        let darkGreenColor = NSColor(red: 82/255, green: 151/255, blue: 103/255, alpha: 1)

        let circle = CAShapeLayer()
        circle.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: 8, y: 8), size: CGSize(width: 28, height: 28)), nil)
        circle.strokeColor = NSColor(red: 227/255, green: 228/255, blue: 199/255, alpha: 1).CGColor
        circle.fillColor = darkGreenColor.CGColor

        circle.lineWidth = 2
        circle.opacity = 0.8

        let text = CATextLayer()
        text.frame = CGRect(origin: CGPoint(x: 8, y: 8), size: CGSize(width: 28, height: 28))
        text.string = title
        text.alignmentMode = kCAAlignmentCenter;
        text.foregroundColor = NSColor.whiteColor().CGColor
        text.fontSize = 20

        let pointLayer = CALayer()
        pointLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 44, height: 44))
        pointLayer.shadowOpacity = 0.625
        pointLayer.shadowOffset = CGSizeMake(0, 1)
        pointLayer.shadowPath = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: 11, y: 11), size: CGSize(width: 22, height: 22)), nil)

        pointLayer.addSublayer(circle)
        pointLayer.addSublayer(text)

        return pointLayer
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        doInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        doInit()
    }

    func doInit() {
        panGestureRecognizer = NSPanGestureRecognizer(target: self, action: "handlePan:")
        setControlPointsFromTimingFunction()

        wantsLayer = true

        // Setitng up the sublayers would make sense here, but there are problems getting
        // the layer when being loaded form a nib/xib/storyboard.
    }

    func setupSublayers() {
        let darkBrownColor = NSColor(red: 72/255, green: 52/255, blue: 37/255, alpha: 1)
        let darkGreenColor = NSColor(red: 82/255, green: 151/255, blue: 103/255, alpha: 1)

        layer!.backgroundColor = NSColor.whiteColor().CGColor

        graphInner.strokeColor = darkBrownColor.CGColor
        graphInner.fillColor = NSColor.clearColor().CGColor
        graphInner.lineWidth = 2

        graphOuter.strokeColor = darkBrownColor.colorWithAlphaComponent(0.5).CGColor
        graphOuter.fillColor = NSColor.clearColor().CGColor
        graphOuter.lineWidth = 1
        graphOuter.lineDashPattern = [6, 5]

        line1.strokeColor = darkGreenColor.CGColor
        line1.fillColor = NSColor.clearColor().CGColor
        line1.lineWidth = 2
        line1.lineDashPattern = [3, 3]

        line2.strokeColor = darkGreenColor.CGColor
        line2.fillColor = NSColor.clearColor().CGColor
        line2.lineWidth = 2
        line2.lineDashPattern = [3, 3]

        curve.strokeColor = NSColor.orangeColor().CGColor
        curve.fillColor = NSColor.clearColor().CGColor;
        curve.lineWidth = 4;

        propertyLabel.bounds = CGRect(origin: CGPointZero, size: CGSize(width: 150, height: 22))
        propertyLabel.fontSize = 15
        propertyLabel.foregroundColor = NSColor.blackColor().CGColor
        propertyLabel.alignmentMode = kCAAlignmentCenter
        propertyLabel.string = "property"
        propertyLabel.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI_2)))

        timeLabel.bounds = CGRect(origin: CGPointZero, size: CGSize(width: 150, height: 22))
        timeLabel.fontSize = 15
        timeLabel.foregroundColor = NSColor.blackColor().CGColor
        timeLabel.alignmentMode = kCAAlignmentCenter
        timeLabel.string = "time"

        layer!.addSublayer(graphInner)
        layer!.addSublayer(graphOuter)
        layer!.addSublayer(line1)
        layer!.addSublayer(line2)
        layer!.addSublayer(curve)
        layer!.addSublayer(propertyLabel)
        layer!.addSublayer(timeLabel)
        layer!.addSublayer(pointLayer1)
        layer!.addSublayer(pointLayer2)

        addGestureRecognizer(panGestureRecognizer)
    }

    override func updateLayer() {
        // Setitng up the sublayers would make sense here, but there are problems getting
        // the layer when being loaded form a nib/xib/storyboard.
        // So, we setup the sublayers here if it hasn't been done.

        if (nil == graphInner.superlayer) {
            setupSublayers()
        }
    }

    override func layoutSublayersOfLayer(layer: CALayer!) {
        if layer == self.layer {
            let rect = curveRect()

            let pathInner = NSBezierPath()
            pathInner.moveToPoint(CGPoint(x: rect.origin.x, y: CGRectGetMaxY(rect) + 16))
            pathInner.lineToPoint(CGPoint(x: rect.origin.x - 3, y: CGRectGetMaxY(rect) + 10))
            pathInner.lineToPoint(CGPoint(x: rect.origin.x + 3, y: CGRectGetMaxY(rect) + 10))
            pathInner.closePath()

            pathInner.moveToPoint(CGPoint(x: rect.origin.x, y: CGRectGetMaxY(rect) + 10))
            pathInner.lineToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect)))
            pathInner.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) + 10, y: CGRectGetMinY(rect)))

            pathInner.moveToPoint(CGPoint(x: CGRectGetMaxX(rect) + 16, y: CGRectGetMinY(rect)))
            pathInner.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) + 10, y: CGRectGetMinY(rect) + 3))
            pathInner.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) + 10, y: CGRectGetMinY(rect) - 3))
            pathInner.closePath()

            let pathOuter = NSBezierPath()
            pathOuter.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect) - 0.5))
            pathOuter.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) - 0.5, y: CGRectGetMaxY(rect) - 0.5))
            pathOuter.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) - 0.5, y: CGRectGetMinY(rect)))

            graphInner.path = pathInner.cgPath()
            graphOuter.path = pathOuter.cgPath()

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            propertyLabel.position = CGPoint(x: CGRectGetMinX(rect) - 15, y: CGRectGetMidY(rect))
            timeLabel.position = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMinY(rect) - 15)

            updatePaths(0.1, animateLines: false)
            CATransaction.commit()
        }
    }


    func updatePaths(duration: CGFloat, animateLines: Bool) {
        let rect = curveRect()
        let cp1 = CGPoint(x: CGRectGetMinX(rect) + controlPoint1.x * CGRectGetWidth(rect),
            y: CGRectGetMaxY(rect) - controlPoint1.y * CGRectGetHeight(rect))
        let cp2 = CGPoint(x: CGRectGetMinX(rect) + controlPoint2.x * CGRectGetWidth(rect),
            y: CGRectGetMaxY(rect) - controlPoint2.y * CGRectGetHeight(rect))

        let pathCurve = NSBezierPath()
        pathCurve.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect)))
        pathCurve.curveToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)), controlPoint1: cp1, controlPoint2: cp2)

        let pathLine1 = NSBezierPath()
        pathLine1.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinX(rect)))
        pathLine1.lineToPoint(cp1)

        let pathLine2 = NSBezierPath()
        pathLine2.moveToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))
        pathLine2.lineToPoint(cp2)

        let cgPath = pathCurve.cgPath()

        let completion : () -> Void = {
            self.pointLayer1.position = cp1
            self.pointLayer2.position = cp2

            self.curve.path = cgPath
            self.line1.path = pathLine1.cgPath()
            self.line2.path = pathLine2.cgPath()
        }

        if (animateLines) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(CFTimeInterval(duration))

            curve.path = cgPath
            self.line1.path = pathLine1.cgPath()
            self.line2.path = pathLine2.cgPath()

            let line1Animation = CABasicAnimation(keyPath: "path")
            line1Animation.fromValue = (line1.presentationLayer() as! CAShapeLayer).path
            line1Animation.toValue = pathLine1.cgPath()
            line1.addAnimation(line1Animation, forKey: "path")

            let line2Animation = CABasicAnimation(keyPath: "path")
            line2Animation.fromValue = (line2.presentationLayer() as! CAShapeLayer).path
            line2Animation.toValue = pathLine2.cgPath()
            line2.addAnimation(line2Animation, forKey: "path")

            let point1Animation = CABasicAnimation(keyPath: "position")
            point1Animation.fromValue = NSValue(point: pointLayer1.presentationLayer().position)
            point1Animation.toValue = NSValue(point: cp1)
            pointLayer1.addAnimation(point1Animation, forKey: "position")

            let point2Animation = CABasicAnimation(keyPath: "position")
            point2Animation.fromValue = NSValue(point: pointLayer2.presentationLayer().position)
            point2Animation.toValue = NSValue(point: cp2)
            pointLayer2.addAnimation(point2Animation, forKey: "position")

            CATransaction.setCompletionBlock(completion)
            CATransaction.commit()
        } else {
            completion()
        }
    }

    func handlePan(panner : NSPanGestureRecognizer) {
        if .Began == panner.state {
            draggingPoint = nil
            if NSPointInRect(panner.locationInView(self), pointLayer1.frame) {
                draggingPoint = pointLayer1
            } else if NSPointInRect(panner.locationInView(self), pointLayer2.frame) {
                draggingPoint = pointLayer2
            }
            if nil != draggingPoint {
                let touchPoint = panner.translationInView(self)
                let adjustedTranslation = CGPoint(x: draggingPoint!.position.x + touchPoint.x, y: draggingPoint!.position.y + touchPoint.y)
                panner.setTranslation(adjustedTranslation, inView: self)
            }
        } else if (.Ended == panner.state) {
            draggingPoint = nil
            timingFunction = CAMediaTimingFunction(controlPoints: Float(controlPoint1.x), 1 - Float(controlPoint1.y), Float(controlPoint2.x), 1 - Float(controlPoint2.y))
        } else if nil != draggingPoint {
            let rect = curveRect()
            let touchPoint = panner.translationInView(self)
            // The "30" is magic; seems like it should be 40 for the inset. But 40 causes things to jump, 40 doesn't.
            // Is this the 30 the canvas view is offset from its superview? That doens't seem to make sense...
            let cp = CGPoint(x: (touchPoint.x - CGRectGetMinX(rect)) / CGRectGetWidth(rect),
                y: (CGRectGetMaxY(rect) + 30 - touchPoint.y) / CGRectGetHeight(rect))

            if (draggingPoint == pointLayer1) {
                controlPoint1 = cp
            } else {
                controlPoint2 = cp
            }

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer!.setNeedsLayout()
            CATransaction.commit()
        }
    }

    func curveRect() -> CGRect {
        return (80 > bounds.size.width || 80 > bounds.size.height) ? CGRectZero : CGRectInset(bounds, 40, 40)
    }

    func setControlPointsFromTimingFunction() {
        let points = UnsafeMutablePointer<Float>.alloc(2)

        timingFunction.getControlPointAtIndex(1, values: points)
        controlPoint1 = CGPoint(x: Double(points[0]), y: 1 - Double(points[1]))
        timingFunction.getControlPointAtIndex(2, values: points)
        controlPoint2 = CGPoint(x: Double(points[0]), y: 1 - Double(points[1]))
    }
}

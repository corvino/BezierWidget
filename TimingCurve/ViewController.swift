//
//  ViewController.swift
//  TimingCurve
//
//  Created by Nathan Corvino on 3/31/15.
//  Copyright (c) 2015 Nathan Corvino. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let graphInner = CAShapeLayer()
    let graphOuter = CAShapeLayer()
    let line1 = CAShapeLayer()
    let line2 = CAShapeLayer()
    let curve = CAShapeLayer()

    var pointView1 = NSView()
    var pointView2 = NSView()

    var settingsCp1 = CGPoint(x: 0.25, y: 1 - 0.10000000149011612)
    var settingsCp2 = CGPoint(x: 0.25, y: 1 - 0.10000000149011612)

    let isAnimating = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let darkBrownColor = NSColor(red: 72/255, green: 52/255, blue: 37/255, alpha: 1)
        let darkGreenColor = NSColor(red: 82/255, green: 151/255, blue: 103/255, alpha: 1)

        graphInner.strokeColor = darkBrownColor.CGColor
        graphInner.fillColor = NSColor.clearColor().CGColor
        graphInner.lineWidth = 2
        graphInner.frame = view.layer!.bounds

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

        setupPointView(pointView1, title: "1")
        setupPointView(pointView2, title: "2")

        view.wantsLayer = true
        view.layer!.addSublayer(graphInner)
        view.layer!.addSublayer(graphOuter)
        view.layer!.addSublayer(line1)
        view.layer!.addSublayer(line2)
        view.layer!.addSublayer(curve)
        view.addSubview(pointView1)
        view.addSubview(pointView2)
    }

    func curveRect() -> CGRect {
        return (80 > view.frame.size.width || 80 > view.frame.size.height) ? CGRectZero : CGRectInset(view.frame, 40, 40)
    }

    func setupPointView(pointView : NSView, title: String) {
        pointView.wantsLayer = true
        pointView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 44, height: 44))

        let circle = CAShapeLayer()
        circle.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: 8, y: 8), size: CGSize(width: 28, height: 28)), nil)
        circle.strokeColor = NSColor(red: 227/255, green: 228/255, blue: 199/255, alpha: 1).CGColor
        circle.fillColor = line1.strokeColor
        circle.lineWidth = 2
        circle.opacity = 0.8

        let text = CATextLayer()
        text.frame = CGRect(origin: CGPoint(x: 8, y: 8), size: CGSize(width: 28, height: 28))
        text.string = title
        text.alignmentMode = kCAAlignmentCenter;
        text.foregroundColor = NSColor.whiteColor().CGColor
        text.fontSize = 20

        pointView.layer!.shadowOpacity = 0.625
        pointView.layer!.shadowOffset = CGSizeMake(0, 1)
        pointView.layer!.shadowPath = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: 11, y: 11), size: CGSize(width: 22, height: 22)), nil)

        pointView.layer!.addSublayer(circle)
        pointView.layer!.addSublayer(text)

        pointView.addGestureRecognizer(NSPanGestureRecognizer(target: self, action: "handlePan:"))
    }

    func handlePan(gestureRecognizer : NSPanGestureRecognizer) {
        if !(.Cancelled == gestureRecognizer.state || .Ended == gestureRecognizer.state) {
            let rect = curveRect()
            var touchPoint = gestureRecognizer.locationInView(view)
            if touchPoint.x < CGRectGetMinX(rect)  {
                touchPoint.x = CGRectGetMinX(rect)
            } else if touchPoint.x > CGRectGetMaxX(rect) {
                touchPoint.y = CGRectGetMaxY(rect)
            }
            let cp = CGPoint(x: (touchPoint.x - CGRectGetMinX(rect)) / CGRectGetWidth(rect),
                             y: (CGRectGetMaxY(rect) - touchPoint.y) / CGRectGetHeight(rect))
            if gestureRecognizer.view == pointView1 {
                settingsCp1 = cp
            } else {
                settingsCp2 = cp
            }

            self.view.needsLayout = true
        }
    }

    override func viewWillLayout() {
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
        // Because of autoclose!!
        pathOuter.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect) + 0.5))

        graphInner.path = cocoaPathToQuartzPath(pathInner)
        graphOuter.path = cocoaPathToQuartzPath(pathOuter)

        updatePaths(0.1, animateLines: false)
    }

    func centeredRect(center: CGPoint, size: CGSize) -> CGRect {
        return CGRect(origin: CGPoint(x: center.x - size.width  / 2, y: center.y - size.height / 2), size: size)
    }

    func updatePaths(duration: CGFloat, animateLines: Bool) {
        let rect = curveRect()
        let cp1 = CGPoint(x: CGRectGetMinX(rect) + settingsCp1.x * CGRectGetWidth(rect),
                          y: CGRectGetMaxY(rect) - settingsCp1.y * CGRectGetHeight(rect))
        let cp2 = CGPoint(x: CGRectGetMinX(rect) + settingsCp2.x * CGRectGetWidth(rect),
                          y: CGRectGetMaxY(rect) - settingsCp2.y * CGRectGetHeight(rect))
        let pathCurve = NSBezierPath()

        pathCurve.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect)))
        pathCurve.curveToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)), controlPoint1: cp1, controlPoint2: cp2)
        pathCurve.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect)))

        let pathLine1 = NSBezierPath()
        pathLine1.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinX(rect)))
        pathLine1.lineToPoint(cp1)

        let pathLine2 = NSBezierPath()
        pathLine2.moveToPoint(cp2)
        pathLine2.lineToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))

        CATransaction.begin()
        CATransaction.setAnimationDuration(CFTimeInterval(duration))
        let animation = CABasicAnimation(keyPath: "path")
        let cgPath = cocoaPathToQuartzPath(pathCurve)
        if let layer = curve.presentationLayer() as? CAShapeLayer {
            animation.fromValue = layer.path
            animation.toValue = cgPath
        }

        if (animateLines) {

        } else {
            pointView1.frame = centeredRect(cp1, size: pointView1.frame.size)
            pointView2.frame = centeredRect(cp2, size: pointView2.frame.size)
        }

        curve.path = cgPath
        self.line1.path = cocoaPathToQuartzPath(pathLine1)
        self.line2.path = cocoaPathToQuartzPath(pathLine2)
    }

    func cocoaPathToQuartzPath(bezierPath: NSBezierPath) -> CGPathRef? {
        var retval : CGPathRef?

        if (0 < bezierPath.elementCount) {
            let path = CGPathCreateMutable()
            let points = NSPointArray.alloc(3)
            var pathOpen = false

            for var i = 0; i < bezierPath.elementCount; i++ {
                switch(bezierPath.elementAtIndex(i, associatedPoints: points)) {
                case .MoveToBezierPathElement:
                    CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
                case .LineToBezierPathElement:
                    CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
                    pathOpen = true
                case .CurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
                    pathOpen = true
                case .ClosePathBezierPathElement:
                    CGPathCloseSubpath(path)
                    pathOpen = false
                }
            }

            if (pathOpen) {
                CGPathCloseSubpath(path)
            }

            retval =  CGPathCreateCopy(path)
            points.dealloc(3)
        }

        return retval
    }
}

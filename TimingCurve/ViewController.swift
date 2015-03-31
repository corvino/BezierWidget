//
//  ViewController.swift
//  TimingCurve
//
//  Created by Nathan Corvino on 3/31/15.
//  Copyright (c) 2015 Nathan Corvino. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var curveContainer : NSView?

    let graphInner = CAShapeLayer()
    let graphOuter = CAShapeLayer()
    let line1 = CAShapeLayer()
    let line2 = CAShapeLayer()
    let curve = CAShapeLayer()

    var pointView1 = NSView()
    var pointView2 = NSView()


    override func viewDidLoad() {
        super.viewDidLoad()

        let darkBrownColor = NSColor(red: 72/255, green: 52/255, blue: 37/255, alpha: 1)

        graphInner.strokeColor = darkBrownColor.CGColor
        graphInner.fillColor = NSColor.redColor().CGColor
        graphInner.lineWidth = 2
        graphInner.frame = self.view.layer!.bounds
//        graphInner.backgroundColor = NSColor.redColor().CGColor

        graphOuter.strokeColor = darkBrownColor.colorWithAlphaComponent(0.5).CGColor
        graphOuter.fillColor = NSColor.clearColor().CGColor
        graphOuter.lineWidth = 1
        graphOuter.lineDashPattern = [6, 5]

        line1.strokeColor = NSColor.greenColor().CGColor
        line1.fillColor = NSColor.clearColor().CGColor
        line1.lineWidth = 2
        line1.lineDashPattern = [3, 3]

        line2.strokeColor = NSColor.greenColor().CGColor
        line2.fillColor = NSColor.clearColor().CGColor
        line2.lineWidth = 2
        line2.lineDashPattern = [3, 3]

        curveContainer = view

        self.view.layer!.addSublayer(graphInner)
        self.view.layer!.addSublayer(graphOuter)
        self.view.layer!.addSublayer(line1)
        self.view.layer!.addSublayer(line2)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func setupPointView(pointView : NSView) {
        pointView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 44, height: 44))
        pointView.layer!.opacity = 0.8

        let circle = CAShapeLayer()
        circle.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: 8, y: 8), size: CGSize(width: 28, height: 28)), nil)
        circle.strokeColor = NSColor(red: 227/255, green: 228/255, blue: 199/255, alpha: 1).CGColor
        circle.fillColor = line1.strokeColor
        circle.lineWidth = 2
    }

    override func viewWillLayout() {
        if let rect = curveContainer?.frame {
            let pathInner = NSBezierPath()
            pathInner.moveToPoint(CGPoint(x: rect.origin.x, y: rect.origin.y - 16))
            pathInner.lineToPoint(CGPoint(x: rect.origin.x - 3, y: rect.origin.y + 10))
            pathInner.closePath()

            pathInner.moveToPoint(CGPoint(x: rect.origin.x, y: rect.origin.y - 10))
            pathInner.lineToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect)))
            pathInner.lineToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect)))

            pathInner.moveToPoint(CGPoint(x: CGRectGetMaxX(rect) + 16, y: CGRectGetMaxY(rect)))
            pathInner.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) + 10, y: CGRectGetMaxY(rect) - 3))
            pathInner.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) + 10, y: CGRectGetMaxY(rect) + 3))
            pathInner.closePath()

            let pathOuter = NSBezierPath()
            pathOuter.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect) + 0.5))
            pathOuter.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) - 0.5, y: CGRectGetMinY(rect) + 0.5))
            pathOuter.lineToPoint(CGPoint(x: CGRectGetMaxX(rect) - 0.5, y: CGRectGetMaxY(rect)))

            self.graphInner.path = cocoaPathToQuartzPath(pathInner)
            self.graphOuter.path = cocoaPathToQuartzPath(pathOuter)
        }
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
                    CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
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

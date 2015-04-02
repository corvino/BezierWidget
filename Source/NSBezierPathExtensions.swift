//
//  NSBezierPathExtensions.swift
//  TimingCurve
//
//  Created by Nathan Corvino on 4/2/15.
//  Copyright (c) 2015 Nathan Corvino. All rights reserved.
//

import AppKit

extension NSBezierPath {
    func cgPath() -> CGPathRef? {
        var retval : CGPathRef?

        if (0 < elementCount) {
            let path = CGPathCreateMutable()
            let points = NSPointArray.alloc(3)
            var pathOpen = false

            for var i = 0; i < elementCount; i++ {
                switch(elementAtIndex(i, associatedPoints: points)) {
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

//            if (pathOpen) {
//                CGPathCloseSubpath(path)
//            }

            retval =  CGPathCreateCopy(path)
            points.dealloc(3)
        }

        return retval
    }
}

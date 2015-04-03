//
//  ViewController.swift
//  BezierWidget
//
//  Created by Nathan Corvino on 3/31/15.
//  Copyright (c) 2015 Nathan Corvino. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var bezierWidget: BezierWidget!

    @IBOutlet weak var cp1TextField: NSTextField!
    @IBOutlet weak var cp2TextField: NSTextField!
    @IBOutlet weak var curvePopUp: NSPopUpButton!
    @IBOutlet weak var customTimingMenuItem: NSMenuItem!

    var changingTiming = false

    deinit {
        bezierWidget.removeObserver(self, forKeyPath: "controlPoint1")
        bezierWidget.removeObserver(self, forKeyPath: "controlPoint2")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.cp1TextField.stringValue = String(NSString(format: "(%0.2f,%0.2f)" , bezierWidget.controlPoint1.x, bezierWidget.controlPoint1.y))
        self.cp2TextField.stringValue = String(NSString(format: "(%0.2f,%0.2f)" , bezierWidget.controlPoint2.x, bezierWidget.controlPoint2.y))

        bezierWidget.addObserver(self, forKeyPath: "controlPoint1", options: NSKeyValueObservingOptions.New, context: nil)
        bezierWidget.addObserver(self, forKeyPath: "controlPoint2", options: NSKeyValueObservingOptions.New, context: nil)
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case "controlPoint1":
            let controlPoint = change["new"] as! NSValue
            self.cp1TextField.stringValue = String(NSString(format: "(%0.2f,%0.2f)" , controlPoint.pointValue.x, controlPoint.pointValue.y))
            if !changingTiming { curvePopUp.selectItem(customTimingMenuItem) }
        case "controlPoint2":
            let controlPoint = change["new"] as! NSValue
            self.cp2TextField.stringValue = String(NSString(format: "(%0.2f,%0.2f)" , controlPoint.pointValue.x, controlPoint.pointValue.y))
            if !changingTiming { curvePopUp.selectItem(customTimingMenuItem) }
        default:
            break
        }
    }

    @IBAction func curvePopUpChanged(sender: AnyObject) {
        var timingFunction : CAMediaTimingFunction?
        switch curvePopUp.indexOfSelectedItem {
        case 0:
            timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        case 1:
            timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        case 2:
            timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        case 3:
            timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        case 4:
            timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        default:
            break
        }

        if nil != timingFunction {
            changingTiming = true
            bezierWidget.timingFunction = timingFunction
            changingTiming = false
        }
    }
}

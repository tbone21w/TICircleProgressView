//
//  TICircleProgress.swift
//  TICircleProgress
//
//  Created by Todd Isaacs on 4/21/16.
//  Copyright © 2016 Todd Isaacs. All rights reserved.
//
import UIKit

@IBDesignable
class TICircleProgressView: UIView {
  
  @IBInspectable
  var trackBackgroundColor:UIColor = UIColor(red: 0.652, green: 0.800, blue: 0.320, alpha: 1.000)
  
  @IBInspectable
  var trackColor:UIColor = UIColor(red: 0.797, green: 0.320, blue: 0.800, alpha: 1.000)
  
  @IBInspectable
  var progress: Float = 0.0 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable
  var fontName: String = "Arial" {
    didSet {
      fontValidated = false
      setNeedsDisplay()
    }
  }
  
  @IBInspectable
  var displaySize: CGFloat = 35
  
  @IBInspectable
  var labelSize: CGFloat = 10
  
  @IBInspectable
  var trackWidth: CGFloat = 10
  
  
  @IBInspectable
  var label: String = "Complete"
  
  //selected font to use
  private var font: UIFont!
  private var fontValidated = false
  
  private let π:CGFloat = CGFloat(M_PI)
  
  
  
  override func drawRect(rect: CGRect) {
    drawProgressView()
  }
  
  lazy var systemFontFamilies: [String] = {
    let fontFamilies = UIFont.familyNames()
    return fontFamilies
  }()
  
  
  /**
   Validates the font string against the systems fonts.  This happens everytime the font is
   set. Invalid fonts will be ignored and set to the default.
   */
  private func validateFont() {
    for fontFamily in systemFontFamilies {
      let fontNames: NSArray = UIFont.fontNamesForFamilyName(fontFamily) as NSArray
      
      for systemFontName in fontNames {
        if systemFontName as! String == fontName {
          self.font = UIFont(name: systemFontName as! String, size: 10)!
          
          fontValidated = true
          return
        }
        print(" * \(fontNames)")
      }
      
    }
    
    //no font found
    self.font = UIFont(name: "Arial", size: 10)!
    
    fontValidated = true
  }
  
  
  /**
   Creates the largest CGRect to house the circular component with an origin that
   is centered in the given frame.  This will be used to position and size the
   centered display text.
   
   - Parameter frame:  CGRect of the UIView frame
   
   - Returns:          The largest square CGRect that is contained in the center of the
   CGRect.
   */
  private func getTargetDrawArea(frame: CGRect) -> CGRect {
    let maxRect:CGRect
    let size:CGFloat
    let origin:CGPoint
    
    if frame.width >= frame.height {
      //Use height since width is larger
      size = frame.height - trackWidth
      let offsetX = (frame.width - frame.height)/2 + trackWidth / 2.0
      let offsetY = trackWidth / 2.0
      origin = CGPoint(x: offsetX, y: offsetY)
      
    } else {
      //use width since height is greater
      size = frame.width - trackWidth
      let offsetY = (frame.height - frame.width)/2 + trackWidth / 2.0
      let offsetX = trackWidth / 2.0
      origin = CGPoint(x: offsetX, y: offsetY)
    }
    
    maxRect = CGRect(origin: origin, size: CGSize(width: size, height: size))
    return maxRect
  }
  
  
  /**
   Converts the given percentage to a radian value based on a circle where the 0 is
   the top (3π/2).  This value will not go over 100 (3π/2).  When the value is 0 the
   value returned will be equivalent to 0.3 percent to show a sliver on the progress
   indicator to represent the starting point.
   
   IOS circular arc
   Top:      270 degrees --> 3π/2
   Right:    0   degrees --> 2π
   Bottom:   90  degrees --> π/2
   Left:     180 degrees --> π
   
   - Parameter percentage:   float value 0 - 100
   
   - Returns:  radian value based on a circle with 0 degrees starting at the top
   */
  private func percentToRadian(percent:Float) -> CGFloat {
    var endAngleRadians: CGFloat
    if progress >= 100 {
      endAngleRadians  = CGFloat((Double(99.99/100 * 360) - Double(90)) * M_PI / 180)
    } else if progress <= 0 {
      endAngleRadians  = CGFloat((Double(0.3/100 * 360) - Double(90)) * M_PI / 180)
    } else {
      endAngleRadians  = CGFloat((Double(progress/100 * 360) - Double(90)) * M_PI / 180)
    }
    
    return endAngleRadians
  }
  
  
  /**
   Calculates the size the font will be based on the given font attributes.
   
   - Parameter sampleText:  String of text to draw
   - Parameter fontAttributes  [String: AnyObject] dictionary of font attributes.
   
   [NSFontAttributeName: UIFont(name: "TrebuchetMS", size: UIFont.smallSystemFontSize())!,
   NSForegroundColorAttributeName: contCOlor,
   NSParagraphStyleAttributeName: messageStyle]
   
   - Returns:  CGFloat for the calcualted height of the sample text
   
   NOTE: this needs some work it is returning values that are too large
   */
  private func calcActualFontHeight(sampleText: String, fontAttributes: [String: AnyObject]) -> CGFloat {
    let drawRect = self.getTargetDrawArea(frame)
    let nsString = NSString(string: label)
    
    let boundingRect = nsString.boundingRectWithSize(CGSize(width: drawRect.width, height: drawRect.height),
                                                     options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                                     attributes: fontAttributes,
                                                     context: nil)
    
    return boundingRect.size.height
    
  }
  
  
  /**
   Draws the circular track
   */
  private func drawTrack(frame: CGRect) {
    trackBackgroundColor.setStroke()
    let ovalPath = UIBezierPath(ovalInRect: frame)
    ovalPath.lineWidth = trackWidth
    ovalPath.stroke()
  }
  
  
  /**
   Draws the progress indicator on the track
   */
  private func drawProgress(frame: CGRect) {
    trackColor.setStroke()
    
    let startAngle: CGFloat = 3 * π / 2
    
    let endAngleRadians: CGFloat = percentToRadian(progress)
    
    let centerX: CGFloat = frame.minX + frame.width / 2
    let centerY: CGFloat = frame.minY + frame.width / 2
    
    let completePath = UIBezierPath(arcCenter: CGPoint(x: centerX , y: centerY),
                                    radius: frame.width/2,
                                    startAngle: startAngle,
                                    endAngle: endAngleRadians,
                                    clockwise: true)
    
    
    completePath.lineWidth = trackWidth
    completePath.stroke()
  }
  
  
  /**
   Draws the progress text in the center.
   */
  private func drawProgressText(progressText: String, drawRect: CGRect) {
    
    if !fontValidated {
      validateFont()
    }
    
    let textStyle = NSMutableParagraphStyle()
    textStyle.alignment = .Center
    
    let progressFont:UIFont = UIFont(name: font!.fontName, size: displaySize)!
    
    let progressTextFontAttributes = [NSFontAttributeName: progressFont, NSForegroundColorAttributeName: trackColor, NSParagraphStyleAttributeName: textStyle]
    
    let PROGRESS_TEXT_HEIGHT:CGFloat = displaySize + 4
    
    let xPos = drawRect.minX
    let yPos = drawRect.minY + drawRect.width/2 - PROGRESS_TEXT_HEIGHT/2
    
    let progressMessageRect = CGRect(x: xPos,
                                     y: yPos,
                                     width: drawRect.width,
                                     height: PROGRESS_TEXT_HEIGHT)
    
    drawText(progressText, fontAttributes: progressTextFontAttributes, frame: progressMessageRect)
  }
  
  
  /**
   Draws the label in the center under the progress text
   */
  private func drawLabelText(labelText:String, drawRect: CGRect) {
    
    if !fontValidated {
      validateFont()
    }
    
    let textStyle = NSMutableParagraphStyle()
    textStyle.alignment = .Center
    
    let labelFont = UIFont(name: font!.fontName, size: labelSize)!
    
    let labelTextFontAttributes = [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: trackColor, NSParagraphStyleAttributeName: textStyle]
    
    let LABEL_TEXT_HEIGHT:CGFloat = labelSize + 3
    let PROGRESS_TEXT_HEIGHT:CGFloat = displaySize + 3
    
    let xPos = drawRect.minX
    let yPos = drawRect.minY + drawRect.width/2 + PROGRESS_TEXT_HEIGHT/2
    
    
    let labelRect = CGRect(x: xPos,
                           y: yPos,
                           width: drawRect.width,
                           height: LABEL_TEXT_HEIGHT)
    
    drawText(labelText, fontAttributes: labelTextFontAttributes, frame: labelRect)
  }
  
  
  /**
   Draws text in a given rectangle with given attributes
   */
  private func drawText(text: String, fontAttributes: [String: AnyObject], frame:CGRect) {
    let context = UIGraphicsGetCurrentContext()
    CGContextSaveGState(context)
    CGContextClipToRect(context, frame)
    
    NSString(string: text).drawInRect(frame, withAttributes: fontAttributes)
    
    CGContextRestoreGState(context)
  }
  
  
  /**
   Draws the progress component view
   */
  func drawProgressView() {
    
    let drawRect = getTargetDrawArea(self.frame)
    let progressText = "\(Int(round(progress)))" + "%"
    
    drawTrack(drawRect)
    drawProgress(drawRect)
    
    drawLabelText(label, drawRect: drawRect)
    drawProgressText(progressText, drawRect: drawRect)
  }
}

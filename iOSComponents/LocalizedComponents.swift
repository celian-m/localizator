
//
//  LocalizedLabel.swift
//  DirectAssurance
//
//  Created by Célian MOUTAFIS on 17/03/2016.
//  Copyright © 2016 MyStudioFactory. All rights reserved.
//

import UIKit


let _underline_height : CGFloat = 4
/** Shorthand for NSLocalizedStirng*/
func l( string : String) -> String {
    return Localizator.localizedString(string)
}

@objc public class LocalizedLabel: UILabel {
    @IBInspectable public var localizedText : String = "" {
        didSet {
            self.reload()
        }
    }
    @IBInspectable public var uppercased : Bool = false {
        didSet {
            self.reload()
        }
    }
    func reload(){
        let str = self.uppercased ? l(self.localizedText).uppercaseString : l(self.localizedText)
        if self.justified && self.text != nil{
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.Justified
            style.firstLineHeadIndent = 0.00001
            let attributed = NSAttributedString(string: str, attributes: [NSParagraphStyleAttributeName : style, NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor])
            self.attributedText = attributed
        }else{
            self.text = str;
        }
        
    
    }
 
    @IBInspectable public var underlined : Bool = false
    @IBInspectable public var justified : Bool = false {
        didSet {
            self.reload()
        }
    }
    
    override public func drawRect(rect: CGRect) {
        
        if self.underlined {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetStrokeColorWithColor(context, self.textColor.CGColor)
            CGContextSetLineWidth(context, _underline_height)
            CGContextMoveToPoint(context, self.frame.size.width / 2 - 12.5, self.frame.size.height)
            CGContextAddLineToPoint(context, self.frame.size.width / 2 + 12.5, self.frame.size.height)
            CGContextStrokePath(context)
        }
        super.drawRect(rect)
    }
    
}

public class LocalizedButton: UIButton {
    
    @IBInspectable public var numberOfLines : NSInteger = 0
    @IBInspectable public var underlined : Bool = false
    @IBInspectable public var bordered : Bool = false {
        didSet {
            self.reload()
        }
    }
    @IBInspectable public var cornered : Bool = false {
        didSet {
            self.reload()
        }
    }
    
    @IBInspectable public var uppercased : Bool = false {
        didSet {
            self.reload()
        }
    }
    
    override public func drawRect(rect: CGRect) {
        
        if self.underlined {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetStrokeColorWithColor(context, self.titleColorForState(self.state)?.CGColor)
            CGContextSetLineWidth(context, _underline_height)
            CGContextMoveToPoint(context, self.frame.size.width / 2 - 12.5, self.frame.size.height)
            CGContextAddLineToPoint(context, self.frame.size.width / 2 + 12.5, self.frame.size.height)
            CGContextStrokePath(context)
        }
        super.drawRect(rect)
    }
    
    @IBInspectable public var localizedText : String = "" {
        didSet {
            self.reload()
            self.titleLabel!.numberOfLines = self.numberOfLines
            self.titleLabel!.textAlignment = .Center
            self.imageView?.contentMode = .ScaleAspectFit
           
        }
    }
    
   // private var _rightImage : String = ""
    
    @IBInspectable public var rightImage : String = "" {
        didSet {
            self.reload()
        }
    }
    
    private var rightImageViewContainer : UIView?
    private var rightImageView : UIView?
    
    func reload(){
        let str =  self.uppercased ? l(self.localizedText).uppercaseString : l(self.localizedText)
        self.setTitle(str, forState: .Normal)
        self.setTitle(str, forState: .Disabled)
        if (self.imageForState(.Normal) != nil) {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        }
        self.layer.cornerRadius = self.cornered ? self.frame.size.height / 2 : 0
        self.layer.masksToBounds = true
        
        if (rightImageViewContainer != nil){
            rightImageViewContainer?.removeFromSuperview()
            rightImageViewContainer = nil
        }
        if rightImage.characters.count > 0 {
            let titleFrame = self.titleLabel!.frame
            var size = self.frame.size
            size.width = (size.width - titleFrame.origin.x - titleFrame.size.width)
            
            rightImageViewContainer = UIView(frame: CGRectMake((titleFrame.origin.x + titleFrame.size.width), 0, size.width, size.height))
            self.addSubview(rightImageViewContainer!)
            
            rightImageViewContainer?.contentMode = .Center
            rightImageViewContainer?.backgroundColor = UIColor.whiteColor()
            
            rightImageViewContainer?.translatesAutoresizingMaskIntoConstraints = false
            let ref : CGFloat = 25
            let trailing = NSLayoutConstraint(item: rightImageViewContainer!, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -5)
            
            let width = NSLayoutConstraint(item: rightImageViewContainer!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: ref)
            
            let heigth = NSLayoutConstraint(item: rightImageViewContainer!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: ref)
            
            let centerY =  NSLayoutConstraint(item: rightImageViewContainer!, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
            
            self.addConstraints([trailing, width, heigth, centerY])
            rightImageViewContainer?.userInteractionEnabled = false
            
            
            
        }
        
        if self.bordered {
            self.layer.borderColor = self.titleColorForState(.Normal)?.CGColor
            self.layer.borderWidth = 1
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (rightImageViewContainer != nil){
            rightImageViewContainer!.layer.cornerRadius = rightImageViewContainer!.frame.size.height / 2
            rightImageView?.removeFromSuperview()
            rightImageView = nil
            let margin : CGFloat = 3
            let imageView = UIImageView(frame: CGRectMake(margin, margin, rightImageViewContainer!.frame.size.width - 2*margin, rightImageViewContainer!.frame.size.height - 2*margin))
            imageView.image = UIImage(named: rightImage)?.imageWithRenderingMode(.AlwaysTemplate)
            imageView.tintColor = self.tintColor
            imageView.contentMode = .ScaleAspectFit
            rightImageViewContainer?.addSubview(imageView)
            rightImageView = imageView
            imageView.userInteractionEnabled = false
        }
    }
    
    private var _enabled:Bool = true
    override public var enabled : Bool {
        get {
            return _enabled
        }
        set {
            if newValue {
                self.alpha = 1
            }else{
                self.alpha = 0.6
            }
            _enabled = newValue
            super.enabled = newValue
       }
    }
    
}


public class LocalizedTextField: UITextField {
    
    @IBInspectable public var localizedPlaceholder : String = "" {
        didSet {
            self.reload()
        }
    }
    
    func reload(){
        let str = l(self.localizedPlaceholder)
        self.placeholder = str
    }
    
    func textFieldWantNextResponder(sender : AnyObject?){
        let selector = #selector(textFieldWantNextResponder(_:))
        if self.delegate != nil && self.delegate!.respondsToSelector(selector) {
            self.delegate!.performSelector(selector, withObject: sender!)
        }
    }
    
    func textFieldWantPreviousResponder(sender : AnyObject?){
        let selector = #selector(textFieldWantPreviousResponder(_:))
        if self.delegate != nil && self.delegate!.respondsToSelector(selector) {
            self.delegate!.performSelector(selector, withObject: sender!)
        }
    }
}





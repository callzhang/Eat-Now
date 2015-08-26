//
//  TextfieldWithInset.swift
//  WaiJiaoLaiLe
//
//  Created by Zitao Xiong on 3/2/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TextfieldWithInset: UITextField {
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
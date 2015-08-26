//
//  ApplicationButton.swift
//  WaiJiaoLaiLe
//
//  Created by Zitao Xiong on 3/2/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ApplicationButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var layerBorderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = layerBorderWidth
        }
    }
    @IBInspectable var layerBorderColor: UIColor = UIColor.clearColor(){
        didSet {
            layer.borderColor = layerBorderColor.CGColor
        }
    }
    @IBInspectable var layerBorderRespectingPixelOverPoint: Bool = false {
        didSet {
            if (layerBorderRespectingPixelOverPoint) {
               layer.borderWidth = layerBorderWidth * self.onePixel()
            }
        }
    }
    
    func onePixel() -> CGFloat {
        let onePixel = 1.0 / UIScreen.mainScreen().scale;
        return onePixel
    }
}
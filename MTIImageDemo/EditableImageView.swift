//
//  EditableImageView.swift
//  MTIImageDemo
//
//  Created by Scott Zhu on 11/22/18.
//  Copyright © 2018 Scott Zhu. All rights reserved.
//

import UIKit
import MetalPetal
import MetalKit

open class UIEditableImageView: UIImageView {
    
    fileprivate lazy var context: MTIContext? = {
        let options = MTIContextOptions()
        guard let device = MTLCreateSystemDefaultDevice(),
            let context = try? MTIContext(device: device, options: options) else { return nil }
        return context
    }()
    
    fileprivate lazy var renderView: MTKView = {
        let view = MTKView(frame: .zero, device: context?.device)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.isOpaque = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    fileprivate lazy var renderRequest: MTIDrawableRenderingRequest = {
        let request = MTIDrawableRenderingRequest()
        request.drawableProvider = self.renderView
        request.resizingMode = MTIDrawableRenderingResizingMode.aspectFill
        return request
    }()
    
    fileprivate var originalImage: UIImage?
    fileprivate var inputImage: MTIImage?
    fileprivate var outputImage: MTIImage?
    
    override open var image: UIImage? {
        didSet {
            originalImage = image
            if let cgImage = image?.cgImage {
                inputImage = MTIImage(cgImage: cgImage, options: [MTKTextureLoader.Option.SRGB: false], isOpaque: true)
            } else {
                print("Not able to find CGImage on this UIImage")
            }
        }
    }
    
    public fileprivate(set) var appliedFilter: MTIUnaryFilter?
    
    fileprivate lazy var brightnessFilter: MTIBrightnessFilter = {
        var brightnessFilter = MTIBrightnessFilter()
        brightnessFilter.brightness = 0
        return brightnessFilter
    }()
    //The adjusted brightness (-1.0 - 1.0, with 0.0 as the default)
    open var brightness: Float {
        set {
            self.renderView.isPaused = false
            brightnessFilter.brightness = newValue
        }
        get { return brightnessFilter.brightness }
    }
    
    fileprivate lazy var contrastFilter: MTIContrastFilter = {
        var contrastFilter = MTIContrastFilter()
        contrastFilter.contrast = 1.0
        return contrastFilter
    }()
    //The adjusted contrast (0.0 - 4.0, with 1.0 as the default)
    open var contrast: Float {
        set {
            self.renderView.isPaused = false
            contrastFilter.contrast = newValue
        }
        get { return contrastFilter.contrast }
    }
    
    fileprivate lazy var saturationFilter: MTISaturationFilter = {
        var saturationFilter = MTISaturationFilter()
        return saturationFilter
    }()
    //The saturation. 0 - 2, 1 by default
    open var saturation: Float {
        set {
            self.renderView.isPaused = false
            saturationFilter.saturation = newValue
        }
        get { return saturationFilter.saturation }
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        originalImage = image
        if let cgImage = image?.cgImage {
            inputImage = MTIImage(cgImage: cgImage, options: [MTKTextureLoader.Option.SRGB: false], isOpaque: true)
        } else {
            print("Not able to find CGImage on this UIImage")
        }
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    fileprivate func initialize() {
        addSubview(renderView)
        renderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        renderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        renderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        renderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIEditableImageView: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        brightnessFilter.inputImage = self.inputImage
        contrastFilter.inputImage = brightnessFilter.outputImage
        saturationFilter.inputImage = contrastFilter.outputImage
        guard let ajustedImage = saturationFilter.outputImage else { return }
        var outputImage = ajustedImage
        
        if let appliedFilter = appliedFilter {
            appliedFilter.inputImage = ajustedImage
            if let filteredImage = appliedFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        do {
            try autoreleasepool {
                try self.context?.render(outputImage, toDrawableWithRequest: renderRequest)
                self.outputImage = outputImage
            }
        } catch {
            print(error)
        }
        view.isPaused = true
        self.context?.reclaimResources()
    }
}

public extension MTIBrightnessFilter {
    class var maxValue: Float { return 1.0 }
    class var minValue: Float { return -1.0 }
    class var defaultValue: Float { return 0.0 }
}

public extension MTIContrastFilter {
    class var maxValue: Float { return 4.0 }
    class var minValue: Float { return 0.0 }
    class var defaultValue: Float { return 1.0 }
}

public extension MTISaturationFilter {
    class var maxValue: Float { return 2.0 }
    class var minValue: Float { return 0.0 }
    class var defaultValue: Float { return 1.0 }
}



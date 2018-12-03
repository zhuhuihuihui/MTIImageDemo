//
//  ViewController.swift
//  MTIImageDemo
//
//  Created by Scott Zhu on 11/22/18.
//  Copyright © 2018 Scott Zhu. All rights reserved.
//

import UIKit
import MetalPetal

class ViewController: UIViewController {
    
//    public lazy var imageView: UIEditableImageView = {
//        let imageView = UIEditableImageView(image: UIImage.init(named: "IMG_0355"))
//        imageView.clipsToBounds = true
//        imageView.contentMode = .scaleAspectFit
////        imageView.translatesAutoresizingMaskIntoConstraints = false
////        imageView.frame = UIScreen.main.bounds
//        return imageView
//    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        return scrollView
    }()
    
    lazy var imageView: MTIImageView = {
//        var imageView = MTIImageView(frame: .zero)
        var imageView = MTIImageView(frame: CGRect.init(x: 0, y: 0, width: 4032, height: 3024))
        imageView.isUserInteractionEnabled = true
        imageView.resizingMode = .aspectFill
        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var inputImage: MTIImage? = {
        guard let cgImage = UIImage(named: "IMG_0355")?.cgImage else { return nil }
        let mtiImage = MTIImage(cgImage: cgImage, options: [.SRGB: false], isOpaque: true)
        return mtiImage
    }()
    
    fileprivate lazy var brightnessFilter: MTIBrightnessFilter = {
        var brightnessFilter = MTIBrightnessFilter()
        brightnessFilter.brightness = 0
        return brightnessFilter
    }()
    
    fileprivate lazy var contrastFilter: MTIContrastFilter = {
        var contrastFilter = MTIContrastFilter()
        contrastFilter.contrast = 1.0
        return contrastFilter
    }()
    
    fileprivate lazy var saturationFilter: MTISaturationFilter = {
        var saturationFilter = MTISaturationFilter()
        return saturationFilter
    }()
    
    var outputImage: MTIImage? {
        self.brightnessFilter.inputImage = self.inputImage
        self.contrastFilter.inputImage = brightnessFilter.outputImage
        saturationFilter.inputImage = contrastFilter.outputImage
        guard let output = saturationFilter.outputImage else { return nil }
        return output
    }
    
    lazy var sliderBrightness: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = MTIBrightnessFilter.minValue
        slider.maximumValue = MTIBrightnessFilter.maxValue
        slider.value = MTIBrightnessFilter.defaultValue
        slider.addTarget(self, action: #selector(brightnessValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    lazy var sliderContrast: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = MTIContrastFilter.minValue
        slider.maximumValue = MTIContrastFilter.maxValue
        slider.value = MTIContrastFilter.defaultValue
        slider.addTarget(self, action: #selector(contrastValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    lazy var sliderSaturation: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = MTISaturationFilter.minValue
        slider.maximumValue = MTISaturationFilter.maxValue
        slider.value = MTISaturationFilter.defaultValue
        slider.addTarget(self, action: #selector(saturationValueChanged(_:)), for: .valueChanged)
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.addSubview(imageView)
        scrollView.contentSize = imageView.bounds.size
        
        view.addSubview(sliderContrast)
        view.addSubview(sliderBrightness)
        view.addSubview(sliderSaturation)
        sliderSaturation.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        sliderSaturation.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        sliderSaturation.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        sliderBrightness.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        sliderBrightness.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        sliderBrightness.bottomAnchor.constraint(equalTo: sliderSaturation.topAnchor, constant: -8).isActive = true
        
        sliderContrast.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        sliderContrast.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        sliderContrast.bottomAnchor.constraint(equalTo: sliderBrightness.topAnchor, constant: -8).isActive = true
        
        imageView.image = self.outputImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let zoomScale = view.frame.size.width / imageView.frame.size.width
        scrollView.zoomScale = zoomScale
        scrollView.minimumZoomScale = zoomScale
        scrollView.maximumZoomScale = 1
    }
    
    @objc func brightnessValueChanged(_ sender: UISlider) {
        self.brightnessFilter.brightness = sender.value
        imageView.image = self.outputImage
    }
    
    @objc func contrastValueChanged(_ sender: UISlider) {
        self.contrastFilter.contrast = sender.value
        imageView.image = self.outputImage
    }
    
    @objc func saturationValueChanged(_ sender: UISlider) {
        self.saturationFilter.saturation = sender.value
        imageView.image = self.outputImage
    }

}

// MARK: - UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


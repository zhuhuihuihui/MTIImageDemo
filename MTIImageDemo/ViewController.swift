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
    
    public lazy var imageView: UIEditableImageView = {
        let imageView = UIEditableImageView(image: UIImage.init(named: "IMG_0355"))
        imageView.clipsToBounds = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
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
    }
    
    @objc func brightnessValueChanged(_ sender: UISlider) {
        imageView.brightness = sender.value
    }
    
    @objc func contrastValueChanged(_ sender: UISlider) {
        imageView.contrast = sender.value
    }
    
    @objc func saturationValueChanged(_ sender: UISlider) {
        imageView.saturation = sender.value
    }

}


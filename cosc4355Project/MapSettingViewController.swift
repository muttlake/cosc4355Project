//
//  MapSettingViewController.swift
//  cosc4355Project
//
//  Created by Qaem on 12/4/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class MapSettingViewController: UIViewController {
    
    var parentView: MapsViewController?
    weak var delegate: MapSettingProtocol?
    
    
    @IBOutlet weak var radiusInMileLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider)
    {
        radiusInMileLabel.text = String(round(Double(slider.value)))
    }
    
    
    @IBAction func saveMapSetting(_ sender: UIButton)
    {
        delegate?.updateMaxTravelDistanceIn(miles: Double(round(Double(slider.value))))
    }
    
    
    func setSliderValue(value : Float)
    {
        slider.setValue(value, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
}

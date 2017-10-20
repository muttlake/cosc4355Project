//
//  MapsViewController.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/16/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapsViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var map: MKMapView!
    
    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        
        //set your debug location to : 29.716887, -95.338975  (HBS building)
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
        
        map.setRegion(region, animated: true)
        
        //print(location.coordinate)
        
        let annotationLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(29.721543, -95.343632)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationLocation
        annotation.title = "PGH"
        annotation.subtitle = "Bad plumbing."
        
        map.addAnnotation(annotation)
        
        self.map.showsUserLocation = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
          }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

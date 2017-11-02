//  MapsViewController.swift
//  cosc4355Project
//  Qaem Parasla


import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation
import CoreFoundation

class MapsViewController: UIViewController{
    
    //var locationManager = CLLocationManager()
    var locationManager : CLLocationManager?
    var postingReference : FIRDatabaseReference?
    var distanceToTraveRadius : Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationServiceIsUnAvailableView: UIView!
    
    @IBOutlet weak var enableLocationServicesButton: UIButton!
    
    @IBAction func enableLocationServicesButton(_ sender: UIButton) {
        //Send user to app setting to turn on location services
        UIApplication.shared.open(URL(string:"App-Prefs:root=Privacy")!, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        showLocationAvailabilityView(isViewHidden: true)
        postingReference = FIRDatabase.database().reference().child("projects")//get ref to atribute posting
        distanceToTraveRadius = 50
        locationManager?.delegate = self
        mapView.delegate = self
    }
    
    
    func retrivePostingFromDatabase()
    {
        postingReference?.observe(.value, with: { (snapshot) in
            
            for projects in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let project = projects.value as? [String: String]
                let projLat = project?["latitude"]
                let projLon = project?["longitude"]
 
                let userLat = self.locationManager?.location?.coordinate.latitude
                let userLon = self.locationManager?.location?.coordinate.longitude
                print("MYLAT--- \(userLat!)")
                print("MYLON--- \(userLon!)")
                
                if projLat != nil
                {
                    //print("FFDDSFDSFSFSFs")
                    let pi = Double.pi
                    let projLatd = Double(projLat!)!
                    print("LAT1--- \(projLatd)")
                    let projLond = Double(projLon!)!
                    print("LON1--- \(projLond)")
                    //print(latd*pi/180)
                    let left = sin(projLatd*pi/180) * sin(userLat!*pi/180)
                    let right = cos(projLatd*pi/180) * cos(userLat!*pi/180) * cos((projLond*pi/180)-(userLon!*pi/180))
                    let leftright = left + right
                    let dist = acos(leftright) * 3959
                    print("DIST")
                    print(dist)
                    
                    //let dis = acos((sin(latd*(pi/180)) * sin(mylat*(pi/180)))+(cos(latd*(pi/180))*cos(mylat*(pi/180))*cos((lond*(pi/180))-(mylon*(pi/180)))))*3959
                   // print("DISTANCE \(dis)")
                    
                   if (dist <= self.distanceToTraveRadius)
                   {
                        print("INSIDE-----------------")
                        let cord = CLLocationCoordinate2DMake(projLatd, projLond)
                        let point = MKPointAnnotation()
                        point.title = project?["title"]
                        point.coordinate = cord
                        self.mapView.addAnnotation(point)
                    }
                }
            }
            
        })
        
        print("DONE RETRIVE POSTING")
    }
    
    
    func centerMapOnUserLocation()
    {
        print("CENTER MAP ON USER LOCATION")
        guard let coordinate = locationManager?.location?.coordinate else{return}
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinate, 6701,6701), animated: false)
    }
    
    //Depending on Location Authorization Status it will enable or disable the Location Service View
    func showLocationAvailabilityView(isViewHidden : Bool)
    {
        print("SHOW LOCATION IS UN AVAILABLE VIEW")
        locationServiceIsUnAvailableView.isHidden = isViewHidden
    }
    
    func setUpMap()
    {
        print("SETUPMAP")
        showLocationAvailabilityView(isViewHidden: true)
        mapView.showsUserLocation = true
        retrivePostingFromDatabase()
    }
    
    
}


extension MapsViewController: MKMapViewDelegate
{
    //It is called when annotation is added
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "homepin.png")
        annotationView!.image = pinImage
        annotationView!.canShowCallout = true
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view.annotation?.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("CALL CENTER MAP ON USER LOCATION - WHEN USER LOCATION UPDATES")
        centerMapOnUserLocation()
    }
}


extension MapsViewController: CLLocationManagerDelegate
{
    //Called when the locationManager object is created
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("IN - DID CHANGE AUTHORIZATION")
        switch status {
        case .notDetermined:
            print("NOT DETERMINED")
            locationManager?.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            print("AUTHORIZED WHEN IN USE")
            setUpMap()
        case .authorizedAlways:
            print("AUTHORIZED ALWAYS")
            setUpMap()
            break
        case .restricted:
            print("RESTRICTED")
            // restricted by e.g. parental controls. User can't enable Location Services
            // call function which will display disable map screen and ask user to enable
            showLocationAvailabilityView(isViewHidden: false)
            break
        case .denied:
            print("DENIED")
            // user denied your app access to Location Services, but can grant access from Settings.app
            // call function which will display disable map screen and ask user to enable
            showLocationAvailabilityView(isViewHidden: false)
            break
        }
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("IN - DID UPDATE LOCAION")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("IN - DID FAIL WITH ERROR")
        print("START ERROR MESSAGE \(error.localizedDescription)")
        print("END ERROR MESSAGE")
    }
}








//////////////////////////////////////////////////////////////////////////////////////////////////////
////
////  MapsViewController.swift
////  cosc4355Project
////
////  Created by Timothy M Shepard on 10/16/17.
////  Copyright © 2017 cosc4355. All rights reserved.
////
//
//import UIKit
//import MapKit
//import CoreLocation
//
//class MapsViewController: UIViewController, CLLocationManagerDelegate{
//
//    @IBOutlet weak var map: MKMapView!
//
//    let manager = CLLocationManager()
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations[0]
//        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
//
//        //set your debug location to : 29.716887, -95.338975  (HBS building)
//        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//
//        let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
//
//        map.setRegion(region, animated: true)
//
//        //print(location.coordinate)
//
//        let annotationLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(29.721543, -95.343632)
//
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = annotationLocation
//        annotation.title = "PGH"
//        annotation.subtitle = "Bad plumbing."
//
//        map.addAnnotation(annotation)
//
//        self.map.showsUserLocation = true
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyKilometer
//        manager.requestWhenInUseAuthorization()
//        manager.startUpdatingLocation()
//
//          }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
/////
//////////////////////////////////////////////////////////////////////////////////////////////////////

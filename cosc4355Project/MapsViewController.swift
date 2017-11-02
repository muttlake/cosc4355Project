//  MapsViewController.swift
//  cosc4355Project
//  Qaem Parasla


import UIKit
import FirebaseDatabase
import Firebase
import MapKit
import CoreLocation
import CoreFoundation


private class CustomAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var image: String?
    var posting_id: String?
    var projPhoto: UIImage?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.image = nil
        self.posting_id = nil
    }
}


class MapsViewController: UIViewController{
    
    var locationManager : CLLocationManager?
    var postingReference : FIRDatabaseReference?
    var maxTravelDistanceInRadius : Double = 0.0
    var isContractor = false
    var userPic: UIImage?
    var user: User?
    var customImage1 : CustomImageView?
    var projPhoto : UIImage?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationServiceDidFailNotificationView: UIView!
    
    @IBOutlet weak var enableLocationServicesButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            print("INSIDE ________'")
            guard let userInfo = FIRDataSnapshot.value as? [String : Any] else { return }
            if (userInfo["userType"] as! String == "Contractor") {
                self.isContractor = true
            }
            self.setImage(url: userInfo["profilePicture"] as! String, type: "")
        })
        
        //Default to hidden because we dont want the view to show if authorization is slow.
        locationServiceDidFailNotificationView.isHidden = true
        maxTravelDistanceInRadius = 50 //in miles
        postingReference = FIRDatabase.database().reference().child("projects")//get ref to atribute posting
        locationManager?.delegate = self
        mapView.delegate = self
    }
    
    func setImage(url : String, type: String)
    {
        let url = NSURL(string: url)
        var image = UIImage()
        
        URLSession.shared.dataTask(with: url as! URL, completionHandler: {(data, response, error) in
            if error != nil
            {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: {
                //print("INSERE WHER ______")
                if type == "project"
                {
                    //print("SET PROJECT PHOTO")
                    self.projPhoto = UIImage(data: data!)!
                    
                }
                else
                {
                    //print("SET USER PIC")
                    self.userPic = UIImage(data: data!)!
                }
                
            })
            
        }).resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "mapTobidSeque" )
        {
            print("-----INSIDE PREPARE SEGUE MATCHED")
            
            var postingDetails = sender as? [String: Any]
            let dvc = segue.destination as! BidFormViewController
            dvc.projectImagePhoto = projPhoto
            dvc.posterImagePhoto = userPic
            dvc.projectTitleString = postingDetails?["title"] as? String
            dvc.projectDescriptionString = postingDetails?["description"] as? String
            dvc.postingId = postingDetails?["posting_id"] as? String
            dvc.userWhoPostedId = postingDetails?["user_id"] as? String
            
            //Disable textbox/button if user is client
            if isContractor == false
            {
                //dvc.makeBidButton.isEnabled = true
                //dvc.bidAmountField.isEnabled = false
            }
        }
    }
    
    
    //This is one time event which grabs all projects from the database. It creats annotation and db observer if the following conditions are met:
    //The given project is <= to max distance the contractor wants to travel
    func retrivePostingFromDatabase()
    {
        //var postingReference : FIRDatabaseReference?
        //postingReference = FIRDatabase.database().reference().child("projects")//get ref to atribute posting
        
        
        
        let userLat = self.locationManager?.location?.coordinate.latitude
        let userLon = self.locationManager?.location?.coordinate.longitude
        
        //test for region
        let region = CLCircularRegion(center: CLLocationCoordinate2DMake(userLat!, userLon!), radius: 5, identifier: "geofence")
        
        locationManager?.startMonitoring(for: region)
        
        //let circle = MKCircle(center: CLLocationCoordinate2DMake(userLat!, userLon!), radius: region.radius)
        //mapView.add(circle)
        
        print(locationManager?.monitoredRegions)
        
        //end test region
        
        postingReference?.observeSingleEvent(of: .value, with: { (snapshot) in
            for projects in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                
                let project = projects.value as? [String: String]
                
                if let projLat = project?["latitude"], let projLon = project?["longitude"], let status = project?["status"]
                {
                    if status == "pending"
                    {
                        //calculate the distances between users and projects location
                        let pi = Double.pi
                        let projLatd = Double(projLat)!
                        //print("LAT1--- \(projLatd)")
                        let projLond = Double(projLon)!
                        //print("LON1--- \(projLond)")
                        //print(latd*pi/180)
                        let left = sin(projLatd*pi/180) * sin(userLat!*pi/180)
                        let right = cos(projLatd*pi/180) * cos(userLat!*pi/180) * cos((projLond*pi/180)-(userLon!*pi/180))
                        let leftright = left + right
                        let dist = acos(leftright) * 3959
                        //print("DIST")
                        //print(dist)
                        
                        if (dist <= self.maxTravelDistanceInRadius)
                        {
                            let point = CustomAnnotation()
                            
                            //test
                            //point.projPhoto = self.retriveImage(url: (project?["photoUrl"])!)
                            //print("retriveing priject")
                            //print(point.projPhoto)
                            self.setImage(url: (project?["photoUrl"])!, type: "project")
                            //test
                            
                            let projectCord = CLLocationCoordinate2DMake(projLatd, projLond)
                            point.title = project?["title"]
                            point.posting_id = project?["posting_id"]
                            point.coordinate = projectCord
                            point.image = "homepin.png"
                            
                            self.mapView.addAnnotation(point)
                            self.setChangeObservation(posting_id: (project?["posting_id"])!, annotation: point )
                        }
                    }
                }
            }
        })
        
        print("DONE RETRIVE POSTING")
    }
    
    
    
    //Check for new project on the project database(does not work on locality)
    func monitorNewProjects()
    {
        let childRef = FIRDatabase.database().reference().child("projects").observe(.childAdded, with: { (snapshot) in
            for projects in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                //                  postingDetails[projects.key] = projects.value!
            }
        })
    }
    
    //Obserbe any changes to nearby projects
    func setChangeObservation(posting_id: String, annotation: MKAnnotation)
    {
        print("SET CHANGE OBSERVATION FUNTION")
        print(posting_id)
        postingReference?.child(posting_id).observe(.childChanged, with: {(snapshot) in
            //process the change
            //it was changed (pending to complete) ()
            print("THIS IS SNAPSHOT \(snapshot)")
            
            if snapshot.key == "status"
            {
                let status = String(describing: snapshot.value!)
                
                switch status{
                case "complete":
                    //remove annotation
                    print("REMOVED ANNOTATION")
                    self.mapView.removeAnnotation(annotation)
                    break
                case "pending":
                    //add the annotation
                    print("ADDED ANNOTATION")
                    self.mapView.addAnnotation(annotation)
                    break
                default:
                    break
                }
            }
        })
    }
    
    func centerMapOnUserLocation()
    {
        print("CENTER MAP ON USER LOCATION")
        guard let coordinate = locationManager?.location?.coordinate else{return}
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinate, 6701,6701), animated: false)
    }
    
    //Depending on Location Authorization Status it will enable or disable the Location Service View
    func locationAvailabilityMessageView(isHidden : Bool)
    {
        print("SHOW LOCATION IS UN AVAILABLE VIEW")
        locationServiceDidFailNotificationView.isHidden = isHidden
    }
    
    func setUpMap()
    {
        print("SETUPMAP")
        mapView.showsUserLocation = true
        retrivePostingFromDatabase()
        //monitorNewProjects()
    }
    
    
    
    //Sends user to app setting where they can the app allow location access
    @IBAction func enableLocationServicesButton(_ sender: UIButton) {
        
        UIApplication.shared.open(URL(string:"App-Prefs:root=Privacy")!, options: [:], completionHandler: nil)
    }
    
}


extension MapsViewController: MKMapViewDelegate
{
    //It is called when annotation is added
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        //Return if Annotation is not of type CustomAnnotation
        if !(annotation is CustomAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        //Annotation does not exsist yet
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            let customPointAnnotation = annotation as! CustomAnnotation
            annotationView?.image = UIImage(named: customPointAnnotation.image!)
        }
            //Annotation exsist
        else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            if !(view.annotation is CustomAnnotation)
            {
                print("-----NOT CUSTOM ANNOTATION")
                //return nil
            }
            
            let customPointAnnotation = view.annotation as! CustomAnnotation
            var postingDetails = [String: Any]()
            
            let childRef = FIRDatabase.database().reference().child("projects").child(customPointAnnotation.posting_id!)
            
            childRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                for projects in snapshot.children.allObjects as! [FIRDataSnapshot]
                {
                    postingDetails[projects.key] = projects.value!
                }
                //self.projPhoto = customPointAnnotation.projPhoto
                //print("CLOCKEdd")
                //print(self.projPhoto)
                self.setImage(url: postingDetails["photoUrl"] as! String, type: "project")
                
                self.performSegue(withIdentifier: "mapTobidSeque", sender: postingDetails)
                
            })
            
        }
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
        case .authorizedWhenInUse, .authorizedAlways:
            print("AUTHORIZED WHEN IN USE")
            print(" OR AUTHORIZED ALWAYS")
            locationAvailabilityMessageView(isHidden: true)
            setUpMap()
        case .restricted, .denied:
            print("RESTRICTED")
            // restricted by e.g. parental controls. User can't enable Location Services
            // call function which will display disable map screen and ask user to enable
            print("OR DENIED")
            // user denied your app access to Location Services, but can grant access from Settings.app
            // call function which will display disable map screen and ask user to enable
            locationAvailabilityMessageView(isHidden: false)
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("DID EXIT REGION__________")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DID ENTER REGION ___________")
    }
    
    
    //This is called when location manager is set to start updating location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("IN - DID UPDATE LOCAION")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("IN - DID FAIL WITH ERROR")
        print(error.localizedDescription)
        locationAvailabilityMessageView(isHidden: false)
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

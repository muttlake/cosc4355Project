//  MapsViewController.swift
//  cosc4355Project
//  Qaem Parasla

import UIKit
import FirebaseDatabase
import Firebase
import MapKit
import CoreLocation


class CustomAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var posting_id: String?
    var annotationImage: String?
    var projPhoto: UIImage?
    var posterPic: UIImage?
    var postingDetails : [String : String]
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.posting_id = nil
        self.annotationImage = nil
        self.postingDetails = [:]
    }
}


//MapSettingViewController calls this when save button is pressed
protocol MapSettingProtocol: class {
    func updateMaxTravelDistanceIn(miles: Double)
}


/*
 class CustomAnnotationView: MKPinAnnotationView {
 
 override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
 super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
 self.canShowCallout = false
 //print("INIT")
 //self.image = UIImage(named: "homepin.png")
 }
 
 required init?(coder aDecoder: NSCoder) {
 super.init(coder: aDecoder)
 self.canShowCallout = false
 //print("REQUIRED INIT")
 //self.image = UIImage(named: "homepin.png")
 }
 
 override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
 let hitView = super.hitTest(point, with: event)
 if (hitView != nil)
 {
 self.superview?.bringSubview(toFront: self)
 }
 return hitView
 }
 
 override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
 let rect = self.bounds;
 var isInside: Bool = rect.contains(point);
 if(!isInside)
 {
 for view in self.subviews
 {
 isInside = view.frame.contains(point);
 if isInside
 {
 break;
 }
 }
 }
 return isInside;
 }
 }*/


class MapsViewController: UIViewController, MapSettingProtocol{
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationServiceDidFailNotificationView: UIView!
    
    @IBOutlet weak var enableLocationServicesButton: UIButton!
    
    @IBOutlet weak var mapSettingButton: UIButton!
    
    @IBOutlet weak var mapSettingView: UIView!
    
    var locationManager : CLLocationManager?
    var postingReference : FIRDatabaseReference?
    var maxTravelDistanceInMiles : Double = 2.0
    var isContractor = false
    var inRadiusProjects : [CustomAnnotation] = []
    var outsideRadiusProjects : [CustomAnnotation] = []
    
    var mapSettingViewController = MapSettingViewController()
    weak var mapSetting: MapSettingProtocol?
    
    
    @IBAction func mapSettingButtonPressed(_ sender: UIButton) {
        mapSettingView.isHidden = false
    }
    
    //Called from MapSettingViewController
    func updateMaxTravelDistanceIn(miles: Double)
    {
        mapSettingView.isHidden = true
        
        guard let currentLocation = self.locationManager?.location
            else{return}
        
        print(maxTravelDistanceInMiles)
        print(miles)
        
        if(maxTravelDistanceInMiles == miles)
        {}
        else if(maxTravelDistanceInMiles < miles)
        {
            print("inside <")
            for reg in (locationManager?.monitoredRegions)!
            {
                print("removed <")
                locationManager?.stopMonitoring(for: reg)
            }
            maxTravelDistanceInMiles = miles
            createGeoRegion()
            processOutsideRadiusAnnotation(currentLocation: currentLocation)
        }
        else if(maxTravelDistanceInMiles > miles)
        {
            for reg in (locationManager?.monitoredRegions)!
            {
                print("removed > ")
                locationManager?.stopMonitoring(for: reg)
            }
            print(locationManager?.monitoredRegions.count)
            print("inside >")
            maxTravelDistanceInMiles = miles
            createGeoRegion()
            processInRadiusAnnotation(currentLocation: currentLocation)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()// This function will call didChangeAuthorization aync
        locationManager?.delegate = self
        mapView.delegate = self
    }
    
    
    
    func setUpMap()
    {
        //maxTravelDistanceInMiles = 50.0
        postingReference = FIRDatabase.database().reference().child("projects")
        createGeoRegion()
        retrivePostingFromDatabase()
    }
    
    
    func getImage(url : String, completion: @escaping (Data) -> ())
    {
        let url = NSURL(string: url)
        
        URLSession.shared.dataTask(with: url as! URL, completionHandler: {(data, response, error) in
            completion(data!)
        }).resume()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {

        if (segue.identifier == "mapToContainer" )
        {
            print("-----INSIDE PREPARE SEGUE MATCHED")
            
            let dvc = segue.destination as! MapSettingViewController
            //dvc.setSliderValue(value: Float(maxTravelDistanceInMiles))
            dvc.delegate = self
            
        }
        
        if (segue.identifier == "mapTobidSegue" )
        {
            //print("-----INSIDE PREPARE SEGUE MATCHED")
            
            let customAnnotation = sender as! CustomAnnotation
            
            let dvc = segue.destination as! BidFormViewController
            dvc.projectImagePhoto = customAnnotation.projPhoto
            dvc.posterImagePhoto = customAnnotation.posterPic
            dvc.projectTitleString = customAnnotation.title
            dvc.projectDescriptionString = customAnnotation.postingDetails["description"]
            dvc.postingId = customAnnotation.postingDetails["posting_id"]
            dvc.userWhoPostedId = customAnnotation.postingDetails["user_id"]
            
            //Disable textbox/button if user is client
            if isContractor == false
            {
                //dvc.bidButtonIsHidden = true
                //dvc.bidTextFieldIsHidden = true
            }
        }
    }
    
    
    //This is one time event which grabs all projects from the database. It creats annotation and db observer if the following conditions are met:
    //The given project is <= to max distance the contractor wants to travel
    func retrivePostingFromDatabase()
    {
        
        guard let currentLocation = self.locationManager?.location
            else{return}
        
        //Go thru all projects in the database(Not using geofire)
        postingReference?.observeSingleEvent(of: .value, with: { (snapshot) in
            for projectSnap in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                let project = projectSnap.value as? [String: String]
                
                if let lat = project?["latitude"], let lon = project?["longitude"], let status = project?["status"]
                {
                    if status == "pending"
                    {
                        let projectlocation = CLLocation.init(latitude: Double(lat)!,
                                                              longitude: Double(lon)!)
                        let dist = (currentLocation.distance(from: projectlocation))/1609.34
                        //print(dist)
                        
                        let projectAnnotation = CustomAnnotation()
                        projectAnnotation.title = project?["title"]
                        projectAnnotation.posting_id = project?["posting_id"]
                        projectAnnotation.coordinate = projectlocation.coordinate
                        projectAnnotation.annotationImage = "homepin.png"
                        
                        if (dist <= self.maxTravelDistanceInMiles)
                        {
                            self.inRadiusProjects.append(projectAnnotation)
                            self.mapView.addAnnotation(projectAnnotation)
                            self.setChangeObservation(posting_id: (project?["posting_id"])!, annotation: projectAnnotation)
                        }
                        else
                        {
                            self.outsideRadiusProjects.append(projectAnnotation)
                        }
                    }
                }
            }})
        
        print("DONE RETRIVE POSTING")
    }
    
    
    //Check for new project on the project database(does not work on locality)
    func monitorNewProjects()
    {
        //When new project is found
        //
    }
    
    
    //Obserbe any changes to nearby projects
    func setChangeObservation(posting_id: String, annotation: MKAnnotation)
    {
        //print("SET CHANGE OBSERVATION FUNTION")
        //print(posting_id)
        postingReference?.child(posting_id).observe(.childChanged, with: {(snapshot) in
            //process the change
            //it was changed (pending to complete) ()
            //print("THIS IS SNAPSHOT \(snapshot)")
            
            if snapshot.key == "status"
            {
                let status = String(describing: snapshot.value!)
                
                switch status{
                case "complete":
                    //remove annotation
                    //print("REMOVED ANNOTATION")
                    self.mapView.removeAnnotation(annotation)
                    break
                case "pending":
                    //add the annotation
                    //print("ADDED ANNOTATION")
                    self.mapView.addAnnotation(annotation)
                    break
                default:
                    break
                }
            }
        })
    }
    
    
    func createGeoRegion()
    {
        print("CREATING REGION")
        print(maxTravelDistanceInMiles)
        let userLat = self.locationManager?.location?.coordinate.latitude
        let userLon = self.locationManager?.location?.coordinate.longitude
        let coordinate = CLLocationCoordinate2DMake(userLat!, userLon!)
        let region = CLCircularRegion(center: coordinate, radius: Double(maxTravelDistanceInMiles)*1609.34, identifier: "geofence")
        mapView.removeOverlays(mapView.overlays)
        region.notifyOnExit = true
        region.notifyOnEntry = false
        locationManager?.startMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: Double(maxTravelDistanceInMiles)*1609.34)
        mapView.add(circle)
    }
    
    
    func centerMapOnUserLocation()
    {
        //print("CENTER MAP ON USER LOCATION")
        guard let coordinate = locationManager?.location?.coordinate else{return}
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinate, 9701,9701), animated: false)
    }
    
    
    func getUserType()
    {
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            
            guard let userInfo = FIRDataSnapshot.value as? [String : String] else { return }
            
            if (userInfo["userType"] == "Contractor")
            {
                self.isContractor = true
            }
            else
            {
                self.isContractor = false
            }
        })
    }//End getUserType
    
    
    func getProjectPosterProfileImage(poster: String, completion: @escaping (Data) -> ())
    {
        FIRDatabase.database().reference().child("users").child(poster).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            guard let userInfo = FIRDataSnapshot.value as? [String : String] else { return }
            
            self.getImage(url: userInfo["profilePicture"]!, completion: { (data) in
                completion(data)
            })
        })
    }//End getUserType
    
    
    //Depending on Location Authorization Status it will enable or disable the Location Service View
    func isLocationServiceAuthorized(isAuthorized: Bool)
    {
        //print("SHOW LOCATION IS UN AVAILABLE VIEW")
        locationServiceDidFailNotificationView.isHidden = isAuthorized
    }
    
    
    //Sends user to app setting where they can the app allow location access
    @IBAction func enableLocationServicesButton(_ sender: UIButton) {
        
        UIApplication.shared.open(URL(string:"App-Prefs:root=Privacy")!, options: [:], completionHandler: nil)
    }
    
    @objc func preProcessForSegue(annotation : MKAnnotation)
    {
        
        let dispatchGroup = DispatchGroup()
        let customAnnotation = annotation as! CustomAnnotation
        var postingDetails = [String: Any]()
        
        let childRef = FIRDatabase.database().reference().child("projects").child(customAnnotation.posting_id!)
        
        childRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for projectSnap in snapshot.children.allObjects as! [FIRDataSnapshot]
            {
                postingDetails[projectSnap.key] = projectSnap.value!
            }
            
            customAnnotation.postingDetails = postingDetails as! [String : String]
            
            dispatchGroup.enter()
            self.getImage(url: postingDetails["photoUrl"] as! String, completion: { (data) in
                customAnnotation.projPhoto = UIImage(data : data)
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            self.getProjectPosterProfileImage(poster: postingDetails["user_id"] as! String, completion: { (data) in
                customAnnotation.posterPic = UIImage(data : data)
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .main, execute: {
                self.performSegue(withIdentifier: "mapTobidSegue", sender: customAnnotation)
            })
            
        })
        
    }
    
    func processInRadiusAnnotation(currentLocation : CLLocation)
    {
        var track = 0
        
        //Process the active projects if they fall outside new radius
        for annotationInRadius in inRadiusProjects
        {
            let projectlocation = CLLocation.init(latitude: annotationInRadius.coordinate.latitude,
                                                  longitude: annotationInRadius.coordinate.longitude)
            
            let dist = (currentLocation.distance(from: projectlocation))/1609.34
            //print(dist)
            
            if (dist > Double(maxTravelDistanceInMiles))
            {
                inRadiusProjects.remove(at: track)
                outsideRadiusProjects.append(annotationInRadius)
                mapView.removeAnnotation(annotationInRadius)
                track -= 1
            }
            track += 1
        }
    }
    
    
    func processOutsideRadiusAnnotation(currentLocation : CLLocation)
    {
        var track = 0
        //Process the inactive projects if they belong to new radius
        for annotationOutside in outsideRadiusProjects
        {
            let projectlocation = CLLocation.init(latitude: annotationOutside.coordinate.latitude,
                                                  longitude: annotationOutside.coordinate.longitude)
            
            let dist = (currentLocation.distance(from: projectlocation))/1609.34
            //print(dist)
            
            if (dist <= Double(maxTravelDistanceInMiles))
            {
                inRadiusProjects.append(annotationOutside)
                outsideRadiusProjects.remove(at: track)
                mapView.addAnnotation(annotationOutside)
                track -= 1
            }
            
            track += 1
        }
    }
}


extension MapsViewController: MKMapViewDelegate
{
    
    //Just for test .. Remove later
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .red
        circleRenderer.fillColor = .red
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
    
    
    /*
     func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
     if view.annotation is MKUserLocation
     {
     return
     }
     
     let customAnnotation = view.annotation as! CustomAnnotation
     let views = Bundle.main.loadNibNamed("calloutView", owner: nil, options: nil)
     let calloutView = views?[0] as! calloutView
     calloutView.projectTitle.text = customAnnotation.title
     calloutView.projectDescription.text = customAnnotation.posting_id
     let button = UIButton(frame: calloutView.projectDetailsView.frame)
     button.addTarget(self, action: #selector(preProcessForSegue(annotation: view.annotation!)), for: .touchUpInside)
     calloutView.addSubview(button)
     
     calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
     view.addSubview(calloutView)
     mapView.setCenter((view.annotation?.coordinate)!, animated: true)
     }
     
     
     func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
     if view.isKind(of: CustomAnnotationView.self)
     {
     for subview in view.subviews
     {
     subview.removeFromSuperview()
     }
     }
     }
     
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?  {
     
     //Return if Annotation is not of type CustomAnnotation
     if !(annotation is CustomAnnotation) {
     return nil
     }
     
     let annotationIdentifier = "AnnotationIdentifier"
     var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
     
     //Annotation does not exsist yet
     if annotationView == nil {
     annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
     //annotationView!.canShowCallout = false
     let customPointAnnotation = annotation as! CustomAnnotation
     annotationView?.image = UIImage(named: customPointAnnotation.annotationImage!)
     }
     //Annotation exsist
     else
     {
     annotationView!.annotation = annotation
     }
     
     return annotationView
     
     }*/
    
    
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
            annotationView?.image = UIImage(named: customPointAnnotation.annotationImage!)
        }
            //Annotation exsist
        else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    
    //using custom annotation so no need DELETE
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            if !(view.annotation is CustomAnnotation)
            {
                //print("-----NOT CUSTOM ANNOTATION---")
                //return nil
            }
            

            preProcessForSegue(annotation : view.annotation!)

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
                
                self.performSegue(withIdentifier: "mapTobidSegue", sender: postingDetails)
                
            })
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //print("CALL CENTER MAP ON USER LOCATION - WHEN USER LOCATION UPDATES")
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
            //print("NOT DETERMINED")
            //locationManager?.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            //print("AUTHORIZED WHEN IN USE")
            //print(" OR AUTHORIZED ALWAYS")
            //locationAvailabilityMessageView(isHidden: true)
            //setUpMap()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()
            mapView.showsUserLocation = true
            setUpMap()
            isLocationServiceAuthorized(isAuthorized: true)
            break
        case .restricted, .denied:
            //print("RESTRICTED")
            // restricted by e.g. parental controls. User can't enable Location Services
            // call function which will display disable map screen and ask user to enable
            //print("OR DENIED")
            // user denied your app access to Location Services, but can grant access from Settings.app
            // call function which will display disable map screen and ask user to enable
            isLocationServiceAuthorized(isAuthorized: false)
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("DID EXIT REGION__________")
        if region.identifier == "geofence"
        {
            locationManager?.stopMonitoring(for: region)
            
            guard let currentLocation = self.locationManager?.location
                else{return}
            
            createGeoRegion()
            
            processInRadiusAnnotation(currentLocation: currentLocation)
            processOutsideRadiusAnnotation(currentLocation: currentLocation)
            
        }
    }
    
    
    //NO USE YET SO DELETE
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DID ENTER REGION ___________")
    }
    
    
    //This is called when location manager is set to start updating location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("IN - DID UPDATE LOCAION")
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("IN - DID FAIL WITH ERROR")
        print(error.localizedDescription)
        isLocationServiceAuthorized(isAuthorized: false)
        //print("END ERROR MESSAGE")
    }
}

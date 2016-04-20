//
//  MapViewController.swift
//  OnTheMap
//
//  Created by iMac on 2016-02-26.
//  Copyright © 2016 iMac. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let parse = ParseClient()
    
    let uda = UdacityClient()
   
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var locationz = StudentInformationCollection.sharedInstance.locationz
    var locationStructs = StudentInformationCollection.sharedInstance.locationStructs
    
    var students = Students.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.navigationController?.navigationBarHidden = true
        getStudentLocations()
        
    }
    
    
    
    @IBAction func reload(sender: AnyObject) {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        self.loadPins()
    }
    
    func loadPins(){
        
        let locations = self.students.students
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        
        for student in locations {
            
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastname
            let mediaURL = student.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
        }
        
        // When the array is complete, we add the annotations to the map.
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.addAnnotations(annotations)
        }
        // self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        uda.deleteSession()
       
        appDelegate.firstName = nil
        appDelegate.lastName = nil
        appDelegate.sessionID = nil
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func getStudentLocations(){
        
        parse.accessParse(self, parameters: ["limit": 100, "order" : "-updatedAt"]) { (data, error) -> Void in
            
            guard error.code == 0 else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.alert("download failed")
                    
                }
                return
            }
            
            self.locationz = (data["results"] as? [[String:AnyObject]])!
            self.parseStudentLocations()
            self.loadPins()
            
        }
        
    }
    
    func parseStudentLocations(){
        
        for location in self.locationz{
            
            let student = StudentInformation(studentDictionary: location)
            
            self.students.students.append(student)
            
        }
    }
    
    /*
    func alert(message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }*/
}

//
//  MapPinController.swift
//  OnTheMap
//
//  Created by iMac on 2016-03-02.
//  Copyright © 2016 iMac. All rights reserved.
//

import UIKit
import MapKit

class MapPinController: UIViewController, UITextViewDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var textArea: UITextView!
    var annotations : [MKPointAnnotation]!
    var l1 : Double!
    var l2 : Double!
    var region :  MKCoordinateRegion!
    var coordinates : CLLocationCoordinate2D!
    @IBOutlet weak var mapView: MKMapView!
    var appDelegate : AppDelegate!
    
    let parse = ParseClient()
    var locationString : String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.navigationController?.navigationBarHidden = true
        self.loadPins()
        self.textArea.delegate = self
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textArea.text = ""
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {}
    }
    
    @IBAction func submit(sender: AnyObject) {
        guard textArea.text != "" else{
            return
        }
        
        if Reachability.isConnectedToNetwork() == false {
            self.alert("Not connected to network.")
            return
        }
        
        parse.createPostRequest(["":""], firstName: self.appDelegate.firstName!, lastName: self.appDelegate.lastName!, mapString: locationString, mediaURL: textArea.text, latitude: l1!, longitude: l2!) { (data, error) -> Void in
            
            
            
            dispatch_async(dispatch_get_main_queue()) {
                guard error.code == 0 else {
                    self.alert(error.localizedDescription)
                    return
                }
                
                let vc = self.navigationController?.viewControllers[1]
                
                self.navigationController?.popToViewController(vc!, animated: true)
                
            }
        }
    }
    
    func loadPins(){
        
        self.mapView.setRegion(self.region, animated: true)
        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinates
        
        // Finally we place the annotation in an array of annotations.
        self.annotations!.append(annotation)
        
        // When the array is complete, we add the annotations to the map.
        
        self.mapView.addAnnotations(self.annotations)
        
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
    
    
}
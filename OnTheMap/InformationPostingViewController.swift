//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by iMac on 2016-02-26.
//  Copyright © 2016 iMac. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController : UIViewController, UITextViewDelegate{
    
    @IBOutlet weak var locationTextArea: UITextView!
    @IBOutlet weak var textArea: UITextView!
    var coordinates : CLLocationCoordinate2D?
    var annotations : [MKPointAnnotation]?
    var l1 : Double?
    var l2 : Double?
    var region :  MKCoordinateRegion?
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        textArea.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.textArea.delegate = self
       
        
    }
    
    

    
    
    
    @IBAction func goToMapPinView(sender: AnyObject) {
        
        performSegueWithIdentifier("MapPinView", sender: self)
        
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        textArea.text = ""
    }
    
    
    
    @IBAction func loadPins(sender: AnyObject){
        
       
        let geocoder = CLGeocoder()
        
        
        geocoder.geocodeAddressString(textArea.text!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                self.alert("Address not found")
                return
            }
            
            if let placemark = placemarks?.first {
                
                dispatch_async(dispatch_get_main_queue()) {
                self.coordinates = placemark.location!.coordinate
                
                self.annotations = [MKPointAnnotation]()
                
                
                self.l1 = self.coordinates!.latitude
                self.l2 = self.coordinates!.longitude
                
                
                self.region = MKCoordinateRegion(center: self.coordinates!, span: MKCoordinateSpan(latitudeDelta: 0.75, longitudeDelta: 0.75))
                  
                     dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("MapPinView", sender: self)
                    }
                }
                
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MapPinView" {
            
            let vc = segue.destinationViewController as! MapPinController
            vc.locationString = textArea.text
            vc.annotations = self.annotations
            vc.l1 = self.l1
            vc.l2 = self.l2
            vc.region = self.region
            vc.coordinates = self.coordinates
        }
    }
    
}

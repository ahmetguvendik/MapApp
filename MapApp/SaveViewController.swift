//
//  SaveViewController.swift
//  MapApp
//
//  Created by Ahmet GÜVENDİK on 7.03.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class SaveViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var mapVıew: MKMapView!
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    let locationManager = CLLocationManager()
    var annatationTitle = ""
    var annatationSubtitle = ""
    var annatationLatitude = Double()
    var annatationLongitude = Double()
    
    var selectedName = ""
    var selectedId : UUID?
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Map", into: context)
        
        entity.setValue(cityTextField.text, forKey: "name")
        entity.setValue(noteTextField.text, forKey: "note")
        entity.setValue(UUID(), forKey: "id")
        entity.setValue(selectedLatitude, forKey: "latitude")
        entity.setValue(selectedLongitude, forKey: "longitude")
        
        do{
            try context.save()
            print("Basarili")
        }catch{
            print("Error")
        }
        
    }
    
    func getData (){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Map") //Entity tanimlamasi
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "id=%@", selectedId!.uuidString) //Filtreleme islemleri icin
            
            do{
                let datas = try context.fetch(fetchRequest)
                
                if datas.count > 0 {
                    for data in datas as! [NSManagedObject]{
                        if let name = data.value(forKey: "name") as? String{
                            annatationTitle = name
                            
                            if let stock = data.value(forKey: "note") as? String{
                                annatationSubtitle = String(stock)
                                
                                
                                if let latitude = data.value(forKey: "latitude") as? Double{
                                    annatationLatitude  = latitude
                                    
                                    
                                    if let longitude = data.value(forKey: "longitude") as? Double{
                                        annatationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annatationTitle
                                        annotation.subtitle = annatationSubtitle
                                        let cordnate = CLLocationCoordinate2D(latitude: annatationLatitude, longitude: annatationLongitude)
                                        annotation.coordinate = cordnate
                                        
                                        mapVıew.addAnnotation(annotation)
                                        
                                        cityTextField.text = annatationTitle
                                        noteTextField.text = annatationSubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                                        let region = MKCoordinateRegion(center: cordnate, span: span)
                                        mapVıew.setRegion(region, animated: true)
                                        
                                    }
                                }
                            }
                        }
                        
        
                    }
                }
                
            } catch {
                print("HATA")
            }
        }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVıew.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //En iyi konumu yakalamak icin
        locationManager.requestWhenInUseAuthorization() //Izin Icin
        locationManager.startUpdatingLocation() //Konum guncelleme icin
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addPoint(gesturRecognizer:)))
        gesture.minimumPressDuration = 2
        mapVıew.addGestureRecognizer(gesture)
        
        if selectedName != ""{
           getData()
        }
            
    }
    
    @objc func addPoint(gesturRecognizer: UILongPressGestureRecognizer){
        if gesturRecognizer.state == .began {
            let point = gesturRecognizer.location(in: mapVıew)
            let cordinate = mapVıew.convert(point, toCoordinateFrom: mapVıew)
            selectedLatitude = cordinate.latitude
            selectedLongitude = cordinate.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = cordinate
            annotation.title = cityTextField.text
            annotation.subtitle = noteTextField.text
            mapVıew.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedName == ""{
 
            
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapVıew.setRegion(region, animated: true)
        }
        
    }
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId)
        
        if pinView == nil {
            
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            
            let button = UIButton(type: .detailDisclosure) //Detay gosterme butonu
            
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
            
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedName != ""{
            let location = CLLocation(latitude: annatationLatitude, longitude: annatationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(location) { placmark, error in
                
                if let placemarks = placmark {
                    if placemarks.count > 0 {
                        let newPlacmark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: newPlacmark)
                        item.name = self.annatationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            
            }
        }
    }
    
}


import UIKit
import MapKit

class ViewController: UIViewController , CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var destination: CLLocationCoordinate2D!

    @IBOutlet weak var map: MKMapView!
    
    // create a places array
    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.delegate = self
        
//        this line is equivalent to the user location check box in map view
//        map.showsUserLocation = true
        
        // we give the delegate of locationManager to this class
        locationManager.delegate = self
        
        // accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // request the user for the location access
        locationManager.requestWhenInUseAuthorization()
        
        // start updating the location of the user
        locationManager.startUpdatingLocation()
 
        // 1 - define latitude and longitude
        let latitude: CLLocationDegrees = 43.64
        let longitude: CLLocationDegrees = -79.38
        
//        displayLocation(latitude: latitude, longitude: longitude, title: "Toronto Downtown", subtitle: "beatiful city")
        
        // long press gesture
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addlongPressAnnotation))
        map.addGestureRecognizer(uilpgr)
        
        // add double tap
        addDoubleTap()
        
        // add annotation for the places
//        addPlaces()
        
        // add polyline method
//        addPolyline()
        
        // add polygon method
//        addPolygon()
        
    }
    
    //MARK: - places method
    /// add places function
    func addPlaces() {
        map.addAnnotations(places)
        
        let overlays = places.map { MKCircle(center: $0.coordinate, radius: 1000)}
        map.addOverlays(overlays)
    }
    
    //MARK: - polyline method
    func addPolyline() {
        let coordinates = places.map {$0.coordinate}
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
    }
    
    //MARK: - polygon method
    func addPolygon() {
        let coordinates = places.map {$0.coordinate}
        let polyline = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
    }
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addlongPressAnnotation(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        // add annotation
        let annotation = MKPointAnnotation()
        annotation.title = "My destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    }
    
    
    //MARK: - didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "Your Location", subtitle: "you are here")
        
        
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String) {
        // 2 - define delta latitude and delta longitude for the span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        // 3 - creating the span and location coordinate and finally the region
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 4 - set region for the map
        map.setRegion(region, animated: true)
        /*
        // add annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
 */
    }
    
    //MARK: - double tap func
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        map.removeOverlays(map.overlays)
        // add annotation
        
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = "My destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
    }
    
    func removePin() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
//        map.removeAnnotations(map.annotations)
    }
    
    // added zoom in and zoom out functionality
    @IBAction func zoomInZoomOut(_ sender: UIButton) {
        
        if(sender.tag==2){
            var region = map.region;         var span = MKCoordinateSpan();         span.latitudeDelta = region.span.latitudeDelta/2;         span.longitudeDelta = region.span.longitudeDelta/2;         region.span = span;         map.setRegion(region, animated: true);
        }else{
             var region = map.region;         var span = MKCoordinateSpan();         span.latitudeDelta = region.span.latitudeDelta*2;         span.longitudeDelta = region.span.longitudeDelta*2;         region.span = span;         map.setRegion(region, animated: true);
        }
        
    }
    
    @IBAction func drawDirection(_ sender: UIButton) {
        map.removeOverlays(map.overlays)
        
        // create the alert
                let alert = UIAlertController(title: "Alert", message: "Please select destination by double tapping on the screen.", preferredStyle: UIAlertController.Style.alert)
        
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
              
        
        let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        print("here")
        if(destination != nil)
        {
              
           let destinationPlaceMark = MKPlacemark(coordinate: destination)
                   
                   // request a direction
                   let directionRequest = MKDirections.Request()
                   
                   // define source and destination
                   directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
                   directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
                   
                   // transportation type
                   if(sender.tag==0){
                        directionRequest.transportType = .walking
                   }else{
                        directionRequest.transportType = .automobile
                   }
                  
                   
                   // calculate directions
                   let directions = MKDirections(request: directionRequest)
                   directions.calculate { (response, error) in
                       guard let directionResponse = response else {return}
                       // create route
                       let route = directionResponse.routes[0]
                       // draw the polyline
                       self.map.addOverlay(route.polyline, level: .aboveRoads)
                       
                       // defining the bounding map rect
                       let rect = route.polyline.boundingMapRect
           //            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
                       self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                   }
        }  else{
            self.present(alert, animated: true, completion: nil)
        }
        }
        
    
}

extension ViewController: MKMapViewDelegate {
    //MARK: - add viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        
        // add custom annotation with image
        let pinAnnotation = map.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
        pinAnnotation.image = UIImage(named: "ic_place_2x")
        pinAnnotation.canShowCallout = true
        pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinAnnotation
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Place", message: "Welcome", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - render for overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.purple
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}

//
//  DetailsMapViewRepresentable.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct DetailsMapViewRepresentable: UIViewRepresentable {
    @EnvironmentObject var locationSearchViewModel: LocationSearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = LocationServices.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    
    let mapView = MKMapView()
    
    @Binding var mapState: MapViewState
    @Binding var selectedFroop: Froop
    @Binding var selectedFroopUUID: String
    @Binding var froopMapOpen: Bool
    
    func calculateDistance(to location: Froop) -> Double {
        PrintControl.shared.printLocationServices("-DetailsMapViewRepresentable: Function: calculateDistance is firing!")
        guard let userLocation = locationManager.userLocation else { return 0 }
        let froopLocation = CLLocation(latitude: location.froopLocationCoordinate?.latitude ?? 0.0, longitude: location.froopLocationCoordinate?.longitude ?? 0.0)
        return userLocation.distance(from: froopLocation)
    }
    
    func makeUIView(context: Context) -> some UIView {
        PrintControl.shared.printLocationServices("-FroopMapViewRepresentable: Function: makeUIView is firing!")
        
        let froopDescription = froopManager.selectedFroop.description
        PrintControl.shared.printLocationServices(froopDescription)
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addAnnotationOnLongPress))
            mapView.addGestureRecognizer(longPressGesture)
        
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none

        if let froopLocation = froopManager.selectedFroop.froopLocationCoordinate {
            let region = MKCoordinateRegion(center: froopLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: false)
        }
        
        PrintControl.shared.printLocationServices("updating userLocation ELEVEN")
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        PrintControl.shared.printLocationServices("-DetailsMapViewRepresentable: Function: updateUIView is firing!")
        
        if let froopLocation = froopManager.selectedFroop.froopLocationCoordinate {
            let region = MKCoordinateRegion(center: froopLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
        }
        
        switch mapState {
            case .noInput:
                PrintControl.shared.printLocationServices("NO INPUT")
                context.coordinator.clearMapViewAndRecenterOnUserLocation()
                
                break
            case .searchingForLocation:
                PrintControl.shared.printLocationServices("SEARCHING FOR LOCATION")
                break
            case .locationSelected:
                PrintControl.shared.printLocationServices("LOCATION SELECTED")
                if let selectedCoordinate = froopManager.selectedFroop.froopLocationCoordinate {
                    print("Selected Coordinate: \(selectedCoordinate.latitude), \(selectedCoordinate.longitude)")
                    if CLLocationCoordinate2DIsValid(selectedCoordinate) {
                        PrintControl.shared.printLocationServices("DEBUG: Adding stuff to map..")
                        context.coordinator.addAndSelectAnnotation(withCoordinate: selectedCoordinate)
                        context.coordinator.configurePolyline(withDestinationCoordinate: selectedCoordinate)
                    } else {
                        print("Error: Selected coordinate is not valid.")
                    }
                } else {
                    print("Error: No selected coordinate available.")
                }
                break
            case .polylineAdded:
                PrintControl.shared.printMap("POLY LINE ADDED")
                break
            case .tripRequested:
                PrintControl.shared.printMap("TRIP REQUESTED")
                break
            case .tripAccepted:
                PrintControl.shared.printMap("TRIP ACCEPTED")
                break
            case .driverArrived:
                PrintControl.shared.printMap("DRIVER ARRIVED")
                break
            case .tripInProgress:
                PrintControl.shared.printMap("TRIP IN PROGRESS")
                break
            case .arrivedAtDestination:
                PrintControl.shared.printMap("ARRIVED AT DESTINATION")
                break
            case .tripCompleted:
                PrintControl.shared.printMap("TRIP COMPLETED")
                break
            case .tripCancelled:
                PrintControl.shared.printMap("TRIP CANCELLED")
                break
        }
    }
    
    func makeCoordinator() -> DetailsMapCoordinator {
        PrintControl.shared.printLocationServices("-DetailsMapViewRepresentable: Function: makeCoordinator is firing!")
        return DetailsMapCoordinator(parent: self, mapUpdateState: MapUpdateState(), froop: froopManager.selectedFroop, mapView: mapView)
    }
}

extension DetailsMapViewRepresentable {
    
    class DetailsMapCoordinator: NSObject, MKMapViewDelegate {
        @State var froop: Froop
        var mapView = MKMapView()
        @ObservedObject var locationManager = LocationManager.shared
        @ObservedObject var locationServices = LocationServices.shared // @Binding var mapState: MapViewState
        @ObservedObject var appStateManager = AppStateManager.shared
        @ObservedObject var printControl = PrintControl.shared
        @ObservedObject var froopDataListener = FroopDataListener.shared
        @Published var annotations: [MKAnnotation] = []

        @EnvironmentObject var locationViewModel: LocationSearchViewModel
        
        let annotationModel = AnnotationModel()
        var visualEffectView: UIVisualEffectView?
        var selectedAnnotationView: MKAnnotationView?

        // MARK: - Properties
        let mapUpdateState: MapUpdateState
        let parent: DetailsMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        //var froopLocation: CLLocationCoordinate2D?
        
        //print("updating userLocation FOURTEEN")
        // MARK: - Lifecycle
        
        
        init(parent: DetailsMapViewRepresentable, mapUpdateState: MapUpdateState, froop: Froop, mapView: MKMapView) {
            self.parent = parent
            self.mapUpdateState = mapUpdateState
            self.froop = froop
            self.mapView = mapView
            //            self.mapView = parent.mapView // set mapView to parent's mapView
            super.init()
        }
        
        // MARK: - MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            print("MapView ViewFor Function Called")
            if let froopDropPin = annotation as? FroopDropPin {
                let identifier = "FroopDropPin"
                
                // Reuse or create an MKPinAnnotationView
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: froopDropPin, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                } else {
                    annotationView?.annotation = froopDropPin
                }
                
                // Set the pin color
                annotationView?.markerTintColor = froopDropPin.color
                
                return annotationView
            }
            return nil
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if locationServices.trackActiveUserLocation == false {
                return
            }
            let newCoordinate = userLocation.coordinate
            guard let previousCoordinate = self.userLocationCoordinate else {
                // This is the first location update, so we don't have a previous location to compare with
                self.userLocationCoordinate = newCoordinate
                return
            }
            
            let distance = sqrt(pow(newCoordinate.latitude - previousCoordinate.latitude, 2) + pow(newCoordinate.longitude - previousCoordinate.longitude, 2))
            if distance < 0.00001 { // Adjust this threshold as needed
                                    // The location hasn't changed significantly, so we ignore this update
                return
            }
            
            // The location has changed significantly, so we process this update
            self.userLocationCoordinate = newCoordinate
            
            PrintControl.shared.printLocationServices("Previous Location: \(String(describing: previousCoordinate.latitude)), \(String(describing: previousCoordinate.longitude))")
            print("New Location: \(newCoordinate.latitude), \(newCoordinate.longitude)")
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            
            PrintControl.shared.printLocationServices("updating userLocation TOMMY")
            PrintControl.shared.printLocationServices(mapUpdateState.isFunctionEnabled.description)
            self.currentRegion = region
            
            parent.mapView.setRegion(region, animated: false)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            PrintControl.shared.printLocationServices("-DetailsMapViewRepresentable: Function: mapView2 is firing!")
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation as? MovableAnnotation {
                if control == view.rightCalloutAccessoryView {
                    // Handle the detail disclosure button being tapped
                    let alert = UIAlertController(title: "Edit Annotation", message: nil, preferredStyle: .alert)
                    alert.addTextField { textField in
                        textField.text = annotation.title
                    }
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        if let newTitle = alert.textFields?.first?.text {
                            annotation.title = newTitle
                        }
                    })
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.first?.rootViewController?.present(alert, animated: true)
                    }
                } else if control == view.leftCalloutAccessoryView {
                    // Handle the delete button being tapped
                    mapView.removeAnnotation(annotation as! MKAnnotation)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            selectedAnnotationView = view

            if view.annotation is FroopDropPin {
                appStateManager.isAnnotationMade = true
                appStateManager.isFroopTabUp = false
                appStateManager.isDarkStyle = false
                ActiveMapViewModel.shared.annotationModel.annotation = view.annotation as? FroopDropPin
            }
        }
        
        // MARK: - Helpers
        
        @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
            print("Long press detected!")

            if gesture.state == .began {
                print("Gesture state is .began")

                let point = gesture.location(in: mapView)
                let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                print("Coordinate: \(coordinate.latitude), \(coordinate.longitude)")
 
                // Fetch or define the creatorUID and profileImageUrl values
                let creatorUID = FirebaseServices.shared.uid
                let profileImageUrl = MyData.shared.profileImageUrl
                
                let annotation = FroopDropPin(coordinate: coordinate, title: "Title Here.", subtitle: "SubTitle Here", messageBody: "Message Here", color: UIColor.purple, creatorUID: creatorUID, profileImageUrl: profileImageUrl)
                
                mapView.addAnnotation(annotation)
                appStateManager.isAnnotationMade = true
                appStateManager.isFroopTabUp = false
                annotationModel.annotation = annotation
                
                annotations.append(annotation) // Add the new annotation to viewModel.annotations
            }
        }
        
        @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
            // Get the point that was tapped
            let point = gesture.location(in: mapView)
            
            // Convert that point to a coordinate
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // Define the map rect to search within
            let mapPoint = MKMapPoint(coordinate)
            let searchRect = MKMapRect(x: mapPoint.x, y: mapPoint.y, width: 1, height: 1)
            
            // Filter the map's annotations to find those within the search rect
            let tappedAnnotations = mapView.annotations.filter { annotation in
                searchRect.contains(MKMapPoint(annotation.coordinate))
            }
            
            // If no annotations were tapped
            if tappedAnnotations.isEmpty {
                // Deselect all currently selected annotations
                for annotation in mapView.selectedAnnotations {
                    mapView.deselectAnnotation(annotation, animated: true)
                }
            }
        }
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            PrintControl.shared.printLocationServices("-DetailsMapViewRepresentable: Function: addAndSelectAnnotation is firing!")
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            
            let anno = MKPointAnnotation()
            anno.coordinate = froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
            parent.mapView.addAnnotation(anno)
            parent.mapView.selectAnnotation(anno, animated: true)
        }
        
        func calculateDistance(to location: Froop) -> Double {
            PrintControl.shared.printLocationServices("-DetailsMapViewRepresentable: Function: calculateDistance is firing!")
            guard let userLocation = locationManager.userLocation else { return 0 }
            let froop = CLLocation(latitude: location.froopLocationCoordinate?.latitude ?? 0.0, longitude: location.froopLocationCoordinate?.longitude ?? 0.0)
            print("FROOP LOCATION")
            print(location.froopLocationCoordinate?.longitude ?? 0.0)
            print(location.froopLocationCoordinate?.latitude ?? 0.0)
            
            return userLocation.distance(from: froop)
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            PrintControl.shared.printMap("-FroopMapViewRepresentable: Function: configurePolyline is firing!")
            PrintControl.shared.printMap("DAVID - CONFIGURE POLY LINE STARTED")

            guard let userCoordinate = self.parent.mapView.userLocation.location?.coordinate else {
                print("Error: Unable to fetch userCoordinate.")
                return
            }
            print("User Coordinate: \(userCoordinate.latitude), \(userCoordinate.longitude)")
            print("Destination Coordinate: \(coordinate.latitude), \(coordinate.longitude)")

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            request.transportType = .automobile

            let directions = MKDirections(request: request)
            directions.calculate { [unowned self] response, error in
                if let error = error {
                    print("Error in directions.calculate: \(error.localizedDescription)")
                    return
                }
                guard let route = response?.routes.first else {
                    print("No route available.")
                    return
                }

                self.parent.mapView.addOverlay(route.polyline)
                self.parent.mapState = .polylineAdded

                let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect,
                                                               edgePadding: .init(top: 150, left: 50, bottom: 150, right: 50))
                print("Setting map region to cover polyline.")
                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        func clearMapViewAndRecenterOnUserLocation() {
            PrintControl.shared.printMap("DetailsMapViewRepresentable: Function: clearMapViewAndRecenterOnUserLocation is firing!")
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
            PrintControl.shared.printLocationServices("updating userLocation NINETEEN")
            if let currentRegion = currentRegion {
                parent.mapView.setRegion(currentRegion, animated: false)
            }
        }
    }
}


struct CustomAnnotation: Codable {
    let id: String
    let title: String
    let latitude: Double
    let longitude: Double
    let description: String
    let owner: String
    let ownerUid: String
    
    // Add any other properties you need
}

//
//  FroopMapViewRepresentable.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct FroopMapViewRepresentable: UIViewRepresentable {
    @EnvironmentObject var locationSearchViewModel: LocationSearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = LocationServices.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopData: FroopData
    
    let mapView = MKMapView()
    
    @Binding var mapState: MapViewState
    
  

    func calculateDistance(to location: FroopData) -> Double {
        PrintControl.shared.printLocationServices("-FroopMapViewRepresentable: Function: calculateDistance is firing!")
        guard let userLocation = LocationManager.shared.userLocation else { return 0 }
        let froopData = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        PrintControl.shared.printLocationServices(froopData.description)
        PrintControl.shared.printLocationServices("8888888888888888888888")
        return userLocation.distance(from: froopData)
    }

    func makeUIView(context: Context) -> some UIView {
        PrintControl.shared.printLocationServices("-FroopMapViewRepresentable: Function: makeUIView is firing!")
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        if let userLocation = LocationManager.shared.userLocation {
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            mapView.setRegion(region, animated: false)
        }
        
        PrintControl.shared.printLocationServices("updating userLocation ELEVEN")
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        PrintControl.shared.printLocationServices("-FroopMapViewRepresentable: Function: updateUIView is firing!")
        switch mapState {
        case .noInput:
            PrintControl.shared.printLocationServices("NO INPUT")
            context.coordinator.clearMapViewAndRecenterOnUserLocation()
            break
        case .searchingForLocation:
            PrintControl.shared.printLocationServices("SEARCHING FOR LOCATION")
            break
        case .locationSelected:
            print("LOCATION SELECTED")
            if CLLocationCoordinate2DIsValid(froopData.froopLocationCoordinate) {
                PrintControl.shared.printLocationServices("DEBUG: Adding stuff to map..")
                context.coordinator.addAndSelectAnnotation(withCoordinate: froopData.froopLocationCoordinate)
                context.coordinator.configurePolyline(withDestinationCoordinate: froopData.froopLocationCoordinate)
                print("Froop Coordinates \(String(describing: froopData.froopLocationCoordinate))")
                print("User Coordinates \(self.mapView.userLocation)")
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
    
    func makeCoordinator() -> MapCoordinator {
        PrintControl.shared.printLocationServices("-FroopMapViewRepresentable: Function: makeCoordinator is firing!")
        return MapCoordinator(parent: self, mapUpdateState: MapUpdateState(), froopData: froopData)
    }
}

extension FroopMapViewRepresentable {
    
    class MapCoordinator: NSObject, MKMapViewDelegate {
        @ObservedObject var froopData: FroopData
        let mapView = MKMapView()
        @ObservedObject var locationManager = LocationManager.shared
        @ObservedObject var locationServices = LocationServices.shared // @Binding var mapState: MapViewState
        @EnvironmentObject var locationViewModel: LocationSearchViewModel
        
        // MARK: - Properties
        let mapUpdateState: MapUpdateState
        let parent: FroopMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        //var froopLocation: CLLocationCoordinate2D?
        
        //print("updating userLocation FOURTEEN")
        // MARK: - Lifecycle
        
        init(parent: FroopMapViewRepresentable, mapUpdateState: MapUpdateState, froopData: FroopData) {
            self.parent = parent
            self.mapUpdateState = mapUpdateState
            self.froopData = froopData
            
            super.init()
        }
        
        
        // MARK: - MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if LocationServices.shared.trackUserLocation == false {
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
            PrintControl.shared.printLocationServices("New Location: \(newCoordinate.latitude), \(newCoordinate.longitude)")
            
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
            PrintControl.shared.printLocationServices("-FroopMapViewRepresentable: Function: mapView2 is firing!")
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        
        // MARK: - Helpers
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            PrintControl.shared.printLocationServices("-FroopMapViewRepresentable: Function: addAndSelectAnnotation is firing!")
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            
            let anno = MKPointAnnotation()
            anno.coordinate = coordinate
            parent.mapView.addAnnotation(anno)
            parent.mapView.selectAnnotation(anno, animated: true)
        }
        
        func calculateDistance(to location: FroopData) -> Double {
            PrintControl.shared.printLocationServices("-FroopMapViewRepresentable: Function: calculateDistance is firing!")
            guard let userLocation = locationManager.userLocation else { return 0 }
            let froopData = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            return userLocation.distance(from: froopData)
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            PrintControl.shared.printMap("-FroopMapViewRepresentable: Function: configurePolyline is firing!")
            PrintControl.shared.printMap("DAVID - CONFIGURE POLY LINE STARTED")
            
            guard let userCoordinate = LocationManager.shared.userLocation?.coordinate else {
                return
            }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                guard let route = response?.routes.first else {
                    return
                }
                
                self?.parent.mapView.addOverlay(route.polyline)
                self?.parent.mapState = .polylineAdded
                
                let rect = self?.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect,
                                                                edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32))
                
                if let rect = rect {
                    self?.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                }
            }
        }
        
        func clearMapViewAndRecenterOnUserLocation() {
            PrintControl.shared.printMap("FroopMapViewRepresentable: Function: clearMapViewAndRecenterOnUserLocation is firing!")
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
            PrintControl.shared.printLocationServices("updating userLocation NINETEEN")
            if let currentRegion = currentRegion {
                parent.mapView.setRegion(currentRegion, animated: false)
            }
        }
    }
}

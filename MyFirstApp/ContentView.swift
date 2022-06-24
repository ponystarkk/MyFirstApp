//
//  ContentView.swift
//  MyFirstApp
//
//  Created by Mac on 20/6/2565 BE.
//

import SwiftUI
import MapKit //
class GlobalVar: ObservableObject{
    @Published var FixLatitude = "999"
    @Published var FixLongitude = "999"
}
struct ImageOverlay: View{
    @StateObject var globalvar = GlobalVar()
    @ObservedObject var locationManager = LocationManager()
    var userLatitude: String {
            return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
        }
    var userLongitude: String {
            return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
        }
    var body: some View{
        
        ZStack{
            Text("Name: Pony Stark" + "\nlatitude: \(String(Double(round((Double(userLatitude)!)*1000000)/1000000)))" + "\nlongitude: \(String(Double(round((Double(userLongitude)!)*100000)/1000000)))"+"\nREF: \(String(Int((Double(userLatitude)!)*(Double(userLongitude)!))))")
                .font(.callout)
                .padding(6)
                .foregroundColor(.white)
        }.background(Color.black)
            .opacity(0.8)
            .cornerRadius(10.0)
            .padding(6)
    }
}

struct ContentView: View {
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var image:UIImage?
    @StateObject var globalvar = GlobalVar()
    @StateObject private var viewModel = ContentViewModel()
    let ScreenWidth = UIScreen.main.bounds.size.width
        
    @ObservedObject var locationManager = LocationManager()
    var userLatitude: String {
            return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
        }
    var userLongitude: String {
            return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
        }
    
    var body: some View{
        /*
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)//
            .ignoresSafeArea()
            .accentColor(Color(.systemYellow))
            .onAppear{
                viewModel.checkIfLocationServicesIsEnabled()
            }*/
        
        NavigationView {
            VStack{
                Image(uiImage: image ?? UIImage(named: "PlaceHolder")!)
                    .resizable()
                    .frame(width:ScreenWidth,height:UIScreen.main.bounds.size.width*3/2)
                    .overlay(ImageOverlay(),alignment: .bottomTrailing)
                
                Button("Take a Picture"){
                    self.showSheet = true
                }.padding()
                    .actionSheet(isPresented: $showSheet) {
                        ActionSheet(title: Text("Select Photo"),message: Text("Choose"),buttons: [
                            /*
                            .default(Text("Photo Library")){
                                self.showImagePicker = true
                                self.sourceType = .photoLibrary
                            },*/
                            .default(Text("Camera")){
                                self.showImagePicker = true
                                self.sourceType = .camera
                                globalvar.FixLatitude = userLatitude
                                globalvar.FixLongitude = userLongitude
                            },
                            .cancel()
                        ])
                    }
            }
            .navigationTitle("Pong Horse Park")
        }.sheet(isPresented: $showImagePicker){
            ImagePicker(image: self.$image, isShown: self.$showImagePicker,sourceType: self.sourceType)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))//
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            checkLocationAuthorization()
        }else{
            print("Error")
        }
    }
    
    private func checkLocationAuthorization(){
        guard let locationManager = locationManager else {
            return
        }
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate,span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))//
        @unknown default:
            break
        }

    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

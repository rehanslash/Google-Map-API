//
//  Direction.swift
//  MapDemo
//
//  Created by SGI-Mac7 on 27/10/2016.
//  Copyright © 2016 Higher Visibility. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import GoogleMaps
import GoogleMapsDirections
import Alamofire
import MapKit


class Direction {
    
    static var directionShareInstance = Direction()
    
    var origin: String = ""
    var destination:String = ""
    var distance:Double = 0.0
    var overviewPolyline = ""
    var routeDistance = 0.0
    var routeTime = 0.0
    var mapRegionCoordinate = CLLocationCoordinate2D()
    
    var officesCordinate:[String:CLLocation] = ["CYP": CLLocation(latitude: 51.4179061, longitude: -0.0733453),"NBA":CLLocation(latitude: 51.648597, longitude: -0.173328),"NBT": CLLocation(latitude: 51.41245, longitude: -0.28409),"XYZ": CLLocation(latitude: 24.889014, longitude: 67.062616),"WCP":CLLocation(latitude: 51.3813, longitude: -0.24526),"SUR":CLLocation(latitude: 51.3922, longitude: -0.30329)]
    
    var distanceFromOffices:[String:CLLocationDistance] = [:]
    
    func getDistance_for_MultipleLocation(_ google_url:String,completion:@escaping (_ viasDistance:Double)->()){
        
        
        let url:URL = URL(string: google_url)!
        var fromViasDistance = 0.0
        Alamofire.request(url).responseJSON { (dataResponse) in
            
            print("resultValue",dataResponse.result.value!)
            
            let json = JSON(data: dataResponse.data!)
            
            let count = json["routes"][0]["legs"].count
            
            let legs_Array = json["routes"][0]["legs"]
            
            for i in 0 ..< count{
                
                let text = legs_Array[i]["distance"]["text"]
                let makeString = String(describing: text)
                
                if makeString.contains("km"){
                    
                    let b = makeString.components(separatedBy:" ")
                    let c = b[0]
                    
                    if c.contains(","){
                        let d = c.components(separatedBy:",")
                        let e = "\(d[0])\(d[1])"
                        let f = Double(e)
                        let distanceInMiles = f! * 0.62137
                        fromViasDistance = fromViasDistance + distanceInMiles
                        
                    }
                    else
                    {
                        let f = Double(c)
                        let distanceInMiles = f! * 0.62137
                        fromViasDistance = fromViasDistance + distanceInMiles
                        
                    }
                }
                    
                else if makeString.contains("mi"){
                    let b = makeString.components(separatedBy:" ")
                    let c = b[0]
                    if c.contains(","){
                        
                        let d = c.components(separatedBy:",")
                        let e = "\(d[0])\(d[1])"
                        let f = Double(e)
                        fromViasDistance = fromViasDistance + f!
                        
                    }else{
                        
                        let d = Double(c)
                        
                        fromViasDistance = fromViasDistance + d!
                        
                    }
                    
                }
                    
                else if makeString.contains("m"){
                    
                    let b = makeString.components(separatedBy:" ")
                    let c = b[0]
                    if c.contains(","){
                        
                        let d = c.components(separatedBy:",")
                        let e = "\(d[0])\(d[1])"
                        let f = Double(e)! * 0.000621371
                        fromViasDistance = fromViasDistance + f
                        
                    }else{
                        
                        let d = Double(c)! * 0.000621371
                        
                        fromViasDistance = fromViasDistance + d
                        
                    }
                    
                }
                
            }
            
            completion(fromViasDistance)
            
        }
    }
    
    
    func calculate_Vehicle_Rent(Distance:Double) -> [String:(Double,Double)]{
        
        var fareArray = [String:(Double,Double)]()
        
        let saloonfare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "S", distance: Distance)
        fareArray["S"] = saloonfare
        
        
        let estatefare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "E", distance: Distance)
        fareArray["E"] = estatefare
        
        
        let mpv6fare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "6", distance: Distance)
        fareArray["6"] = mpv6fare
        
        
        let eightfare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "8", distance: Distance)
        fareArray["8"] = eightfare
        
        
        let executivefare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "X", distance: Distance)
        fareArray["X"] = executivefare
        
        return fareArray
    }
    
    func Calculate_Fare(Vehicletype:String) -> (Double,Double) {
        
        let dis = JobDetails.shareInstance.jobMileage
        
        switch Vehicletype {
        case "S":
            let fare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "S", distance: dis)
            return fare
        case "E":
            let fare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "E", distance: dis)
            return fare
        case "6":
            let fare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "6", distance: dis)
            return fare
        case "X":
            let fare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "X", distance: dis)
            return fare
        case "8":
            let fare = Fare.sharedInstance.fareCalculationAccordingToMileage(vehicleSymbol: "8", distance: dis)
            return fare
            
        default:
            
            return (10.0,10.0)
        }
        
       
    }
    
    
    
    
    func calculateFareByVehicleType(_ vehicleType:String) -> Double{
         let coredataObject = DBOperations()
        var  fare:Double = 0
        switch vehicleType {
            
           
        case "SALOON":
            
            let dis = self.distance
            let saloon =  coredataObject.vehiclecostArrayCoreData("S")
            print(saloon)
            fare = Direction.calculateFare(saloon, distanceInMiles: dis)
            
        case "ESTATE":
            
            let dis = self.distance
            let estate =  coredataObject.vehiclecostArrayCoreData("E")
            fare = Direction.calculateFare(estate, distanceInMiles: dis)
            
            
        case "MPV6":
            
            let dis = self.distance
            let mpv6 =  coredataObject.vehiclecostArrayCoreData("6")
            fare =  Direction.calculateFare(mpv6, distanceInMiles: dis)
            
        case "MPV7":
            
            let dis = self.distance
            let mpv7 =  coredataObject.vehiclecostArrayCoreData("7")
            fare = Direction.calculateFare(mpv7, distanceInMiles: dis)
            
        case "8Passenger":
            
            let dis = self.distance
            let eight_passenger =  coredataObject.vehiclecostArrayCoreData("8")
            fare = Direction.calculateFare(eight_passenger, distanceInMiles: dis)
            
            //        case "Executive":
            //
            //            let dis = self.distance
            //            let executive = Config.configShareInstance.executiveCashCost
            //            fare = Direction.calculateFare(executive, distanceInMiles: dis)
            
        case "5Seater":
            
            let dis = self.distance
            let five =  coredataObject.vehiclecostArrayCoreData("5")
            fare = Direction.calculateFare(five, distanceInMiles: dis)
            
            //        case "lowcar":
            //
            //            let dis = self.distance
            //            let lowcar = Config.configShareInstance.lowCar
            //            fare = Direction.calculateFare(lowcar, distanceInMiles: dis)
            
        default: break
            
        }
        
        
        return fare
        
        
    }
    
    class func calculateFare(_ costArray:[Double],distanceInMiles:Double) -> Double{
        
        var fare:Double = 0.0
        
        if distanceInMiles > 5 && distanceInMiles < 28{
            
            let myfare:Double = 2 * costArray[0]
            let sub1 = distanceInMiles - 2
            let a:Double = sub1 * costArray[1]
            fare = myfare + a
            
        }
        else if distanceInMiles >= 28{
            
            let mul1:Double = 2 * costArray[0]
            let mul2:Double = 25 * costArray[1]
            let d:Double = distanceInMiles - 27
            let mul3:Double = d * costArray[2]
            fare = mul1 + mul2 + mul3
            
        }
        else{
            
            fare = 6.0
        }
        
        return fare
        
    }
    
    func get_place_detailBy_Apple(coordinate:CLLocationCoordinate2D,completion:@escaping (_ address:String)->()){
        
        
        let locatn = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(locatn, completionHandler:
            {(placemarks, error) in
                
                if error == nil{
                    
                    let place = placemarks![0]
                    
                    var place_addreess = ""
                    
                    
                    if let streetname = place.name{
                        
                        place_addreess = "\(place_addreess) \(streetname)"
                        
                    }
                    
                    
                    if let city = place.administrativeArea{
                        
                        place_addreess = "\(place_addreess) \(city)"
                        
                    }
                    
                    if let postalcode = place.postalCode{
                        
                        place_addreess = "\(place_addreess) \(postalcode)"
                        
                    }
                    
                    completion(place_addreess)
                }
                    
                else{
                    
                    completion("")
                    
                    
                }
                
        })
        
        
        
        
    }
    

    
    func getEstimatedTime(fromlat:Double,fromLong:Double,toLat:Double,toLong:Double,callback:@escaping (_ journeytime:Double,_ distance:Double,_ result:Bool,_ error:String?)->()){
        
        var travelTime = 0.0
        var traveldistance = 0.0
        
        if fromlat != 0.0 && fromLong != 0.0 && toLat != 0.0 && toLong != 0.0 {
            
            let currentLocation = CLLocationCoordinate2D(latitude: fromlat, longitude: fromLong)
            let destinationLocation = CLLocationCoordinate2D(latitude: toLat, longitude: toLong)
            let sourcePlacemark = MKPlacemark(coordinate: currentLocation, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            let directionRequest = MKDirectionsRequest()
            
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .automobile
            directionRequest.requestsAlternateRoutes = true
            
            
            let directions = MKDirections(request: directionRequest)
            
            directions.calculate {
                
                (response, error) -> Void in
                
                if let response = response, error == nil{
                    
                    let sortedRoutes: [MKRoute] = response.routes.sorted(by: {$0.expectedTravelTime < $1.expectedTravelTime})
                    travelTime = sortedRoutes[0].expectedTravelTime
                    traveldistance = sortedRoutes[0].distance
                    callback(travelTime,traveldistance,true,nil)
                    
                }else{
                    callback(travelTime,traveldistance,false,error!.localizedDescription)
                }
            }
        }else{
            
            callback(travelTime,traveldistance,false,"please enter Addresses Again")
        }
    }
    
    
    func getplace_Address_postalcode(coordinate:CLLocationCoordinate2D,completion:@escaping (_ address:String,_ postcode:String)->()){
        
        
        let locatn = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(locatn, completionHandler:
            {(placemarks, error) in
                var place_addreess = ""
                var postal_code = "NPC"
                
                if error == nil{
                    
                    let place = placemarks![0]
                    
                    
                    
                    if let streetname = place.name{
                        
                        place_addreess = "\(place_addreess) \(streetname)"
                        
                    }
                    
                    
                    if let city = place.administrativeArea{
                        
                        place_addreess = "\(place_addreess) \(city)"
                        
                    }
                    
                    if let postalcode = place.postalCode{
                        
                        postal_code = postalcode
                        
                    }
                    
                    completion(place_addreess,postal_code)
                }
                    
                else{
                    
                    completion(place_addreess,postal_code)
                    
                    
                }
                
        })
        
        
        
        
    }
    
    
    

    func getPlace_PostalCode(coordinate:CLLocationCoordinate2D,callback:@escaping (_ postalCode:String)->()){
        
        let locatn = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        print("Rehan Testing\(locatn)")
        
        CLGeocoder().reverseGeocodeLocation(locatn, completionHandler:
            {(placemarks, error) in
                var place_addreess = ""
                
                if error == nil{
                    
                    let place = placemarks![0]
                    
                    if let postalcode = place.postalCode{
                        
                        place_addreess = postalcode
                        
                        callback(place_addreess)
                        
                    }else{
                        
                        
                        callback(place_addreess)
                        
                    }
                    
                    
                }
                    
                else{
                    
                    callback(place_addreess)
                    
                    
                }
                
        })
        
        
    }
    
    
    func geocodeByLatLong(coordinate:CLLocationCoordinate2D,callback:@escaping (_ response:GMSReverseGeocodeResponse,_ error:String)->()){
        
        GMSGeocoder().reverseGeocodeCoordinate(coordinate) { (google_response, google_error) in
            if google_error == nil{
                
                callback(google_response!, "")
                
                
            }else{
                
                callback(google_response!, "Geocode Error")
                
            }
        }
    }
    
    
    func getDirection(callback:@escaping (_ polylinePoints:String ,_ invalidaddress: Bool,_ error:String)->()){
        
        var invalidAdd:Bool = true
        
        if let origin = JobDetails.shareInstance.origin_cordinate{
            
            if let destination = JobDetails.shareInstance.destination_coordinate{
                
                let request = "https://maps.googleapis.com/maps/api/directions/json"
                let parameters : [String : Any] = ["origin" : "\(origin.latitude),\(origin.longitude)", "destination" : "\(destination.latitude),\(destination.longitude)","avoid":"highways|tolls|ferries", "key" : OfficeConfig.shareInstance.googleDirectionKey]
                
                
                

                print(request)
                print(parameters)
                
                if FlagVariables.internet_status != 3 {
                    
                    Alamofire.request(request, method:.get, parameters : parameters).responseJSON(completionHandler: { response in
                        
                        guard let dictionary = response.result.value as? [String : AnyObject]
                            
                            else {
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyUserDefaults.GoogleResponce), object: nil)
                                return
                        }
                        
                        let josn = JSON(dictionary)
                        
                        let routes = josn["routes"][0]
                        let polyline = routes["overview_polyline"]["points"]
                        let distance = routes["legs"][0]["distance"]
                        let distanceText = distance["text"]
                        let distanceValue = distance["value"]
                        let duration = routes["legs"][0]["duration"]
                        let durationText = duration["text"]
                        let durationValue = duration["value"]
                        JobDetails.shareInstance.job_eta = "\(durationText)"
                        
                        print("Duration \(durationText),,,,,,,Duartion \(durationValue)")
                        print("Distance \(distanceText),,,,,,,Distance \(distanceValue)")

                        let array = "\(distanceText)".components(separatedBy: " ")
                        
                        if array.contains("null"){
                            invalidAdd = false
                            
                        }else{
                            
                            self.convertDistanceToMiles(distance: "\(distanceText)")
                            self.overviewPolyline = "\(polyline)"
                            
                        }
                        
                        callback("\(polyline)",invalidAdd,"")
                        
                    })
                    
                }else {
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyUserDefaults.networkNotification), object: nil)
                    callback("", false,"Network down")
                    
                }
            }else{
                
                
                
                callback("", false,"Please Enter Destination Adress Again")
                
            }
        }else{
            
            
            
            callback("", false,"Please Enter Pick Up Adress Again")
        }
    }
    
    
    
    //MARK:- Get Lat and Long by Geocode
    
    func getLatLong(Address:String) {
        
        let request = "https://maps.googleapis.com/maps/api/geocode/json?"
        let apikey = OfficeConfig.shareInstance.googleServiceKey
        let parameters :[String:Any] =  ["key":apikey,"components":"locality:\(Address)"]
        

        Alamofire.request(request, method:.get, parameters : parameters).responseJSON(completionHandler: { response in
            
            guard let dictionary = response.result.value as? [String : AnyObject]
                else {
                    return
            }
            
            let josn = JSON(dictionary)
            print("This is Testing \(josn)")
        
            
        })
    }
    
    
    //Mark :- Get Direction between Customer and Driver
    func getDirectionbtwDrvCust(callback:@escaping (_ polylinePoints:String)->()){
        
      if let origin = JobDetails.shareInstance.origin_cordinate{
        //let destination = JobDetails.shareInstance.destination_coordinate
        
         let drvLat = DriverLoc.sharedInstance.lattitude
        let drvLon = DriverLoc.sharedInstance.longitude
    
        let request = "https://maps.googleapis.com/maps/api/directions/json"
        let parameters : [String : Any] = ["origin" : "\(origin.latitude),\(origin.longitude)", "destination" : "\(drvLat),\(drvLon)","avoid":"highways|tolls|ferries", "key" :OfficeConfig.shareInstance.googleDirectionKey]
        
        
        Alamofire.request(request, method:.get, parameters : parameters).responseJSON(completionHandler: { response in
            
            guard let dictionary = response.result.value as? [String : AnyObject]
                else {
                    return
            }
            
            let josn = JSON(dictionary)
            let routes = josn["routes"][0]
            let polyline = routes["overview_polyline"]["points"]
            let distance = routes["legs"][0]["distance"]
            print("Rehan testing \(distance)")
            let distanceText = distance["text"]
            let distanceValue = distance["value"]
            let duration = routes["legs"][0]["duration"]
            let durationText = duration["text"]
            let durationValue = duration["value"]
            JobDetails.shareInstance.job_eta = "\(durationText)"
            print("Duration \(durationText),,,,,,,Duartion \(durationValue)")
            print("Distance \(distanceText),,,,,,,Distance \(distanceValue)")
            
            self.convertDistanceToMiles(distance: "\(distanceText)")
            
            self.overviewPolyline = "\(polyline)"
            
            callback("\(polyline)")
            
         })
    
        }
    }

    func convertDistanceToMiles(distance:String){
        
        let array = distance.components(separatedBy: " ")
        let dis = self.remove_specific_character_In_String(remove_Char: ",", fromString: array[0])
        let distanceValue:Double = Double(dis)!
        let distanceUnits = array[1]
        
        switch distanceUnits {
            
        case "km":
            JobDetails.shareInstance.jobMileage = round(Config.formatDouble(distanceValue * 0.621371192 , precision: 2))
        case "m":
            JobDetails.shareInstance.jobMileage = round(Config.formatDouble(distanceValue * 0.000621371, precision: 2))
        case "mi":
            JobDetails.shareInstance.jobMileage = round(distanceValue)
        default:
            break
            
        }
    }
    
    func remove_specific_character_In_String(remove_Char:String,fromString:String) -> String{
        
        var fromString = fromString
        
        if fromString.contains(remove_Char){
            
            fromString = fromString.replacingOccurrences(of: remove_Char, with: "")
        }
        
        return fromString
        
    }

}
extension Double {
    var array: [Double] {
        return description.characters.map{Double(String($0)) ?? 0}
    }
}


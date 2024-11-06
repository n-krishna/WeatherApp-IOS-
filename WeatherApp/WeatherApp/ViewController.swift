//
//  ViewController.swift
//  WeatherApp
//
//  Created by Nithin Krishna on 2024-10-30.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
  
    @IBOutlet weak var currentLocBtn: UIButton!
    @IBOutlet weak var searchTextField:UITextField!
    @IBOutlet weak var weatherConditionImage:UIImageView!
    @IBOutlet weak var temperatureLabel:UILabel!
    @IBOutlet weak var locationLabel:UILabel!
    private var tempFlag:Bool = false
    private var cTemp:String = "Temperature"
    private var fTemp:String = "Temperature"
    private var backgroundImageView: UIImageView?
    let locManager = CLLocationManager()
    var isDay:Int = 0
    struct WeatherResponse:Decodable{
            let location:Location
            let current:Weather    }
        
        struct Location:Decodable{
            let name:String
        }
        
        struct Weather:Decodable{
            let temp_c:Float
            let temp_f:Float
            let is_day:Int
            let condition:WeatherCondition
        }
        
        struct WeatherCondition:Decodable{
            let text:String
            let code:Int
        }
        
        @IBOutlet weak var tempSwitch: UISwitch!
        override func viewDidLoad() {
            super.viewDidLoad()
            
            displayImage(imageName: "snowflake", colours: [.white,.orange])
            
            currentLocBtn.setImage(UIImage(systemName: "location.circle"), for: .normal)
            
            searchTextField.delegate = self
            getLocation()
    //        if isDay == 1{
    //            setupBackgroundImage("morning")
    //        }else{
    //            setupBackgroundImage("night")
    //        }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.endEditing(true)
            getWeather(textField.text ?? "")
            return true
        }
      
        @IBAction func tempSwitchToggled(_ sender: UISwitch) {
            
            if sender.isOn{
                tempFlag = true
                temperatureLabel.text = fTemp
            }else{
                tempFlag = false
                temperatureLabel.text = cTemp
            }
            
        }
        @IBAction func onLocationTapped(_ sender: Any) {
            getLocation()
        }
        private func getLocation()
        {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.requestWhenInUseAuthorization()
                locManager.requestLocation()
        }
        
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let first = locations.first else{
                return
            }
            getWeather("\(first.coordinate.latitude),\(first.coordinate.longitude)")
            print("\(first.coordinate.longitude) | \(first.coordinate.latitude)")
            locManager.stopUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("\(error)")
        }
        
        @IBAction func onSearchTapped(_ sender: Any) {
            searchTextField.endEditing(true)
            getWeather(searchTextField.text ?? "")
        }
        
    private func getWeather(_ location: String?) {
        guard let location = location, let url = getUrl(loc: location) else { return }
        let urlSession = URLSession.shared
        let dataTask = urlSession.dataTask(with: url) { data, response, err in
            guard err == nil, let data = data, let weatherResponse = self.parseJson(data: data) else { return }
            DispatchQueue.main.async {
                self.updateUI(with: weatherResponse)
            }
        }
        dataTask.resume()
    }
                        private func parseJson(data: Data) -> WeatherResponse? {
                            let decoder = JSONDecoder()
                            return try? decoder.decode(WeatherResponse.self, from: data)
                        }
                            
                        private func getUrl(loc: String) -> URL? {
                            let baseURL = "https://api.weatherapi.com/v1/"
                            let currentEndpoint = "current.json"
                            let apiKey = "719ecab90bae4c25bd104607240611"
                            let urlString = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(loc)&aqi=no"
                            return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                        }

                        private func displayImage(imageName img: String, colours colors: [UIColor]) {
                            let config = UIImage.SymbolConfiguration(paletteColors: colors)
                            weatherConditionImage.preferredSymbolConfiguration = config
                            weatherConditionImage.image = UIImage(systemName: img)
                        }

                        private func updateUI(with weatherResponse: WeatherResponse) {
                            locationLabel.text = weatherResponse.location.name
                            cTemp = "\(weatherResponse.current.temp_c) C"
                            fTemp = "\(weatherResponse.current.temp_f) F"
                            
                            let code = weatherResponse.current.condition.code
                            let weatherImages: [Int: String] = [
                                1000: "sun.max", 1003: "cloud.sun", 1006: "cloud", 1009: "cloud", 1030: "cloud.fog",
                                1135: "cloud.fog", 1147: "cloud.fog", 1063: "cloud.sun.rain", 1180: "cloud.sun.rain",
                                1186: "cloud.sun.rain", 1072: "cloud.sun.rain", 1189: "cloud.sun.rain",
                                1066: "cloud.snow", 1210: "cloud.snow", 1213: "cloud.snow", 1216: "cloud.snow",
                                1219: "cloud.snow", 1222: "cloud.snow", 1225: "cloud.snow", 1255: "cloud.snow",
                                1258: "cloud.snow", 1117: "cloud.snow", 1114: "cloud.sleet", 1069: "cloud.sleet",
                                1204: "cloud.sleet", 1207: "cloud.sleet", 1237: "cloud.sleet", 1249: "cloud.sleet",
                                1252: "cloud.sleet", 1261: "cloud.sleet", 1264: "cloud.sleet", 1087: "cloud.drizzle",
                                1083: "cloud.drizzle", 1195: "cloud.drizzle", 1240: "cloud.drizzle", 1086: "cloud.heavyrain",
                                1089: "cloud.heavyrain", 1192: "cloud.heavyrain", 1198: "cloud.heavyrain",
                                1201: "cloud.heavyrain", 1243: "cloud.heavyrain", 1246: "cloud.heavyrain",
                                1150: "cloud.sun.bolt", 1153: "cloud.sun.bolt", 1168: "cloud.sun.bolt",
                                1171: "cloud.sun.bolt", 1273: "cloud.bolt.rain", 1276: "cloud.bolt.rain",
                                1279: "cloud.bolt.rain", 1282: "cloud.bolt.rain"
                            ]
                            
                            
                            let selectedImageName = weatherImages[code]
                            displayImage(imageName: selectedImageName ?? "cloud", colours: [.white, .orange])
                            
                            temperatureLabel.text = tempFlag ? fTemp : cTemp
                        }
                    }
    

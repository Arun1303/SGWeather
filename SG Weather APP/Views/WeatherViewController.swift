//
//  WeatherViewController.swift
//  SG Weather APP
//
//  Created by Prabal on 21/03/22.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    var weatherData : WeatherModel?
    
    lazy var searchTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Type Something"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.search
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    
    lazy var tableSetup:UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .blue
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSetup.register(WeatherTopCell.self, forCellReuseIdentifier: "WeatherTopCell")
        tableSetup.register(WeatherBottomCell.self, forCellReuseIdentifier: "WeatherBottomCell")

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(statusManager),
                         name: .flagsChanged,
                         object: nil)

        self.navigationItem.title = "SG Weather"
        view.backgroundColor = .blue
        updateUserInterface()
        searchTextField.delegate = self
        constraintsSetup()
    }
    
    func updateUserInterface() {
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
        
        if Network.reachability.isReachable {
            searchTextField.text = ""
            locationAccess()
        } else {
            showAlert(withTitle: "Internet Connectivity is not reachable. Please check the internet connection.")
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func constraintsSetup() {
        view.addSubview(searchTextField)
        view.addSubview(tableSetup)
        let margineGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: margineGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: margineGuide.leadingAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 40),
            searchTextField.trailingAnchor.constraint(equalTo: margineGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableSetup.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 0),
            tableSetup.leadingAnchor.constraint(equalTo: margineGuide.leadingAnchor),
            tableSetup.trailingAnchor.constraint(equalTo: margineGuide.trailingAnchor),
            tableSetup.bottomAnchor.constraint(equalTo: margineGuide.bottomAnchor, constant: 20)
        ])
        
    }
    
   
    func locationAccess() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                // This is the first and the ONLY time you will be able to ask the user for permission
                locationManager.delegate = self
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                break

            case .restricted, .denied:
                // Disable location features
               
                let alert = UIAlertController(title: "Allow Location Access", message: "SG Weather App needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)

                // Button to Open Settings
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                }))
               // alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

                break

            case .authorizedWhenInUse, .authorizedAlways:
                // Enable features that require location services here.
                print("Full Access")
//                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                
                if CLLocationManager.locationServicesEnabled(){
                    locationManager.startUpdatingLocation()
                }
            
                let lat = locationManager.location?.coordinate.latitude ?? 0.0
                let long = locationManager.location?.coordinate.longitude ?? 0.0
               print(lat , long, "latlong")
                self.locationGeocode(lat: lat, long: long)
               
                break
            @unknown default:
                break
            }
        }
    }
    
    func locationGeocode(lat : CLLocationDegrees , long : CLLocationDegrees) {
        let location = CLLocation(latitude: lat, longitude: long) //changed!!!
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                return
            }else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality {
                print(country)
                print(country , "country")
                self.apiToGetWeatherData(city: city, completion: {
                    (WeatherModel) in
                    self.weatherData = WeatherModel
                    print(self.weatherData?.error?.message)
                    if self.weatherData?.error?.message == "" {
                        DispatchQueue.main.async {
                            self.tableSetup.delegate = self
                            self.tableSetup.dataSource = self
                            self.tableSetup.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(withTitle: self.weatherData?.error?.message ?? "API Error")
                        }
                        
                    }
                    
                })
            }
            else {
            }
        })
    }
    
    func apiToGetWeatherData(city : String, completion : @escaping (WeatherModel) -> ()){
        var urlComps = URLComponents(string: apiurl)!
        var queryItems: [URLQueryItem] =  []
        let queryItem1 = URLQueryItem(name: "key", value: apikey)
        let queryItem2 = URLQueryItem(name: "q", value: city)
        let queryItem3 = URLQueryItem(name: "days", value: "7")
        let queryItem4 = URLQueryItem(name: "aqi", value: "no")
        let queryItem5 = URLQueryItem(name: "alerts", value: "no")
        queryItems.append(queryItem1)
        queryItems.append(queryItem2)
        queryItems.append(queryItem3)
        queryItems.append(queryItem4)
        queryItems.append(queryItem5)
        
        urlComps.queryItems = queryItems
        let result = urlComps.url!
        print(result)
        
        URLSession.shared.dataTask(with: result) { (data, urlResponse, error) in
            print(data,urlResponse?.url,urlResponse)
            if let data = data {
                let jsonDecoder = JSONDecoder()
                let weatherData = try! jsonDecoder.decode(WeatherModel.self, from: data)
                completion(weatherData)
            }
        }.resume()
    }
    
    func showAlert(withTitle message: String) {
        let alert = UIAlertController(title: APP_NAME, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension WeatherViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            self.apiToGetWeatherData(city: city, completion: {
                (WeatherModel) in
                self.weatherData = WeatherModel
                if self.weatherData?.error?.message == "" {
                    DispatchQueue.main.async {
                        self.tableSetup.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(withTitle: self.weatherData?.error?.message ?? "API Error")
                    }
                    
                }
               
            })
        } else {
            locationAccess()
        }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            self.locationGeocode(lat: lat, long: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Fail to get user location")
    }
}

extension WeatherViewController : UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return weatherData?.forecast?.forecastday?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTopCell", for: indexPath) as! WeatherTopCell
            if let imageString = (weatherData?.current?.condition?.icon) {
                if let urlString = URL(string: "https:" + imageString) {
                    if let data = try? Data(contentsOf: urlString) {
                        cell.weatherImageView.image = UIImage(data: data)
                    }
                }
            }
            cell.temperatureLabel.text = "\(weatherData?.current?.temp_c ?? 0.0)\u{00B0} C"
            cell.cityLabel.text = weatherData?.location?.name ?? ""
            cell.selectionStyle = .none
            cell.backgroundColor = .blue
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherBottomCell", for: indexPath) as! WeatherBottomCell
            cell.selectionStyle = .none
            if let current_date = (weatherData?.forecast?.forecastday?[indexPath.row].date) {
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "yyyy-MM-dd"
                if let showDate = inputFormatter.date(from: current_date) {
                    inputFormatter.dateFormat = "E"
                    let resultString = inputFormatter.string(from: showDate)
                    cell.dayLabel.text = resultString
                }
            }
           
           
            let min = weatherData?.forecast?.forecastday?[indexPath.row].day?.mintemp_c ?? 0.0
            let max = weatherData?.forecast?.forecastday?[indexPath.row].day?.maxtemp_c ?? 0.0
            cell.tempLabel.text = "Min \(min)\u{00B0}" + " " + "Max \(max)\u{00B0}" 
            let condition = weatherData?.forecast?.forecastday?[indexPath.row].day?.condition?.text ?? ""
            cell.conditionLabel.text = condition
            if let imageString = (weatherData?.forecast?.forecastday?[indexPath.row].day?.condition?.icon) {
                if let urlString = URL(string: "https:" + imageString) {
                    if let data = try? Data(contentsOf: urlString) {
                        cell.weatherImageView.image = UIImage(data: data)
                    }
                }
            }
           
            cell.backgroundColor = .white
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 325
        case 1 :
            return 75
        default:
            return 0
        }
    }
    
    
}

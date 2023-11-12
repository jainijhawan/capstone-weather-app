//
//  SearchViewController.swift
//  Weather App
//
//  Created by Harwinderjit Kaur on 2023-11-02.
//

import UIKit
import Magnetic
import SpriteKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var magneticView: MagneticView!
    @IBOutlet weak var cityNameTableview: UITableView!
    
    var cityNameDataSource: [(name: String, lat:Double, lon: Double)] = []
    weak var delegate: ViewControllerDelegate?
    
    
    var magnetic: Magnetic?
    let nodes = [Node(text: "Delhi", color: UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00), radius: 50),
                 Node(text: "Mumbai", color: UIColor(red: 0.85, green: 0.36, blue: 0.39, alpha: 1.00), radius: 50),
                 Node(text: "Bangalore", color: UIColor(red: 0.84, green: 0.50, blue: 0.68, alpha: 1.00), radius: 60),
                 Node(text: "Hyderabad", color: UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.00), radius: 60),
                 Node(text: "Kolkata", color: UIColor(red: 0.75, green: 0.73, blue: 0.50, alpha: 1.00), radius: 60),
                 Node(text: "Chennai", color: UIColor(red: 0.99, green: 0.77, blue: 0.49, alpha: 1.00), radius: 50),
                 Node(text: "Gurgaon", color: UIColor(red: 0.92, green: 0.24, blue: 0.28, alpha: 1.00), radius: 60)]
    
    var searchData: [CityData] = [(city: "Delhi", country: "India", lat: "28.6600", lon: "77.2300"),
                                  (city: "Mumbai", country: "India", lat: "18.9667", lon: "72.8333"),
                                  (city: "Bangalore", country: "India", lat: "12.9699", lon: "77.5980"),
                                  (city: "Hyderabad", country: "India", lat: "17.3667", lon: "78.4667"),
                                  (city: "Kolkata", country: "India", lat: "22.5411", lon: "88.3378"),
                                  (city: "Chennai", country: "India", lat: "13.0825", lon: "80.2750"),
                                  (city: "Gurgaon", country: "India", lat: "28.4500", lon: "77.0200")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        magnetic = magneticView.magnetic
        magnetic?.allowsMultipleSelection = false
        magnetic?.backgroundColor = .clear
        magnetic?.magneticDelegate = self
        nodes.forEach { (node) in
            magnetic?.addChild(node)
        }
        cityNameTableview.delegate = self
        cityNameTableview.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func hideAllNodes() {
      for node in nodes {
        let scaleAction = SKAction.scale(to: 0, duration: 0.5)
        node.run(scaleAction)
      }
    }
    @IBAction func backDidTap(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension SearchViewController: UITableViewDelegate,
                                UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cityNameDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchCityTableViewCell.self), for: indexPath) as? SearchCityTableViewCell else {
            return UITableViewCell()
        }
        cell.setupUI(cityNameText: cityNameDataSource[indexPath.row].name)
        cell.selectionStyle = .none
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        cityNameDataSource.removeAll()
        guard let searchText = searchBar.text else { return }
        WeatherServices.shared.getCityNames(searchText: searchText) { success, cityNameModel in
            if success,
               let cityNameModel {
                self.cityNameDataSource = cityNameModel.results?.map({ result in
                    let name = "\(result.city ?? ""), \(result.country ?? "")"
                    return (name: name, lat:result.lat ?? 0, lon: result.lon ?? 0)
                }) ?? []
                
                DispatchQueue.main.async {
                    self.cityNameTableview.reloadData()
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        hideAllNodes()
    }
}


extension SearchViewController {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = cityNameDataSource[indexPath.row]
        let alert = UIAlertController(title: "Add \(selectedCity.name) to favourites", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            saveCityToDataBase(model: SavedCityModel(name: selectedCity.name, lat: selectedCity.lat, lon: selectedCity.lon, temp: 0))
            self.dismiss(animated: true) {
                self.delegate?.reloadCityList()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension SearchViewController: MagneticDelegate {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        let index = nodes.firstIndex(of: node)!
        let selectedCity = searchData[index]
        let alert = UIAlertController(title: "Add \(selectedCity.city) to favourites", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            saveCityToDataBase(model: SavedCityModel(name: selectedCity.city,
                                                     lat: Double(selectedCity.lat) ?? 0,
                                                     lon: Double(selectedCity.lon) ?? 0,
                                                     temp: 0))
            self.dismiss(animated: true) {
                self.delegate?.reloadCityList()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        
    }
}

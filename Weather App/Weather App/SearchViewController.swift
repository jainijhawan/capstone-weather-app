//
//  SearchViewController.swift
//  Weather App
//
//  Created by Harwinderjit Kaur on 2023-11-02.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityNameTableview: UITableView!
    
    var cityNameDataSource: [(name: String, lat:Double, lon: Double)] = []
    weak var delegate: ViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        cityNameTableview.delegate = self
        cityNameTableview.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
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


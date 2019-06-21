//
//  AutoCompleteViewController.swift
//  GoogleMapAutoCompletewithUitextfieldDemo
//
//  Created by Technoduce on 21/06/19.
//  Copyright © 2019 Satheesh. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class AutoCompleteViewController: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var AutoCompleteField: UITextField!
    @IBOutlet weak var AutoCompleteTableview: UITableView!
    
    var tableValue = [GMSAutocompletePrediction]()
    var fetcher: GMSAutocompleteFetcher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GMSServices.provideAPIKey("") // GoogleMap - Api Key
        GMSPlacesClient.provideAPIKey("") // GoogleMap - Client Key

        AutoCompleteField.font = UIFont.systemFont(ofSize: 18)
        AutoCompleteField.attributedPlaceholder = NSAttributedString(string: "placeholder text",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        AutoCompleteField?.addTarget(self, action: #selector(textFieldDidChange(textField:)),for: .editingChanged)

        AutoCompleteField.delegate = self
        AutoCompleteTableview.delegate = self
        AutoCompleteTableview.dataSource = self
        AutoCompleteTableview.tableFooterView = UIView()
        

        let filter = GMSAutocompleteFilter() // GMS - Filter
        filter.type = .establishment // GMS - Map Filter type (Geocode,Address,Establishment,Region,City)
        fetcher  = GMSAutocompleteFetcher(bounds: nil, filter: filter)
        fetcher?.delegate = self
        
        AutoCompleteTableview.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func textFieldDidChange(textField: UITextField) {
        fetcher?.sourceTextHasChanged(textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
}
// Custom Cell
class AutoCompleteCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var AutoCompleteLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
// UITableView - delegate datasource method
extension AutoCompleteViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell") as! AutoCompleteCell
        cell.AutoCompleteLabel?.text = tableValue[indexPath.row].attributedFullText.string
        cell.AutoCompleteLabel.font = UIFont.systemFont(ofSize: 18)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AutoCompleteField.text = tableValue[indexPath.row].attributedFullText.string
        getLatLongFromAutocompletePrediction(prediction:tableValue[indexPath.row])
        AutoCompleteTableview.isHidden = true
    }
    
    func getLatLongFromAutocompletePrediction(prediction:GMSAutocompletePrediction){
        let placeClient = GMSPlacesClient()
        placeClient.lookUpPlaceID(prediction.placeID) { (place, error) -> Void in
            if error != nil {
                //show error
                return
            }
            if let place = place {
                print(place.coordinate.longitude)   // longitude
                print(place.coordinate.latitude)   // latitude
            } else {
                //show error
            }
        }
    }
}

extension AutoCompleteViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        tableValue.removeAll()
        for prediction in predictions{
            tableValue.append(prediction)
        }
        if tableValue.count > 0 {
            AutoCompleteTableview.isHidden = false
        }else{
            AutoCompleteTableview.isHidden = true
        }
        AutoCompleteTableview.reloadData()
    }
    func didFailAutocompleteWithError(_ error: Error) {
        print(error.localizedDescription)
    }
}

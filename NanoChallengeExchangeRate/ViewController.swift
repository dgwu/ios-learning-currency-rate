//
//  ViewController.swift
//  NanoChallengeExchangeRate
//
//  Created by Daniel Gunawan on 26/09/18.
//  Copyright © 2018 Daniel Gunawan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource {
    
    @IBOutlet weak var baseCurrencyButton: UIButton!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    @IBOutlet weak var currencyTableView: UITableView!
    
    var pickerViewIsDisplayed: Bool = false
    
    let currencyOptions = ["IDR", "USD", "EUR", "JPY", "HKD"]
    struct Currency {
        let code: String
        let value: Double
    }
    var currencyData = [Currency]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func initialSetup() {
        self.currencyPickerView.isHidden = true
        self.currencyPickerView.delegate = self
        self.currencyPickerView.dataSource = self
        self.currencyPickerView.backgroundColor = UIColor.white
        
        self.baseCurrencyButton.addTarget(self, action: #selector(togglePickerView), for: .touchUpInside)
        
        currencyTableView.dataSource = self;
        
        // select IDR as initial
        self.baseCurrencyButton.setTitle(currencyOptions[0], for: .normal)
        fetchCurrencyData(baseCurrency: currencyOptions[0])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.currencyOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.currencyOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.baseCurrencyButton.setTitle(currencyOptions[row], for: .normal)
        self.togglePickerView()
        fetchCurrencyData(baseCurrency: currencyOptions[row])
    }

    // MARK : Table View Setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        
        cell.textLabel?.text = currencyData[indexPath.row].code
        cell.detailTextLabel?.text = String.init(format: "%.4f", currencyData[indexPath.row].value)
        
        return cell
    }
    
    // MARK : Action
    @objc func togglePickerView() {
        UIView.animate(withDuration: 0.5) {
            self.currencyPickerView.isHidden.toggle()
        }
    }
    
    func fetchCurrencyData (baseCurrency: String) {
        let url = URL(string: "https://api.exchangeratesapi.io/latest?base=\(baseCurrency)")
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if let unwrappedError = error {
                print("error: \(unwrappedError.localizedDescription)")
            } else if let data = data {
                if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] {
                    if let rateList = jsonObj["rates"] as? [String:Double] {
                        self.currencyData.removeAll()
                        
                        for (code, value) in rateList {
                            self.currencyData.append(Currency(code: code, value: value))
                        }
                        
                        DispatchQueue.main.async {
                            self.currencyTableView.reloadData()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    } else {
                        print("failed to decode rate")
                    }
                } else {
                    print("failed to decode")
                }
            }
        }
        
        dataTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}


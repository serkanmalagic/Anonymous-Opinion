//
//  PuanVerViewController.swift
//  Come-To-Yourself
//
//  Created by Serkan Mehmet Malagiç on 16.04.2020.
//  Copyright © 2020 Serkan Mehmet Malagiç. All rights reserved.
//

import UIKit
import SCLAlertView
import SPAlert
import SwiftOverlays
import PopupDialog

class PuanVerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var puan = 0
    var indexPathRow = 0
    
    //tüm puanlar sırayla bu dizide tutulacak
    //soru sayısı değişince burası da değişmelidir
    var puanArray = [3,3,3,3,3,3]
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //BÜYÜK BAŞLIKLAR
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
        //TABLOADKİ SONDAKİ ÇİZGİLERİ KALDIRIR
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //geri dönüş butonu deaktif etme
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        
        
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "info"), style: .done, target: self, action: #selector(PuanVerViewController.infoTapped))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        
        //KULLANICIYA BEKLEMESİ SÖYLENECEK
        let alert = UIAlertController(title: nil, message: "Sorular Listeleniyor...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
            self.fetchQuestions()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sorularJson.count == 0{
            print(puanArray)
            
        }
        return sorularJson.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoruCell") as! PuanVerTableViewCell
        
        //Tüm butonlara aksiyon eklemesi yapacağız
        cell.btn1.addTarget(self, action: #selector(btn1Tapped(_:)), for: .touchUpInside)
        cell.btn1.tag = indexPath.row
        cell.btn2.addTarget(self, action: #selector(btn2Tapped(_:)), for: .touchUpInside)
        cell.btn2.tag = indexPath.row
        cell.btn3.addTarget(self, action: #selector(btn3Tapped(_:)), for: .touchUpInside)
        cell.btn3.tag = indexPath.row
        cell.btn4.addTarget(self, action: #selector(btn4Tapped(_:)), for: .touchUpInside)
        cell.btn4.tag = indexPath.row
        cell.btn5.addTarget(self, action: #selector(btn5Tapped(_:)), for: .touchUpInside)
        cell.btn5.tag = indexPath.row
        
        cell.soruLabel.text = sorularJson[indexPath.row].soru
        
        
        
        //gölge verme
        cell.shadowView.layer.shadowColor = UIColor.gray.cgColor
        cell.shadowView.layer.shadowOpacity = 0.6
        cell.shadowView.layer.shadowOffset = CGSize.zero
        cell.shadowView.layer.shadowRadius = 5
        cell.shadowView.layer.cornerRadius = 10
        
        
        //SEÇİM YAPILACAK HÜCRENİN ARKA PLAN RENGİNİ AYARLIYORUZ.
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        //layer köşe yumuşatma
        cell.btn1.layer.cornerRadius = 15
        cell.btn2.layer.cornerRadius = 15
        cell.btn3.layer.cornerRadius = 15
        cell.btn4.layer.cornerRadius = 15
        cell.btn5.layer.cornerRadius = 15
        
        
        return cell
        
    }
    
    //CELL İÇERİSİNDE BUTONA TARGET VERİLDİ
    @objc func btn1Tapped(_ sender: UIButton){
        
        print("İndexpath : \(indexPathRow) -- Buton : 1")
        yuklePuan(puan_kullanici_id_param: secilen_kullanici_id, indexPathRow_param: sender.tag, puan_param: 1)
        
    }
    @objc func btn2Tapped(_ sender: UIButton){
        
        print("İndexpath : \(indexPathRow) -- Buton : 2")
        yuklePuan(puan_kullanici_id_param: secilen_kullanici_id, indexPathRow_param: sender.tag, puan_param: 2)
        
    }
    @objc func btn3Tapped(_ sender: UIButton){
        
        print("İndexpath : \(indexPathRow) -- Buton : 3")
        yuklePuan(puan_kullanici_id_param: secilen_kullanici_id, indexPathRow_param: sender.tag, puan_param: 3)
        
    }
    @objc func btn4Tapped(_ sender: UIButton){
        
        print("İndexpath : \(indexPathRow) -- Buton : 4")
        yuklePuan(puan_kullanici_id_param: secilen_kullanici_id, indexPathRow_param: sender.tag, puan_param: 4)
        
    }
    @objc func btn5Tapped(_ sender: UIButton){
        
        print("İndexpath : \(indexPathRow) -- Buton : 5")
        yuklePuan(puan_kullanici_id_param: secilen_kullanici_id, indexPathRow_param: sender.tag, puan_param: 5)
        
    }
    
    func yuklePuan(puan_kullanici_id_param : String , indexPathRow_param : Int , puan_param : Int){
        
        self.view.isUserInteractionEnabled = false
        
        if Reachability.isConnectedToNetwork(){
            //KULLANICIYA BEKLEMESİ SÖYLENECEK
            self.showWaitOverlay()
     
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                let json: [String: Any] = [
                    "kendi_kullanici_id" : UserDefaults.standard.string(forKey: "kullanici_id")!,
                    "puan_kullanici_id":   puan_kullanici_id_param,
                    "soru_id":             sorularJson[indexPathRow_param].id,
                    "puan" :               puan_param
                ]
                print(json)
                
                let jsonData = try? JSONSerialization.data(withJSONObject: json)
                let url = URL(string: base_url + "/soru/sorular_giris.php")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                DispatchQueue.main.async {
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print(error?.localizedDescription ?? "No data")
                            return
                        }
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        if let responseJSON = responseJSON as? [String: Any] {
                            print(responseJSON)
                            
                            let cevapValue =  responseJSON["cevap"] as? String
                            print(cevapValue)
                            if cevapValue == "1" {
                                DispatchQueue.main.async {
                                    self.removeAllOverlays()
                                    sorularJson.remove(at: indexPathRow_param)
                                    self.tabloReload()
                                    self.view.isUserInteractionEnabled = true
                                }
                            }
                            else if cevapValue == "0" {
                                DispatchQueue.main.async {
                                    self.removeAllOverlays()
                                    sorularJson.remove(at: indexPathRow_param)
                                    self.tabloReload()
                                    self.alertFunction(message: "Daha Önce Bu Soruya Puan Verdiniz...")
                                    self.view.isUserInteractionEnabled = true
                                }
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    
    func fetchQuestions(){
        
        
        //PHP DOSYASINA GÖNDERİLECEK URL OLUŞTURULUYOR
        var postString = base_url + "/soru/sorulari_getir.php"
        let myUrl = URL(string: postString )
        
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "GET"// Compose a query string
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            DispatchQueue.main.async {
                if let error = error  {
                    print("Hata")
                    self.alertFunction(message: "Geçersiz İstek. Bilinmeyen Hata")
                    return
                }
                guard let data = data else {return}
                do{
                    let decoder = JSONDecoder()
                    sorularJson.removeAll()
                    sorularJson = try decoder.decode([Soru].self, from: data)
                    
                    print(sorularJson)
                    self.tabloReload()
                    
                }
                catch let jsonError{
                    print("Fail", jsonError)
                }
            }
            
        }
        task.resume()
        
        
    }
    
    //sağdaki buton navigationdaki
    @objc func infoTapped(){
        
        let title = "1 ile 5 Arasında Soruları Puanlayın. Anonim Olarak Değerlendirin. Sorunuz Varsa Profil Destek Sayfasından Bize Ulaşabilirsiniz"
        let message = ""
        let popup = PopupDialog(title: title, message: message)
        popup.transitionStyle = .fadeIn
        let buttonOne = CancelButton(title: "Tamam") {
            print("Tamam tuşuna basıldı.")
        }
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
        
    }
    
    
    func tabloReload(){
        
        //        UIView.transition(with: self.tableView,
        //                          duration: 0.7,
        //                          options: .transitionCrossDissolve,
        //        animations: { self.tableView.reloadData() })
        //
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        
    }
    
    
    
}

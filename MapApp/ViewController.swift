//
//  ViewController.swift
//  MapApp
//
//  Created by Ahmet GÜVENDİK on 7.03.2023.
//

import UIKit
import CoreData

var selectedName = ""
var selectedId = UUID()
var nameArray = [String]()
var idArray = [UUID]()

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toSavePage", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSavePage"{
            let SaveVC =  segue.destination as! SaveViewController
            SaveVC.selectedName = selectedName
            SaveVC.selectedId = selectedId
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func toSavePageButton(_ sender: Any) {
        selectedName = ""
        performSegue(withIdentifier: "toSavePage", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }

    func getData(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Map")
        fetch.returnsObjectsAsFaults = false
        
        do{
            let data = try context?.fetch(fetch)
            for datas in data as! [NSManagedObject]{
                if let name = datas.value(forKey: "name") as? String{
                    nameArray.append(name)
                }
                
                if let id = datas.value(forKey: "id") as? UUID{
                    idArray.append(id)
                }
            }
        } catch{
            print("HATA")
        }
        
        
    }
    
}


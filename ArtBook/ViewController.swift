//
//  ViewController.swift
//  ArtBook
//
//  Created by Burak AKCAN on 10.06.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var nameList:[String] = []
    var idLst = [UUID]()
    var selectedItemName = ""
    var selectedItemId:UUID?
    
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        getData()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//Observer kim ViewController ın kendisi o yüzden self yazdık
// notificationName diğe tarafta mesaj olarak gelen stringin aynısı olmak zorunda
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItemName = nameList[indexPath.row]
        selectedItemId = idLst[indexPath.row]
       performSegue(withIdentifier: "detail", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.choosenItem = selectedItemName
            destinationVC.choosenId = selectedItemId
        }
    }
    
    
    
   


}


extension ViewController {
    @objc func addButton(){
        
        performSegue(withIdentifier: "detail", sender: nil)
        
    }
    
   @objc func getData(){
//Duplicate olmasın (başta bir kere getirdi listeyi , bir veri kaydettik bir daha getrsin istemeyiz ) bunun için
       nameList.removeAll(keepingCapacity: false)
       idLst.removeAll(keepingCapacity: false)
      
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        //FetchRequest
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        //burayı false yaparsak daha hızlı okuma yapacaktır CoreData dan
        fetchRequest.returnsObjectsAsFaults = false
       let sorter = NSSortDescriptor(key: "name", ascending: true)
       fetchRequest.sortDescriptors = [sorter]
        do{
            //results Any tipinde bir liste
           let results = try context.fetch(fetchRequest)  // bu bize liste getirir
            //NSManagedObject bir Core Data objesidir
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String{
                    self.nameList.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID{
                    self.idLst.append(id)
                }
                //veri geldi ve refresh  edilmesi gerekli
                
                self.tableView.reloadData()
                
            }
        }catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
            let idString = idLst[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if !results.isEmpty{
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idLst[indexPath.row]{
                                context.delete(result)
                                nameList.remove(at: indexPath.row)
                                idLst.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print(error)
                                }
//Aranılan şey bulunduysa döngüden çıkmak için break yaptık
                                break
                            }
                        }
                    }
                }
            }catch{
                print(error)
            }
        }
    }
}

// Sıralama yapmak için kullanırız sorter ı


/*func fetchRequest()->NSFetchRequest<NSFetchRequestResult>{
//veritabanını yüklemeye çalışıyoruz
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
//Verileri alfabetik sıraya göre getirmesini istiyorsak
//Verileri hangi sıraya göre getirsin titleText egöre getirsin veascending true a-z ye false z-a olur
    let sorter = NSSortDescriptor(key: "titleText", ascending: true)
    fetchRequest.sortDescriptors = [sorter]
    return fetchRequest
    
} */

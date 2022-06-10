//
//  DetailViewController.swift
//  ArtBook
//
//  Created by Burak AKCAN on 10.06.2022.
//

import UIKit
import CoreData
//Picker kullnamak için UIImageControllerDelegate ve UINavigationControllerDelegate protocollerini eklemem gerekli

class DetailViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var saveButtonView: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    var choosenItem = ""
    var choosenId:UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("burası çalıştı")
//SaveButton custom
        saveButtonView.layer.isOpaque = true
        saveButtonView.layer.cornerRadius = 40
//view gestureRecognizer
        let gestureRecog = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        //Bu sefer bir image a değilde view ın kendisine verdik 
        view.addGestureRecognizer(gestureRecog)
 //image Recognizer
        detailImage.isUserInteractionEnabled = true
        let imageGestureRecog = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        detailImage.addGestureRecognizer(imageGestureRecog)
        
        if choosenItem != "" {
            
            saveButtonView.isHidden = true
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            //Filtreleme işlemi yapacağız ki gelen uuid ye göre veriyi göstermeliyiz

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
            let idString = choosenId?.uuidString
            //bir koşul yazıcam buraya ve o koşulu sağlayanı bulup getirecek bana
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
           // fetchRequest.predicate = NSPredicate(format: "name = %@",choosenItem!)
            //yukarıdaki gibi name göre de yapabilirdim fakat aynı isimden varsa sıkıntı olurdu
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if !(results.isEmpty){
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String{
                            nameTextField.text = name
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearTextField.text = String(year)
                            
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistTextField.text = artist
                        }
                        if let data = result.value(forKey: "image") as? Data{
                            let img = UIImage(data: data)
                            detailImage.image = img
                        }
                    }
                    
                }
            }catch{
            print(error)
            }
            
        }else{
            //Boş geldi viewcontrollerdan o yüzden textfield larım boş görünecek
            //burası yeni  bir ürün eklerken
            nameTextField.text = ""
            artistTextField.text = ""
            yearTextField.text = ""
            print("girdi")
            
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
//Bizim context e ulaşmamız için appdelegate ı br değişken olarak tanımlamımız gerekiyor
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //contexte de ulaştık
        let context = appDelegate.persistentContainer.viewContext
        
//context in içine ne koyacağız
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: context)
        //Attributes
        newItem.setValue(nameTextField.text, forKey: "name")
        newItem.setValue(artistTextField.text, forKey: "artist")
        if let year = Int(yearTextField.text!){
            newItem.setValue(year, forKey: "year")
        }
        //id ye uniqe bir değer atamak için kullanılan yapı
        newItem.setValue(UUID(), forKey: "id")
        let data = detailImage.image!.jpegData(compressionQuality: 0.6)
        newItem.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("succes")
           
        }catch{
            print(error)
        }
//Ana sayfaya yeni bir eleman eklendi veritabanına demek için notyificationCenter yapısını kullanacağız
        //Diğer viewControllerlara bir mesaj yollamamı sağlar
        //Buraya bir mesaj yazağız vebu mesaj gelirse diğer taraf tableView listesini yenileyecek
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func hideKeyboard(){
//View içerisinde yaptığımız değişiklikleri kapatıyor
        //klavyeyi kapatacaktır
        view.endEditing(true)
        
    }
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
//seçilen resmi editlemek için kullanılır
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
//Kullanıcı resmi seçtikten sonra ypaılacaklar
//Görsel seçildikten sonra
//Burası bize bir dictionary dönderiyor
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //orijinal image default olandır
        detailImage.image = info[.originalImage] as? UIImage
// açılan pickerı kapatmak için dismis metodunu yazıyoruz
        self.dismiss(animated: true, completion: nil)
    }

}

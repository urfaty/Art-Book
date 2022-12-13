//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Tayfur Salih Şen on 18.07.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var SaveOutlet: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingid : UUID?
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""{
            
            SaveOutlet.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingid?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false

            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            nameTextField.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistTextField.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearTextField.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageview.image = image
                        }
                    }
                }
                
            }
            catch{print("error")}
            
            
        }
        else{
            SaveOutlet.isHidden = false
            SaveOutlet.isEnabled = false
            nameTextField.text = ""
            artistTextField.text = ""
            yearTextField.text = ""
        }

        
        // Recognizers
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageview.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageview.addGestureRecognizer(imageTapRecognizer)
    }
    

    
    
    
   
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageview.image = info[.originalImage] as? UIImage
        SaveOutlet.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPaintings = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        // Attributes
        
        newPaintings.setValue(artistTextField.text, forKey: "artist")
        newPaintings.setValue(UUID(), forKey: "id")
        newPaintings.setValue(nameTextField.text, forKey: "name")
        
        if let year = Int(yearTextField.text!){
            newPaintings.setValue(year, forKey: "year")
        }
        
        let data = imageview.image!.jpegData(compressionQuality: 0.5)
        
        newPaintings.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        }
        catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object:nil)
        self.navigationController?.popViewController(animated: true)



    }

}

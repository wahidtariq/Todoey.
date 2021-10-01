//
//  CategoryViewController.swift
//  DocumentPicker
//
//  Created by wahid tariq on 30/09/21.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var categories = [`Category`]()
   
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryName = UITextField()
        
        let alert = UIAlertController(title: "Add new Category.", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            
            
            if categoryName.text == ""{
                let ac = UIAlertController(title: "OOPS :(", message: "Looks Like You haven't Typed Anything", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
                return
            }
            
            let newName = Category(context: self.context)
            newName.name = categoryName.text
            self.categories.append(newName)
            self.saveItems()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Category Name"
            categoryName = alertTextField
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    //MARK: - tableView data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
        
          }
    //MARK: - tableView Delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToSegue", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            
            destinationVC.selectedCatagory = categories[indexPath.row]
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//        context.delete(Category[indexPath.row])
            context.delete(categories[indexPath.row])
        self.categories.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        saveItems()
        }
        }
        
        
        
      
    func saveItems(){
        
        do{
            try context.save()
            
        }catch{
            print("error while saving the context\(error)")
        }
        tableView.reloadData()
        
    }
    
    func loadItems(){
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories = try context.fetch(request)
        }catch{
            print("error\(error) while loading the items :-( ")
        }
        tableView.reloadData()
    }
    
}



//
//  ViewController.swift
//  DocumentPicker
//
//  Created by wahid tariq on 21/09/21.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    var itemArray = [Item]()

    var selectedCatagory: Category?{
        didSet{
            loadItems()
        }
    }

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
//
    }
    
    //MARK: - TableView DataSource
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        //      value ------------ = condition  ? valueIfTrue : valueIfFlase
        cell.accessoryType =  item.done ?.checkmark   : .none
//        cell.accessoryType = .checkmark
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
    context.delete(itemArray[indexPath.row])
    self.itemArray.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .fade)
    saveItems()
    }
    }
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
    }
    
    
    @IBAction func addTextFieldPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()
    
        let alert = UIAlertController(title: "Add New Todoey item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
           
            if textField.text == ""{
                let ac = UIAlertController(title: "OOPS :(", message: "Looks Like You haven't Typed Anything", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
                return
            }

            let newitem = Item(context: self.context)
            newitem.title = textField.text!
            newitem.parentCategory = self.selectedCatagory
            newitem.done = false
            
            self.itemArray.append(newitem)
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error while saving Context\(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        
        let Categorypredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCatagory!.name!)
        
        if let addtionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [Categorypredicate, addtionalPredicate])
        }else{
            request.predicate = Categorypredicate
        }


        do{
            itemArray = try context.fetch(request)
        }catch{
            print("error\(error) while loading the items :-( ")
        }
        tableView.reloadData()
    }
}
    
//MARK: - Search Bar methods.
extension TodoListViewController: UISearchBarDelegate{
    
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
            guard let searchBarText = searchBar.text else{ return }
            
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            
           let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBarText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    
            loadItems(with: request, predicate: predicate)
    
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                
                searchBar.resignFirstResponder()
            }
         
            
        }else{
           
         searchBarSearchButtonClicked(searchBar)
            
        }
    }
}

// updating in CoreData
//itemArray[indexPath.row].setValue("Hello", forKey: "title")





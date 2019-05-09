//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Donald McAllister on 5/9/19.
//  Copyright © 2019 Donald McAllister. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadItems()
        
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
//
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
   
        //value = condition ? valueIfTrue : valueIfFalse
       cell.accessoryType = item.done ? .checkmark : .none
      
        return cell
    }
    

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //can UPDATE NSManagedObject:
        //itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
       
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //can't just get the context by saying context = AppDelegate.persistentContainer.viewContext
            //We need to get the object of our delegate. singletons which allows us to get access to AppDelegate.swift:
            //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext <---made global, see above
            //remember Item class automitcally generated, of type: NSManagedObject which are like the rows in table
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false //needed because not optional selected in Data Model
            self.itemArray.append(newItem)
            
           
            self.saveItems()
            
            
            self.tableView.reloadData()
        }

        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new item"
           textField = alertTextfield //extending scope..
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manipulation Methods: Save and Load data, NSCoder
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
           print("error saving context, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
      
        // let request: NSFetchRequest<Item> = Item.fetchRequest()
        //speak to context before we can do anything else:
        do {
               itemArray = try context.fetch(request)
        } catch {
                print("Error fetching data from context \(error)")
        }
     
        tableView.reloadData()

    }
    
   
}

//MARK: - Search Bar Method

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
       request.predicate  = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)

        
    }
}

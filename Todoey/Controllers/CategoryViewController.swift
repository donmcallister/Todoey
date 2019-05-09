//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Donald McAllister on 5/9/19.
//  Copyright © 2019 Donald McAllister. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()

    }

    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let item = categoryArray[indexPath.row]
        
        cell.textLabel?.text = item.name
        
        //value = condition ? valueIfTrue : valueIfFalse
        //cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //can UPDATE NSManagedObject:
        //itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        //categoryArray[indexPath.row].done = !categoryArray[indexPath.row].done
        
        saveCategory()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            //can't just get the context by saying context = AppDelegate.persistentContainer.viewContext
            //We need to get the object of our delegate. singletons which allows us to get access to AppDelegate.swift:
            //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext <---made global, see above
            //remember Item class automitcally generated, of type: NSManagedObject which are like the rows in table
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categoryArray.append(newCategory)
            
            
            self.saveCategory()
            
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new category"
            textField = alertTextfield //extending scope..
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
        
    
    
    //MARK - Model Manipulation Methods: Save and Load data, NSCoder
    
    func saveCategory() {
        
        do {
            try context.save()
        } catch {
            print("error saving context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategory() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        //speak to context before we can do anything else:
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    
}



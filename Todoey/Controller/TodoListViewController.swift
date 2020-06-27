//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    var itemArray:Array<TodoItem> = [TodoItem]()
    
    var selectedCategory: Category? {
        didSet {
            loadTodoItems()
            print("didSet called")
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(dataFilePath)
        
//        loadTodoItems()
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentTodoItem = itemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = currentTodoItem.title
        cell.accessoryType = currentTodoItem.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        saveTodoItems()
    }
    
    //MARK - Add new todo item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Todo Item", message: "So you can add a new todo iteam", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newTodo = TodoItem(context: self.context)
            newTodo.title = textField.text!
            newTodo.done = false
            newTodo.parentCategory = self.selectedCategory
            
            self.itemArray.append(newTodo)
            self.saveTodoItems()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter the todo task..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func saveTodoItems() -> Void {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        updateUi()
    }
    
    //MARK - Load ToDOItems from core data
    
    private func loadTodoItems(with fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), matching predicate: NSPredicate? = nil) -> Void {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            fetchRequest.predicate = compoundPredicate
        } else {
            fetchRequest.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(fetchRequest)
            updateUi()
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    //MARK - update UI
    
    private func updateUi() -> Void {
        tableView.reloadData()
    }
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        
        print(searchBar.text!)
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadTodoItems(with: request, matching: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            
            loadTodoItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

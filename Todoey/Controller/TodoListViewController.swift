//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {
        
    let realm = try! Realm()
    var todoItems: Results<ToDo>?
    
    var selectedCategory: ToDoCategory? {
        didSet {
            loadTodoItems()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodoItems()
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentTodoItem = todoItems?[indexPath.row]
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = currentTodoItem?.title
        cell.accessoryType = currentTodoItem?.done ?? false ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let todo = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    todo.done = !todo.done
                    self.updateUi()
                }
            } catch {
                print("Error saving todo: \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new todo item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Todo Item", message: "So you can add a new todo iteam", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                
                let newTodo = ToDo()
                newTodo.title = textField.text!
                newTodo.dateCreated = Date()
                
                try! self.realm.write {
                    currentCategory.toDoItems.append(newTodo)
                    self.updateUi()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter the todo task..."
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func save(todo: ToDo) -> Void {
        
        do {
            try realm.write{
                realm.add(todo)
            }
            
            updateUi()
        } catch {
            print("Error saving todo to realm: \(error)")
        }
        
    }
    
    //MARK - Load ToDOItems from core data
    
    private func loadTodoItems() -> Void {
        todoItems = selectedCategory?.toDoItems.sorted(byKeyPath: "dateCreated", ascending: true)
        updateUi()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleteing item: \(error)")
            }
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
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        updateUi()
        
        print("Search term: \(searchBar.text!)")
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


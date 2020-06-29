//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Arinze Anakor on 25/06/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<ToDoCategory>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadCategories()
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentTodoCategory = categories?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = currentTodoCategory?.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)// this should come AFTER segue!!!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        print("prepare called")
        
        if segue.identifier == "goToItems" {
            let destinationVc = segue.destination as! TodoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVc.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
    //MARK: - Add Button Action
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFiled = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "Add New Todo Category", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            
            let newCategory = ToDoCategory()
            newCategory.name = textFiled.text!
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Category"
            textFiled = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    
    func loadCategories() {
        categories = realm.objects(ToDoCategory.self)
        updateUi()
    }
    
    func save(category: ToDoCategory) -> Void {
        do {
//            try context.save()
            try realm.write{
                realm.add(category)
            }
            updateUi()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    //MARK: - UI Methos
    
    func updateUi() -> Void {
        tableView.reloadData()
    }
}



